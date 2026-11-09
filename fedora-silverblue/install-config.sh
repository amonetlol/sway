#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RICE_ROOT="$here/../sway-full"
source "$RICE_ROOT/scripts/common.sh"
require_user
resolve_rice
mkdir -p "$HOME/.config" "$HOME/.local/bin"
for src in "$RICE_SOURCE/.config/"*; do
  [[ $(basename "$src") != systemd ]] || continue
  deploy_path "$src" "$HOME/.config/$(basename "$src")"
done
for src in "$RICE_SOURCE/.local/bin/"*; do
  name="$(basename "$src")"; saved="$RICE_WORK/$name.ssh.conf"
  if [[ -d "$src" && -f "$HOME/.local/bin/$name/ssh.conf" ]]; then cp "$HOME/.local/bin/$name/ssh.conf" "$saved"; fi
  deploy_path "$src" "$HOME/.local/bin/$name"
  if [[ -f "$saved" ]]; then install -m600 "$saved" "$HOME/.local/bin/$name/ssh.conf"; fi
done
find "$HOME/.local/bin" "$HOME/.config/wlogout" -type f -exec sh -c 'for f do [ "$(head -c 2 "$f")" != "#!" ] || chmod +x "$f"; done' sh {} +
for hub in ssh-hub term-hub; do chmod 700 "$HOME/.local/bin/$hub.d"; chmod 600 "$HOME/.local/bin/$hub.d/ssh.conf"; done
install_wallpaper_units
mkdir -p "$HOME/.config/systemd/user/waybar.service.d"
backup_path "$HOME/.config/systemd/user/waybar.service.d/sway.conf"
install -m644 "$RICE_SOURCE/.config/systemd/user/waybar.service.d/sway.conf" "$HOME/.config/systemd/user/waybar.service.d/sway.conf"
python3 "$RICE_SOURCE/scripts/setup-desktop.py" "$RICE_BACKUP"
# loginctl nao possui poweroff nem reboot.
sed -i -e 's@/usr/bin/loginctl poweroff@/usr/bin/systemctl poweroff@' -e 's@/usr/bin/loginctl reboot@/usr/bin/systemctl reboot@' "$HOME/.config/wlogout/layout"
# O repositorio Fedora nao fornece swayosd ou awww; preservar teclas e wallpaper.
python3 - "$HOME/.config/sway/config" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]); s=p.read_text()
s=s.replace('swayosd-client --output-volume raise 5','pactl set-sink-volume @DEFAULT_SINK@ +5%').replace('swayosd-client --output-volume lower 5','pactl set-sink-volume @DEFAULT_SINK@ -5%').replace('swayosd-client --output-volume mute-toggle','pactl set-sink-mute @DEFAULT_SINK@ toggle').replace('swayosd-client --input-volume mute-toggle','pactl set-source-mute @DEFAULT_SOURCE@ toggle').replace('swayosd-client --brightness raise 5','brightnessctl set +5%').replace('swayosd-client --brightness lower 5','brightnessctl set 5%-').replace('    bindsym --release Caps_Lock exec swayosd-client --caps-lock','').replace('exec swayosd-server','')
p.write_text(s)
PY
sed -i 's/Wants=awww.service randow-wallpapers.timer/Wants=randow-wallpapers.timer/' "$HOME/.config/systemd/user/sway-session.target"
sed -i '/^Requires=awww.service$/d; /^After=awww.service$/d' "$HOME/.config/systemd/user/randow-wallpapers.service"
sed -i '/systemctl --user restart awww.service/d' "$HOME/.local/bin/sway-session-init"
install -m755 "$here/random-wallpaper.sh" "$HOME/.local/bin/random-wallpaper.sh"
if user_systemd_available; then systemctl --user daemon-reload; fi
log "Configuracao instalada; backups em $RICE_BACKUP."
