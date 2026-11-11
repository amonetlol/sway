#!/usr/bin/env bash
set -euo pipefail
RICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$RICE_ROOT/scripts/common.sh" ]]; then source "$RICE_ROOT/scripts/common.sh"; else
  helper="$(mktemp)"; curl -fLsS https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/scripts/common.sh -o "$helper"; source "$helper"; rm -f "$helper"
fi
require_user
resolve_rice
mkdir -p "$HOME/.config" "$HOME/.local/bin"
for src in "$RICE_SOURCE/.config/"*; do
  [[ $(basename "$src") != systemd ]] || continue
  deploy_path "$src" "$HOME/.config/$(basename "$src")"
done
for src in "$RICE_SOURCE/.local/bin/"*; do
  name="$(basename "$src")"; saved="$RICE_WORK/$name.ssh.conf"
  # Os hubs instalados separadamente podem ser mais recentes e manter sessoes ativas.
  case "$name" in
    ssh-hub|ssh-hub.d|term-hub|term-hub.d)
      [[ ! -e "$HOME/.local/bin/$name" && ! -L "$HOME/.local/bin/$name" ]] || continue ;;
  esac
  # Conservar credenciais locais; o pacote distribuido possui somente campos vazios.
  if [[ -d "$src" && -f "$HOME/.local/bin/$name/ssh.conf" ]]; then cp "$HOME/.local/bin/$name/ssh.conf" "$saved"; fi
  deploy_path "$src" "$HOME/.local/bin/$name"
  if [[ -f "$saved" ]]; then install -m600 "$saved" "$HOME/.local/bin/$name/ssh.conf"; fi
  while IFS= read -r -d '' file; do
    [[ $(head -n1 "$file") != '#!'* ]] || chmod +x "$file"
  done < <(find "$HOME/.local/bin/$name" -type f -print0)
done
while IFS= read -r -d '' file; do
  [[ $(head -n1 "$file") != '#!'* ]] || chmod +x "$file"
done < <(find "$HOME/.config/kitty" "$HOME/.config/wlogout" "$HOME/.config/rofi-wallpaper" -type f -print0)
for hub in ssh-hub term-hub; do chmod 700 "$HOME/.local/bin/$hub.d"; chmod 600 "$HOME/.local/bin/$hub.d/ssh.conf"; done
install_wallpaper_units
mkdir -p "$HOME/.config/systemd/user/waybar.service.d"
backup_path "$HOME/.config/systemd/user/waybar.service.d/sway.conf"
install -m644 "$RICE_SOURCE/.config/systemd/user/waybar.service.d/sway.conf" "$HOME/.config/systemd/user/waybar.service.d/sway.conf"
if user_systemd_available; then
  systemctl --user daemon-reload
fi
if user_systemd_available; then
  systemctl --user --no-reload enable waybar.service pipewire.socket pipewire-pulse.socket wireplumber.service
fi
python3 "$RICE_SOURCE/scripts/setup-desktop.py" "$RICE_BACKUP"
bash "$RICE_SOURCE/scripts/install-themes.sh"
log "Configs instaladas. Backups: $RICE_BACKUP"
log 'Selecione Sway Full no SDDM. Saida padrao: Virtual-1 1920x1080; ajuste .config/sway/config em outro monitor.'
