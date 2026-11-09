#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
backup="$HOME/.local/state/sway-mocaccino/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$HOME/.local/bin"
for f in waybar-volume random-wallpaper.sh sway-session-init wallpaper-thumbnails; do
  [[ ! -e "$HOME/.local/bin/$f" ]] || cp -a "$HOME/.local/bin/$f" "$backup/$f"
  install -m755 "$here/overrides/$f" "$HOME/.local/bin/$f"
done
export MOCACCINO_OVERRIDES="$here/overrides"
python3 - <<'PY'
from pathlib import Path
import json
h=Path.home()
p=h/'.config/sway/config'; s=p.read_text().replace('swaybg_command -\n',''); p.write_text(s)
p=h/'.config/waybar/config'; data=json.loads(p.read_text())
data['modules-right']=['custom/volume' if x=='pulseaudio#sink' else x for x in data['modules-right']]
data['custom/volume']={'exec':str(h/'.local/bin/waybar-volume'),'return-type':'json','interval':2,'on-click':'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle','on-scroll-up':'wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+','on-scroll-down':'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'}
p.write_text(json.dumps(data,ensure_ascii=False,indent=4)+'\n')
p=h/'.config/waybar/style.css'; p.write_text(p.read_text().replace('#pulseaudio','#custom-volume'))
p=h/'.config/rofi-wallpaper/wallpaper.py'; p.write_text((Path(__import__('os').environ['MOCACCINO_OVERRIDES'])/'wallpaper.py').read_text())
for name in ['sway-session.target','randow-wallpapers.service']:
 p=h/'.config/systemd/user'/name
 s=p.read_text().replace('Wants=awww.service randow-wallpapers.timer','Wants=randow-wallpapers.timer').replace('Requires=awww.service\n','').replace('After=awww.service\n','')
 p.write_text(s)
PY
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -S "$XDG_RUNTIME_DIR/bus" ]]; then
  systemctl --user stop awww.service 2>/dev/null || true
  systemctl --user daemon-reload
  gsettings set org.gnome.desktop.interface gtk-theme Colloid-Dark-Catppuccin
  gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
  gsettings set org.gnome.desktop.interface cursor-theme Vimix-cursors
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  systemd-run --user --unit=mocaccino-wallpaper-thumbnails --collect --quiet nice -n 15 "$HOME/.local/bin/wallpaper-thumbnails" || true
fi
