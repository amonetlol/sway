#!/usr/bin/env python3
"""Adapta somente a copia instalada do sway-full para CentOS/Foot/Micro."""
from pathlib import Path
import glob, json, re, shutil

def polkit_agent():
    patterns = ['/usr/libexec/*polkit*kde*', '/usr/lib*/kf*/*polkit*kde*', '/usr/lib*/exec/*polkit*kde*', '/usr/lib*/polkit*/polkit-*-authentication-agent-1']
    for pattern in patterns:
        found = sorted(glob.glob(pattern))
        if found: return found[0]
    raise SystemExit('Nenhum agente polkit-kde encontrado')

home = Path.home()
for base in [home/'.local/bin', home/'.config/sway', home/'.config/rofi', home/'.config/rofi-wallpaper']:
    for p in base.rglob('*'):
        if not p.is_file() or p.is_symlink(): continue
        try: text = p.read_text()
        except (UnicodeError, OSError): continue
        new = re.sub(r'\bnvim\b', 'micro', text).replace('kitty-sway', 'foot-sway')
        if p.name.endswith('.rasi'): new = new.replace('terminal: "kitty"', 'terminal: "foot"')
        if p.name == 'btop-float': new = new.replace('--class btop', '--app-id btop')
        if p.name == 'recovery-shortcuts':
            new = new.replace('alacritty.desktop Alacritty.desktop kitty.desktop', 'foot.desktop footclient.desktop foot-server.desktop micro.desktop')
        if p == home/'.config/sway/config':
            new = new.replace('    xkb_variant abnt2\n', '').replace('xkb_model pc105', 'xkb_model abnt2').replace('swaybg_command -\n', '')
            new = re.sub(r'(swayosd-client --(?:output-volume|brightness) (?:raise|lower)) 5', r'\1', new)
            new = new.replace('systemctl suspend', 'loginctl suspend').replace('systemctl reboot --firmware-setup', 'loginctl reboot --firmware-setup').replace('systemctl reboot', 'loginctl reboot').replace('systemctl poweroff -i', 'loginctl poweroff')
            new = new.replace('bindsym $mod+w exec firefox', 'bindsym $mod+w exec google-chrome-stable')
            agent = polkit_agent()
            new = re.sub(r"exec sh -c 'exec /usr/libexec/polkit-gnome-authentication-agent-1 \|\| exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'", 'exec ' + agent, new)
        if p.name == 'start-sway-full':
            new = new.replace('export WLR_NO_HARDWARE_CURSORS=1', 'export WLR_NO_HARDWARE_CURSORS=1\n  export WLR_RENDERER=pixman')
        if new != text or p.read_bytes().startswith(b'#!'): p.write_text(new)

def executable(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text); path.chmod(0o755)

executable(home/'.local/bin/foot-sway', '#!/bin/sh\nexec /usr/bin/foot "$@"\n')
# Compatibilidade com scripts do modulo bin que chamam o nome antigo.
executable(home/'.local/bin/kitty-sway', '#!/bin/sh\nexec "$HOME/.local/bin/foot-sway" "$@"\n')
foot = home/'.config/foot/foot.ini'; foot.parent.mkdir(parents=True, exist_ok=True)
foot.write_text("""[main]
font=CodeNewRoman Nerd Font Mono:size=12
pad=12x12
[colors-dark]
foreground=c6d0f5
background=303446
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
""")
# No layer-shell do EL10 o clique cai no fundo e o wlogout fecha sem rodar a acao.
launch = home/'.config/wlogout/launch.sh'
launch_text = launch.read_text().replace('protocol=layer-shell', 'protocol=xdg', 1)
launch.write_text(launch_text)
launch.chmod(0o755)
session = home/'.config/wlogout/session-action.sh'
layout = home/'.config/wlogout/layout'
actions = json.loads('['+layout.read_text()+']')
for action in actions:
    action['action'] = str(session) + ' ' + action['label']
layout.write_text(',\n'.join(json.dumps(a, ensure_ascii=False, indent=2) for a in actions)+'\n')
executable(home/'.local/bin/rofi-network-menu', """#!/usr/bin/env bash
set -euo pipefail
nmcli device status | rofi -dmenu -i -p 'Rede (IPv4 fixo)' >/dev/null || true
""")
# Backend leve de wallpapers: Sway gerencia o processo swaybg via IPC.
executable(home/'.local/bin/random-wallpaper.sh', """#!/usr/bin/env bash
set -euo pipefail
python3 - "$@" <<'PY_WALL'
from pathlib import Path
import json,random,subprocess,sys
if len(sys.argv)>1:
    image=Path(sys.argv[1]).expanduser()
else:
    images=[p for p in (Path.home()/'Imagens/wallpapers').rglob('*') if p.is_file() and p.suffix.lower() in ('.jpg','.jpeg','.png','.webp')]
    if not images:raise SystemExit('Nenhum wallpaper encontrado')
    image=random.choice(images)
if not image.is_file():raise SystemExit('Wallpaper nao encontrado: '+str(image))
subprocess.run(['swaymsg','-q','output * bg '+json.dumps(str(image),ensure_ascii=False)+' fill'],check=True)
print('Wallpaper aplicado: '+str(image))
PY_WALL
""")
executable(home/'.local/bin/sway-session-init', """#!/usr/bin/env bash
export XDG_CURRENT_DESKTOP=sway GSK_RENDERER=cairo GDK_DISABLE=dmabuf
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP GSK_RENDERER GDK_DISABLE || true
pgrep -u "$(id -u)" -x pipewire >/dev/null || pipewire >/dev/null 2>&1 &
pgrep -u "$(id -u)" -x pipewire-pulse >/dev/null || pipewire-pulse >/dev/null 2>&1 &
pgrep -u "$(id -u)" -x wireplumber >/dev/null || wireplumber >/dev/null 2>&1 &
# Uma instancia. O modulo de audio aborta a waybar se o Pulse ainda nao subiu.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/pulse/native" ]] && break
  sleep 0.3
done
pgrep -x waybar >/dev/null || (ulimit -n 524288; waybar >/dev/null 2>&1 &)
(while [[ -S "${SWAYSOCK:-}" ]]; do
  "$HOME/.local/bin/random-wallpaper.sh" >/dev/null 2>&1 || true
  sleep 900
done) &
""")
with (home/'.bashrc').open('a') as f:
    f.write("\nalias swall='~/.local/bin/random-wallpaper.sh'\nalias swall2='~/.local/bin/rofi-wallpaper'\n")
style = home/'.config/waybar/style.css'
text = style.read_text()
text = re.sub(r'(?m)^  font-family:.*$', '  font-family: "Symbols Nerd Font Mono", "CodeNewRoman Nerd Font";', text, count=1)
text = re.sub(r'(?m)^  font-weight:.*$', '  font-weight: normal;', text, count=1)
text = text.replace('#pulseaudio, #bluetooth', '#pulseaudio, #custom-volume, #bluetooth')
style.write_text(text)
executable(home/'.local/bin/waybar-loop', """#!/usr/bin/env bash
while true; do
  waybar >/dev/null 2>&1
  sleep 1
done
""")
executable(home/'.local/bin/waybar-toggle', """#!/usr/bin/env bash
if pgrep -x waybar >/dev/null; then
  pkill -USR2 -x waybar
else
  (ulimit -n 524288; waybar >/dev/null 2>&1 &)
fi
""")
config = home/'.config/sway/config'
config.write_text(config.read_text().replace(
    'bindsym $mod+F12 exec pkill -USR2 -x waybar',
    'bindsym $mod+F12 exec ~/.local/bin/waybar-toggle'))
mon = home/'.local/bin/mon'
mon_text = mon.read_text()
needle = '  jq -e \'all(.[]; .success == true)\' <<< "$reply" >/dev/null\n  notify "${current} → ${target}"\n}\n'
insert = needle.replace('}\n', '  pkill -x waybar 2>/dev/null || true\n  (ulimit -n 524288; waybar >/dev/null 2>&1 &)\n}\n', 1)
if needle in mon_text and 'pkill -x waybar' not in mon_text.split('apply_sway', 1)[-1][:800]:
    mon.write_text(mon_text.replace(needle, insert, 1))
    mon.chmod(0o755)
executable(home/'.local/bin/waybar-volume', r"""#!/usr/bin/env bash
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
line=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
if [[ -z "$line" ]]; then printf '\n'; exit 0; fi
pct=$(awk '{printf "%d", $2 * 100}' <<< "$line")
if [[ "$line" == *MUTED* ]]; then
  printf ' 0%%\n'
elif (( pct < 30 )); then
  printf ' %s%%\n' "$pct"
elif (( pct < 70 )); then
  printf ' %s%%\n' "$pct"
else
  printf ' %s%%\n' "$pct"
fi
""")
bar = home/'.config/waybar/config'
data = json.loads(bar.read_text())
right = data.get('modules-right', [])
data['modules-right'] = ['custom/volume' if item == 'pulseaudio#sink' else item for item in right]
data.pop('pulseaudio#sink', None)
data['custom/volume'] = {
    'exec': str(home/'.local/bin/waybar-volume'),
    'interval': 2,
    'format': '{}',
    'on-click': str(home/'.local/bin/pavucontrol'),
}
bar.write_text(json.dumps(data, ensure_ascii=False, indent=4) + '\n')
start = home/'.local/bin/start-sway-full'
text = start.read_text().replace("cleanup() { systemctl --user stop sway-session.target 2>/dev/null || true; }", "cleanup() { :; }")
start.write_text(text); start.chmod(0o755)
