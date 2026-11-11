#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
theme=catppuccin-frappe-blue
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
curl -fL --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
[[ -f "$work/theme/$theme/Main.qml" ]] || { echo "Tema SDDM sem Main.qml." >&2; exit 1; }
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions
if [[ -e /usr/share/sddm/themes/$theme ]]; then
  sudo mkdir -p /var/backups/sway-opensuse-sddm
  sudo mv "/usr/share/sddm/themes/$theme" "/var/backups/sway-opensuse-sddm/$theme-$(date +%Y%m%d-%H%M%S)-$$"
fi
sudo cp -a "$work/theme/$theme" /usr/share/sddm/themes/
sudo tee /etc/sddm.conf.d/90-sway-full.conf >/dev/null <<'EOF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=catppuccin-frappe-blue
CursorTheme=Vimix-cursors
CursorSize=24
[Users]
RememberLastSession=true
EOF
if [[ -f /etc/sddm.conf ]]; then
  sudo sed -i 's/^Current=.*/Current=catppuccin-frappe-blue/' /etc/sddm.conf
fi
sudo tee /usr/local/bin/sway-full-session >/dev/null <<'EOF'
#!/bin/sh
if [ -x "$HOME/.local/bin/start-sway-full" ]; then exec "$HOME/.local/bin/start-sway-full" "$@"; fi
exec /usr/bin/sway "$@"
EOF
sudo tee /usr/share/wayland-sessions/sway-full.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
sudo mkdir -p /usr/local/share/sddm/sway-sessions /usr/local/share/sddm/empty-xsessions
sudo cp /usr/share/wayland-sessions/sway-full.desktop /usr/local/share/sddm/sway-sessions/sway.desktop
sudo tee /etc/sddm.conf.d/96-sway-session.conf >/dev/null <<'EOF'
[Wayland]
SessionDir=/usr/local/share/sddm/sway-sessions
[X11]
SessionDir=/usr/local/share/sddm/empty-xsessions
EOF
sudo chmod 755 /usr/local/bin/sway-full-session
for dm in gdm gdm3 lightdm lxdm; do
  if systemctl is-enabled "$dm.service" >/dev/null 2>&1; then sudo systemctl disable "$dm.service"; fi
done
sudo systemctl enable --force sddm.service
sudo systemctl set-default graphical.target
log "SDDM habilitado com Catppuccin Frappe Blue."
