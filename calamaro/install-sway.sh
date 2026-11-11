#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
RICE_ROOT="$RICE_SOURCE"
source "$RICE_SOURCE/scripts/common.sh"
resolve_rice
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/state/sway-calamaro"
for src in "$RICE_SOURCE/.config/"*; do
  case $(basename "$src") in kitty) continue ;; esac
  deploy_path "$src" "$HOME/.config/$(basename "$src")"
done
for src in "$RICE_SOURCE/.local/bin/"*; do
  name=$(basename "$src"); saved="$RICE_WORK/$name.ssh.conf"
  if [[ -d "$src" && -f "$HOME/.local/bin/$name/ssh.conf" ]]; then cp "$HOME/.local/bin/$name/ssh.conf" "$saved"; fi
  deploy_path "$src" "$HOME/.local/bin/$name"
  if [[ -f "$saved" ]]; then install -m600 "$saved" "$HOME/.local/bin/$name/ssh.conf"; fi
done
while IFS= read -r -d '' file; do
  [[ $(head -n1 "$file") != '#!'* ]] || chmod +x "$file"
done < <(find "$HOME/.local/bin" "$HOME/.config/wlogout" "$HOME/.config/rofi-wallpaper" -type f -print0)
for hub in ssh-hub term-hub; do chmod 700 "$HOME/.local/bin/$hub.d"; chmod 600 "$HOME/.local/bin/$hub.d/ssh.conf"; done
python3 "$HERE/adapt-config.py"
python3 "$RICE_SOURCE/scripts/setup-desktop.py" "$RICE_BACKUP"
bash "$RICE_SOURCE/scripts/install-themes.sh"
bash "$HOME/.local/bin/hide-shortcuts"
# Unidades de usuario do rice (systemd nativo do CalamaroOS).
if [[ -S "$XDG_RUNTIME_DIR/bus" ]]; then
  systemctl --user daemon-reload || true
fi
printf 'random-wallpapers\tinstalled\nhide-shortcuts\tinstalled\nrecovery-shortcuts\tinstalled\nthemes\tinstalled\n' >> "$HOME/.local/state/sway-calamaro/modules.tsv"
log 'Rice aplicado. Backups: $RICE_BACKUP'
