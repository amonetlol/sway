#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
theme=catppuccin-frappe-blue
download https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip "$cache/sddm.zip"
mkdir -p "$cache/sddm"
unzip -oq "$cache/sddm.zip" -d "$cache/sddm"
[[ -f $cache/sddm/$theme/Main.qml ]] || fail 'Tema SDDM sem Main.qml.'
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions
sudo cp -a "$cache/sddm/$theme" /usr/share/sddm/themes/
if [[ -f /etc/sddm.conf ]]; then
  sudo cp -an /etc/sddm.conf /etc/sddm.conf.before-sway-slackware
  sudo sed -i -e "s/^Current=.*/Current=$theme/" -e 's/^InputMethod=.*/InputMethod=/' /etc/sddm.conf
fi
sudo tee /etc/sddm.conf.d/90-sway-full.conf >/dev/null <<EOF
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=$theme
CursorTheme=Vimix-cursors
CursorSize=24
[Users]
RememberLastSession=true
EOF
sudo tee /usr/local/bin/sway-full-session >/dev/null <<'EOF'
#!/bin/sh
exec "$HOME/.local/bin/start-sway-full" "$@"
EOF
sudo chmod 755 /usr/local/bin/sway-full-session
sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway adaptado para Slackware
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
sudo chown root:root /usr/share/wayland-sessions/sway.desktop
sudo chmod 644 /usr/share/wayland-sessions/sway.desktop
sudo mkdir -p /var/lib/sway-slackware/disabled-sessions
for entry in /usr/share/wayland-sessions/labwc.desktop /usr/share/xsessions/xwmconfig.desktop; do
  if [[ -f $entry ]]; then
    sudo mv "$entry" "/var/lib/sway-slackware/disabled-sessions/$(basename "$entry").$(date +%s).bak"
  fi
done
log 'Apenas a sessao Sway disponivel no SDDM.'
