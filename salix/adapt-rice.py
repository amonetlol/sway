#!/usr/bin/env python3
from pathlib import Path
import json, re

home = Path.home()
config = home / '.config'
bins = home / '.local/bin'

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')
    if text.startswith('#!'):
        path.chmod(0o755)

p = config / 'sway/config'
s = p.read_text(encoding='utf-8')
s = s.replace('~/.local/bin/kitty-sway', '~/.local/bin/terminal-sway')
s = s.replace('~/.local/bin/nautilus-sway', 'thunar')
s = s.replace('systemctl suspend', 'loginctl suspend')
s = s.replace('systemctl reboot --firmware-setup', 'loginctl reboot --firmware-setup')
s = s.replace('systemctl reboot', 'loginctl reboot')
s = s.replace('systemctl poweroff -i', 'loginctl poweroff')
s = s.replace('swayosd-client --output-volume raise 5', 'pactl set-sink-volume @DEFAULT_SINK@ +5%')
s = s.replace('swayosd-client --output-volume lower 5', 'pactl set-sink-volume @DEFAULT_SINK@ -5%')
s = s.replace('swayosd-client --output-volume mute-toggle', 'pactl set-sink-mute @DEFAULT_SINK@ toggle')
s = s.replace('swayosd-client --input-volume mute-toggle', 'pactl set-source-mute @DEFAULT_SOURCE@ toggle')
s = re.sub(r'^.*swayosd-client --(?:brightness|caps-lock).*\n', '', s, flags=re.M)
s = s.replace('exec swayosd-server\n', '')
s = re.sub(r'(?<![\w./-])nvim(?![\w./-])', 'micro', s)
write(p, s)

for root in [bins, config / 'sway', home / '.bin']:
    if not root.exists():
        continue
    for path in root.rglob('*'):
        if not path.is_file() or path.is_symlink():
            continue
        try:
            text = path.read_text(encoding='utf-8')
        except (UnicodeError, OSError):
            continue
        new = text.replace('kitty-sway', 'terminal-sway')
        new = re.sub(r'(?<![\w./-])nvim(?![\w./-])', 'micro', new)
        if new != text:
            path.write_text(new, encoding='utf-8')

write(bins / 'terminal-sway', '''#!/usr/bin/env bash
set -euo pipefail
args=()
while (($#)); do
  case "$1" in
    --class) args+=(--app-id "$2"); shift 2 ;;
    --title) args+=(--title "$2"); shift 2 ;;
    --directory) args+=(--working-directory "$2"); shift 2 ;;
    -e|--) shift; break ;;
    *) break ;;
  esac
done
exec /usr/bin/foot "${args[@]}" "$@"
''')
write(bins / 'btop-float', '''#!/bin/sh
exec "$HOME/.local/bin/terminal-sway" --class btop --title btop /usr/bin/btop
''')
write(bins / 'nautilus-sway', '''#!/bin/sh
exec /usr/bin/thunar "$@"
''')
write(bins / 'random-wallpaper.sh', r'''#!/usr/bin/env bash
set -euo pipefail
wallpaper=${1:-$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n1)}
[[ -f "$wallpaper" ]] || exit 1
pkill -u "$(id -u)" -x swaybg 2>/dev/null || true
swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
''')
write(bins / 'sway-wallpaper-loop', '''#!/usr/bin/env bash
set -euo pipefail
while swaymsg -t get_version >/dev/null 2>&1; do
  "$HOME/.local/bin/random-wallpaper.sh" || true
  sleep 90
done
''')
write(bins / 'sway-session-init', '''#!/usr/bin/env bash
set -euo pipefail
export XDG_CURRENT_DESKTOP=sway
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY || true
if command -v pipewire-pulse >/dev/null 2>&1; then
  for daemon in pipewire pipewire-pulse wireplumber; do
    pgrep -u "$(id -u)" -x "$daemon" >/dev/null || "$daemon" >/dev/null 2>&1 &
  done
elif command -v pulseaudio >/dev/null 2>&1; then
  pgrep -u "$(id -u)" -x pulseaudio >/dev/null || pulseaudio --start
fi
pgrep -u "$(id -u)" -x waybar >/dev/null || waybar >/dev/null 2>&1 &
"$HOME/.local/bin/sway-wallpaper-loop" >/dev/null 2>&1 &
''')
write(bins / 'start-sway-full', '''#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
export LANG=pt_BR.UTF-8 EDITOR=micro VISUAL=micro
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export XCURSOR_THEME=Vimix-cursors XCURSOR_SIZE=24 WLR_NO_HARDWARE_CURSORS=1
if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then exec dbus-run-session -- "$0" "$@"; fi
"$HOME/.local/bin/sway-session-init"
exec /usr/bin/sway "$@"
''')
waybar = json.loads((config / 'waybar/config').read_text(encoding='utf-8'))
if isinstance(waybar.get('network'), dict):
    waybar['network']['interface'] = 'eth0'
write(config / 'waybar/config', json.dumps(waybar, ensure_ascii=False, indent=4) + '\n')
write(config / 'foot/foot.ini', '''[main]
font=CodeNewRoman Nerd Font Mono:size=12
term=xterm-256color
pad=12x12
[colors]
alpha=0.96
background=303446
foreground=c6d0f5
regular0=51576d
regular1=e78284
regular2=a6d189
regular3=e5c890
regular4=8caaee
regular5=f4b8e4
regular6=81c8be
regular7=b5bfe2
bright0=626880
bright1=e78284
bright2=a6d189
bright3=e5c890
bright4=8caaee
bright5=f4b8e4
bright6=81c8be
bright7=a5adce
''')
write(config / 'micro/settings.json', json.dumps({'colorscheme': 'nord-16', 'softwrap': True, 'tabsize': 4}, indent=2) + '\n')
write(config / 'micro/colorschemes/nord-16.micro', '''color-link default "#D8DEE9,#2E3440"
color-link comment "#4C566A"
color-link constant "#B48EAD"
color-link constant.number "#B48EAD"
color-link constant.string "#A3BE8C"
color-link identifier "#D8DEE9"
color-link statement "#81A1C1"
color-link symbol "#EBCB8B"
color-link preproc "#5E81AC"
color-link type "#8FBCBB"
color-link special "#EBCB8B"
color-link underlined "#88C0D0"
color-link error "bold #BF616A"
color-link todo "bold #EBCB8B"
color-link statusline "#2E3440,#88C0D0"
color-link tabbar "#3B4252"
color-link indent-char "#434C5E"
color-link line-number "#4C566A,#3B4252"
color-link current-line-number "#D8DEE9,#3B4252"
color-link cursor-line "#3B4252"
color-link color-column "#3B4252"
color-link divider "#4C566A"
color-link scrollbar "#4C566A,#3B4252"
color-link gutter-error "#BF616A"
color-link gutter-warning "#EBCB8B"
color-link diff-added "#A3BE8C"
color-link diff-modified "#EBCB8B"
color-link diff-deleted "#BF616A"
''')
bashrc = home / '.bashrc'
current = bashrc.read_text(encoding='utf-8') if bashrc.exists() else ''
current = current.split('\n# sway-salix editor', 1)[0].rstrip() + '\n'
current += '''
# sway-salix editor
export EDITOR=micro VISUAL=micro
alias nv='micro'
alias v='micro'
alias nvim='micro'
alias tx='micro'
alias al='micro ~/.bashrc ~/.aliases'
alias al2='micro ~/.bashrc ~/.aliases ~/.functions'
alias aln='micro ~/.config/micro/settings.json'
alias alw='micro ~/.config/waybar/config ~/.config/waybar/style.css'
alias ewb='micro ~/.config/waybar/config ~/.config/waybar/style.css'
alias gfont2='fc-list | grep'
alias off='loginctl poweroff'
alias reb='loginctl reboot'
wall() { "$HOME/.local/bin/random-wallpaper.sh" "$@"; }
'''
write(bashrc, current)
write(config / 'wlogout/session-action.sh', '''#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  lock) exec /usr/bin/swaylock -f -c 303446 ;;
  logout) exec /usr/bin/swaymsg exit ;;
  poweroff|reboot) exec /usr/bin/loginctl "$1" ;;
  *) echo 'Uso: session-action.sh lock|logout|poweroff|reboot' >&2; exit 2 ;;
esac
''')
layout = (config / 'wlogout/layout').read_text(encoding='utf-8')
for action in ('/usr/bin/swaylock -f -c 303446', '/usr/bin/loginctl poweroff', '/usr/bin/loginctl reboot', '/usr/bin/swaymsg exit'):
    if action not in layout:
        raise SystemExit('Acao ausente no wlogout: ' + action)
apps = home / '.local/share/applications'
write(apps / 'micro.desktop', f'''[Desktop Entry]
Type=Application
Name=Micro
Exec={bins}/terminal-sway micro %F
Icon=accessories-text-editor
Categories=Utility;TextEditor;
''')
