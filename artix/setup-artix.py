#!/usr/bin/env python3
"""Adapta a copia instalada do rice para elogind e uma sessao sem systemd."""
from pathlib import Path
import re

home = Path.home()
network_config = home / '.config/waybar/config'
text = network_config.read_text()
# Sem filtro en*: a Waybar acompanha a interface da rota padrao, inclusive eth0.
text = re.sub(
    r'("network"\s*:\s*\{[^\n]*\n)[ \t]*"interface"\s*:\s*"en\*"\s*,[ \t]*\n',
    r'\1', text, count=1)
network_config.write_text(text)

config = home / '.config/sway/config'
text = config.read_text()
for old, new in [
    ('systemctl reboot --firmware-setup', 'loginctl reboot --firmware-setup'),
    ('systemctl poweroff -i', 'loginctl poweroff'),
    ('systemctl suspend', 'loginctl suspend'),
    ('systemctl reboot', 'loginctl reboot'),
]:
    text = text.replace(old, new)
config.write_text(text)

def executable(name, text):
    p = home / '.local/bin' / name
    p.write_text(text)
    p.chmod(0o755)

executable('start-sway-full', '''#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export XCURSOR_THEME=Vimix-cursors XCURSOR_SIZE=24 LANG=pt_BR.UTF-8
export GSK_RENDERER=cairo GDK_DISABLE=dmabuf
if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  exec dbus-run-session -- "$0" "$@"
fi
if grep -qi vmware /sys/class/dmi/id/sys_vendor; then export WLR_NO_HARDWARE_CURSORS=1; fi
session_pidfile="$XDG_RUNTIME_DIR/sway-artix-session.pid"
cleanup() {
  if [[ -r "$session_pidfile" ]]; then
    read -r session_pid < "$session_pidfile"
    kill -TERM "$session_pid" 2>/dev/null || true
    rm -f "$session_pidfile"
  fi
}
trap cleanup EXIT
trap 'kill -TERM "$sway_pid" 2>/dev/null || true' TERM INT
/usr/bin/sway "$@" &
sway_pid=$!
wait "$sway_pid"
''')

executable('sway-session-init', '''#!/usr/bin/env bash
set -euo pipefail
export XDG_CURRENT_DESKTOP=sway
export GSK_RENDERER=cairo GDK_DISABLE=dmabuf
exec 9>"$XDG_RUNTIME_DIR/sway-artix-session.lock"
flock -n 9 || exit 0
printf '%s\\n' "$$" > "$XDG_RUNTIME_DIR/sway-artix-session.pid"
children=()
start() { "$@" 9>&- & children+=("$!"); }
cleanup() {
  trap - EXIT TERM INT
  kill "${children[@]}" 2>/dev/null || true
  wait 2>/dev/null || true
  rm -f "$XDG_RUNTIME_DIR/sway-artix-session.pid"
}
trap cleanup EXIT
trap 'exit 0' TERM INT
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP GSK_RENDERER GDK_DISABLE
start pipewire
start pipewire-pulse
start wireplumber
start awww-daemon
start waybar
start elogind-inhibit --what=idle --mode=block --who=Caffeine --why='Caffeine ativo por padrao' sleep infinity
start bash -c 'while :; do "$HOME/.local/bin/random-wallpaper.sh" || true; sleep 90; done'
wait
''')

# Substitui a parte de servicos do helper de wallpaper, mantendo a animacao do rice.
p = home / '.local/bin/random-wallpaper.sh'
s = p.read_text()
start = s.index('if [[ -z "${WAYLAND_DISPLAY:-}" ]] && command -v systemctl')
end = s.index('if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then', start)
s = s[:start] + s[end:]
start = s.index('if ! command -v systemctl')
end = s.index('for attempt in', start)
s = s[:start] + '''if ! awww query >/dev/null 2>&1; then
  awww-daemon >/dev/null 2>&1 &
fi
''' + s[end:]
p.write_text(s)

# O modulo bash detecta Artix separadamente; carregar aliases pacman explicitamente.
p = home / '.bashrc'
s = p.read_text()
addition = '''
# Artix: aliases do pacman compartilhados com Arch.
[[ ! -f "$HOME/.aliases-arch" ]] || source "$HOME/.aliases-arch"
export EDITOR=nvim VISUAL=nvim
'''
if '# Artix: aliases do pacman' not in s:
    p.write_text(s + addition)
