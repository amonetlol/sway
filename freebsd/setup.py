from pathlib import Path
import re
h=Path.home()
p=h/'.config/sway/config'; s=p.read_text()
s=s.replace('set $term ~/.local/bin/kitty-sway','set $term foot')
s=s.replace('output Virtual-1 mode 1920x1080 position 0,0 scale 1','# Saida detectada automaticamente')
s=s.replace('systemctl reboot --firmware-setup','true').replace('systemctl poweroff -i','sudo /sbin/shutdown -p now').replace('systemctl suspend','true').replace('systemctl reboot','sudo /sbin/shutdown -r now')
s='\n'.join(x for x in s.split('\n') if not any(q in x for q in ('swayosd-client','swayosd-server','vmware-user-suid-wrapper','/usr/bin/gnome-keyring-daemon','/usr/libexec/polkit-gnome','waybar-player-watch','bindsym XF86AudioRaiseVolume exec wpctl','bindsym XF86AudioLowerVolume exec wpctl','bindsym XF86AudioMute exec wpctl')))
s+='\nbindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\nbindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\nbindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\n'
p.write_text(s)
p=h/'.config/wlogout/layout';s=p.read_text().replace('/usr/bin/swaylock','/usr/local/bin/swaylock').replace('/usr/bin/swaymsg','/usr/local/bin/swaymsg').replace('/usr/bin/loginctl poweroff','sudo /sbin/shutdown -p now').replace('/usr/bin/loginctl reboot','sudo /sbin/shutdown -r now');p.write_text(s)
p=h/'.config/wlogout/launch.sh';p.write_text(p.read_text().replace('/usr/bin/wlogout','/usr/local/bin/wlogout'))
p=h/'.config/waybar/config';s=p.read_text();s=re.sub(r'("network"\s*:\s*\{[^\n]*\n)[ \t]*"interface"\s*:\s*"en\*"\s*,[ \t]*\n',r'\1',s,count=1);p.write_text(s)
for rel in ('.local/bin/btop-float','.local/bin/show-hotkeys','.local/bin/ssh-hub.d/tmux.conf','.local/bin/term-hub.d/tmux.conf'):
 p=h/rel
 if p.is_file():
  s=p.read_text().replace('"$HOME/.local/bin/kitty-sway" --class btop --title btop /usr/bin/btop','foot -a btop -T btop btop').replace('"$HOME/.local/bin/kitty-sway"','foot').replace('nvim ', 'micro ');p.write_text(s)
for name in ('nautilus-sway', 'pavucontrol'):
 p=h/'.local/bin'/name
 if p.is_file(): p.write_text(p.read_text().replace('/usr/bin/', '/usr/local/bin/'))
p=h/'.local/bin/wallpaper-freebsd';p.write_text('''#!/usr/bin/env python3
from pathlib import Path
import random, subprocess, time
directory = Path.home() / 'Imagens/wallpapers'
while True:
    files = [p for p in directory.rglob('*') if p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp')]
    if files:
        subprocess.run(['awww', 'img', '--transition-type', 'fade', str(random.choice(files))], check=False)
    time.sleep(90)
''');p.chmod(0o755)
p=h/'.local/bin/sway-session-init';p.write_text("#!/bin/sh\ndbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP\npipewire &\npipewire-pulse &\nwireplumber &\nawww-daemon &\n(sleep 3; \"$HOME/.local/bin/wallpaper-freebsd\") &\nwaybar &\n");p.chmod(0o755)
p=h/'.local/bin/start-sway-freebsd';p.write_text("#!/bin/sh\nexport XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland\nexport XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/sway-runtime-$(id -u)}\nmkdir -p \"$XDG_RUNTIME_DIR\" && chmod 700 \"$XDG_RUNTIME_DIR\"\nexport WLR_BACKENDS=x11 WLR_RENDERER=pixman WLR_NO_HARDWARE_CURSORS=1\nexport EDITOR=micro VISUAL=micro\nif [ -z \"${DBUS_SESSION_BUS_ADDRESS:-}\" ]; then exec dbus-run-session -- \"$0\" \"$@\"; fi\nexec sway \"$@\"\n");p.chmod(0o755)
