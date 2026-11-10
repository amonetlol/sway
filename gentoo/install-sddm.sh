#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
work=$(mktemp -d); trap 'rm -rf -- "$work"' EXIT
theme=catppuccin-frappe-blue
curl -fLsS --retry 3 https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip -o "$work/theme.zip"
unzip -oq "$work/theme.zip" -d "$work"
test -f "$work/$theme/Main.qml"
sudo install -d /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/local/share/wayland-sessions /usr/local/share/xsessions
if [[ -d /usr/share/sddm/themes/$theme ]]; then sudo mv "/usr/share/sddm/themes/$theme" "/usr/share/sddm/themes/$theme.bak-$(date +%s)"; fi
sudo cp -a "$work/$theme" /usr/share/sddm/themes/
printf '[Theme]\nCurrent=catppuccin-frappe-blue\n[Users]\nRememberLastSession=true\n[Wayland]\nSessionDir=/usr/local/share/wayland-sessions\n[X11]\nSessionDir=/usr/local/share/xsessions\n' | sudo tee /etc/sddm.conf.d/90-sway-full.conf >/dev/null
printf '#!/bin/sh\nexec "$HOME/.local/bin/start-sway-full" "$@"\n' | sudo tee /usr/local/bin/sway-full-session >/dev/null
sudo chmod 755 /usr/local/bin/sway-full-session
cat <<'EOF' | sudo tee /usr/local/share/wayland-sessions/sway.desktop >/dev/null
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
sudo systemctl enable --force sddm.service
sudo systemctl set-default graphical.target
log 'SDDM habilitado para o proximo boot; a sessao atual nao foi interrompida.'
