#!/usr/bin/env bash
set -euo pipefail
RICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$RICE_ROOT/scripts/common.sh" ]]; then source "$RICE_ROOT/scripts/common.sh"; else
  helper="$(mktemp)"; curl -fLsS https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/scripts/common.sh -o "$helper"; source "$helper"; rm -f "$helper"
fi
require_user
require_arch
sudo -v
if ! pacman -Q sddm >/dev/null 2>&1; then sudo pacman -S --needed --noconfirm sddm; fi
sudo pacman -S --needed --noconfirm qt6-svg qt6-declarative qt6-5compat unzip xorg-server xorg-xauth
theme=catppuccin-frappe-blue
download https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip "$RICE_WORK/theme.zip"
unzip -oq "$RICE_WORK/theme.zip" -d "$RICE_WORK/theme"
[[ -f "$RICE_WORK/theme/$theme/Main.qml" ]] || fail 'O pacote SDDM nao contem Main.qml.'
backup="/var/backups/sway-full-sddm-$(date +%Y%m%d-%H%M%S)-$$"
sudo mkdir -p "$backup" /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions
for file in /usr/local/bin/sway-full-session /usr/share/wayland-sessions/sway-full.desktop; do
  [[ ! -e "$file" ]] || sudo cp -a "$file" "$backup/"
done
if [[ -e "/usr/share/sddm/themes/$theme" ]]; then sudo mv "/usr/share/sddm/themes/$theme" "$backup/$theme"; fi
sudo cp -a "$RICE_WORK/theme/$theme" /usr/share/sddm/themes/
if [[ -f /etc/sddm.conf.d/90-sway-full.conf ]]; then sudo cp -a /etc/sddm.conf.d/90-sway-full.conf "$backup/"; fi
cat >"$RICE_WORK/sddm.conf" <<'EOF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=catppuccin-frappe-blue
[Users]
RememberLastSession=true
EOF
sudo install -m644 "$RICE_WORK/sddm.conf" /etc/sddm.conf.d/90-sway-full.conf
# Um Current antigo no arquivo principal tem precedencia sobre os drop-ins.
if [[ -f /etc/sddm.conf ]]; then
  sudo cp -a /etc/sddm.conf "$backup/"
  sudo sed -i 's/^Current=.*/Current=catppuccin-frappe-blue/' /etc/sddm.conf
fi
cat >"$RICE_WORK/session" <<'EOF'
#!/bin/sh
if [ -x "$HOME/.local/bin/start-sway-full" ]; then exec "$HOME/.local/bin/start-sway-full" "$@"; fi
exec /usr/bin/sway "$@"
EOF
cat >"$RICE_WORK/sway-full.desktop" <<'EOF'
[Desktop Entry]
Name=Sway Full
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
sudo install -m755 "$RICE_WORK/session" /usr/local/bin/sway-full-session
sudo install -m644 "$RICE_WORK/sway-full.desktop" /usr/share/wayland-sessions/sway-full.desktop
for dm in gdm lightdm lxdm; do
  if systemctl is-enabled "$dm.service" >/dev/null 2>&1; then sudo systemctl disable "$dm.service"; fi
done
sudo systemctl enable --force sddm.service
sudo systemctl set-default graphical.target
log 'SDDM habilitado com Catppuccin Frappe Blue. Escolha Sway Full no login.'
log 'O display manager atual nao foi reiniciado. A mudanca vale para o proximo boot.'
