#!/usr/bin/env python3
from pathlib import Path
import json, re

home=Path.home(); config=home/'.config'; bins=home/'.local/bin'
def write(path,text):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text,encoding='utf-8')
    if text.startswith('#!'): path.chmod(0o755)

p=config/'sway/config'; s=p.read_text()
s=s.replace('~/.local/bin/kitty-sway','~/.local/bin/terminal-sway')
s=s.replace('~/.local/bin/nautilus-sway','thunar')
s=s.replace('systemctl suspend','loginctl suspend')
s=s.replace('systemctl reboot','loginctl reboot').replace('systemctl poweroff -i','loginctl poweroff')
s=s.replace('swayosd-client --output-volume raise 5','pactl set-sink-volume @DEFAULT_SINK@ +5%')
s=s.replace('swayosd-client --output-volume lower 5','pactl set-sink-volume @DEFAULT_SINK@ -5%')
s=s.replace('swayosd-client --output-volume mute-toggle','pactl set-sink-mute @DEFAULT_SINK@ toggle')
s=s.replace('swayosd-client --input-volume mute-toggle','pactl set-source-mute @DEFAULT_SOURCE@ toggle')
s=re.sub(r'^.*swayosd-client --(?:brightness|caps-lock).*\n','',s,flags=re.M)
s=s.replace('exec swayosd-server\n','')
write(p,s)
for root in [bins,config/'sway',home/'.bin']:
    if not root.exists():continue
    for p in root.rglob('*'):
        if not p.is_file() or p.is_symlink():continue
        try:s=p.read_text()
        except (UnicodeError,OSError):continue
        old=s
        s=s.replace('kitty-sway','terminal-sway')
        s=re.sub(r'(?<![\w./-])nvim(?![\w./-])','micro',s)
        if s!=old:p.write_text(s)
for p in [home/'.aliases',home/'.functions']:
    if p.exists():
        s=p.read_text().replace('/usr/bin/fastfetch','fastfetch')
        s=re.sub(r'(?<![\w./-])nvim(?![\w./-])','micro',s)
        p.write_text(s)
write(bins/'terminal-sway', '''#!/usr/bin/env bash
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
write(bins/'btop-float', '''#!/bin/sh
exec "$HOME/.local/bin/terminal-sway" --class btop --title btop /usr/bin/btop
''')
write(bins/'nautilus-sway', '''#!/bin/sh
exec /usr/bin/thunar "$@"
''')
write(bins/'random-wallpaper.sh', r'''#!/usr/bin/env bash
set -euo pipefail
wallpaper=${1:-$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n1)}
[[ -f "$wallpaper" ]] || exit 1
pkill -u "$(id -u)" -x swaybg 2>/dev/null || true
swaybg -i "$wallpaper" -m fill >/dev/null 2>&1 &
''')
write(bins/'sway-wallpaper-loop', '''#!/usr/bin/env bash
set -euo pipefail
while swaymsg -t get_version >/dev/null 2>&1; do
  "$HOME/.local/bin/random-wallpaper.sh" || true
  sleep 90
done
''')
write(bins/'sway-session-init', '''#!/usr/bin/env bash
set -euo pipefail
export XDG_CURRENT_DESKTOP=sway
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY || true
for daemon in pipewire pipewire-pulse wireplumber waybar; do
  if ! pgrep -u "$(id -u)" -x "$daemon" >/dev/null; then
    "$daemon" >"$HOME/.local/state/sway-slackware/$daemon.log" 2>&1 &
  fi
done
"$HOME/.local/bin/sway-wallpaper-loop" >/dev/null 2>&1 &
''')
write(bins/'start-sway-full', '''#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
export LANG=pt_BR.UTF-8 EDITOR=micro VISUAL=micro
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export XCURSOR_THEME=Vimix-cursors XCURSOR_SIZE=24 WLR_NO_HARDWARE_CURSORS=1
export GSK_RENDERER=cairo GDK_DISABLE=dmabuf
if [[ -z ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then exec dbus-run-session -- "$0" "$@"; fi
exec /usr/bin/sway "$@"
''')
p=config/'waybar/config'; data=json.loads(p.read_text());data['network']['interface']='eth0'
write(p,json.dumps(data,ensure_ascii=False,indent=4)+'\n')
write(config/'foot/foot.ini','''[main]
font=CodeNewRoman Nerd Font Mono:size=12
term=xterm-256color
pad=12x12
[colors-dark]
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
write(config/'micro/settings.json',json.dumps({'colorscheme':'nord-16','softwrap':True,'tabsize':4},indent=2)+'\n')
p=home/'.bashrc'; s=p.read_text() if p.exists() else ''
s=s.split('\n# sway-slackware editor',1)[0]
s+='''
# sway-slackware editor
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
if ! command -v zoxide >/dev/null; then alias j='cd'; fi
command -v bat >/dev/null || unalias cat 2>/dev/null || true
command -v tldr >/dev/null || unalias man 2>/dev/null || true
command -v procs >/dev/null || unalias ps 2>/dev/null || true
if ! command -v eza >/dev/null; then
  alias ls='ls --color=auto'
  alias ll='ls -lah'
  alias lr='ls -R'
fi
if ! command -v duf >/dev/null; then
  unalias duf 2>/dev/null || true
  alias df='df -h'
fi
'''
write(p,s)
write(config/'wlogout/session-action.sh','''#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  lock) exec /usr/bin/swaylock -f -c 303446 ;;
  logout) exec /usr/bin/swaymsg exit ;;
  poweroff|reboot) exec /usr/bin/loginctl "$1" ;;
  *) exit 2 ;;
esac
''')
s=(config/'wlogout/layout').read_text()
assert '/usr/bin/loginctl poweroff' in s and '/usr/bin/loginctl reboot' in s
apps=home/'.local/share/applications'
write(apps/'micro.desktop',f'''[Desktop Entry]
Type=Application
Name=Micro
Exec={bins}/terminal-sway micro %F
Icon=accessories-text-editor
Categories=Utility;TextEditor;
''')
