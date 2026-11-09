from pathlib import Path
import re
h=Path.home()
p=h/'.config/sway/config'
s=p.read_text()
s=s.replace('set $term ~/.local/bin/kitty-sway','set $term foot')
s=s.replace('systemctl reboot --firmware-setup','loginctl reboot --firmware-setup').replace('systemctl poweroff -i','loginctl poweroff').replace('systemctl suspend','loginctl suspend').replace('systemctl reboot','loginctl reboot')
s='\n'.join(x for x in s.split('\n') if not any(q in x for q in ['swayosd-client','swayosd-server','vmware-user-suid-wrapper','cliphist store','clipboard-menu']))
for binding in ('exec wl-paste --type text --watch clipman store --no-persist', 'bindsym $mod+v exec clipman pick -t rofi'):
    s='\n'.join(line for line in s.split('\n') if line.strip() != binding)
    s+='\n'+binding+'\n'
for binding in ('bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+', 'bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-', 'bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle', 'bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle', 'bindsym XF86MonBrightnessUp exec brightnessctl set +5%', 'bindsym XF86MonBrightnessDown exec brightnessctl set 5%-'):
    s='\n'.join(line for line in s.split('\n') if line.strip() != binding)
    s+='\n'+binding+'\n'
p.write_text(s)
p=h/'.local/bin/clipboard-menu'
p.write_text('#!/bin/sh\nexec clipman pick -t rofi\n')
p.chmod(0o755)
for rel in ('.local/bin/btop-float', '.local/bin/show-hotkeys', '.local/bin/ssh-hub.d/tmux.conf', '.local/bin/term-hub.d/tmux.conf'):
    p=h/rel
    if not p.is_file(): continue
    s=p.read_text()
    s=s.replace('"$HOME/.local/bin/kitty-sway" --class btop --title btop /usr/bin/btop','foot -a btop -T btop /usr/bin/btop')
    s=s.replace('"$HOME/.local/bin/kitty-sway"','foot').replace('│ Kitty ', '│ Foot ').replace('nvim ', 'micro ')
    p.write_text(s)
p=h/'.config/waybar/config'
s=p.read_text(); s=re.sub(r'("network"\s*:\s*\{[^\n]*\n)[ \t]*"interface"\s*:\s*"en\*"\s*,[ \t]*\n',r'\1',s,count=1); p.write_text(s)
p=h/'.local/bin/sway-session-init'
p.write_text('''#!/bin/sh
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
pipewire &
pipewire-pulse &
wireplumber &
awww-daemon &
waybar &
( while :; do "$HOME/.local/bin/random-wallpaper.sh" || true; sleep 90; done ) &
'''); p.chmod(0o755)
p=h/'.local/bin/start-sway-alpine'
p.write_text('''#!/bin/sh
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export WLR_NO_HARDWARE_CURSORS=1
export EDITOR=micro VISUAL=micro
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then exec dbus-run-session -- "$0" "$@"; fi
exec sway "$@"
'''); p.chmod(0o755)
