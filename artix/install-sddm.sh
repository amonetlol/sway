#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
theme=catppuccin-frappe-blue
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
curl -fLsS --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
[[ -f "$work/theme/$theme/Main.qml" ]]
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions
if [[ -e /usr/share/sddm/themes/$theme ]]; then
  sudo mv "/usr/share/sddm/themes/$theme" "/usr/share/sddm/themes/$theme.backup-$(date +%s)"
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
sudo tee /usr/local/bin/sway-full-session >/dev/null <<'EOF'
#!/bin/sh
exec "$HOME/.local/bin/start-sway-full" "$@"
EOF
sudo mkdir -p /var/lib/sway-artix/session-backups
if [[ -f /usr/share/wayland-sessions/sway-full.desktop ]]; then
  sudo mv /usr/share/wayland-sessions/sway-full.desktop "/var/lib/sway-artix/session-backups/sway-full-$(date +%s).desktop"
fi
sudo cp -an /usr/share/wayland-sessions/sway.desktop /var/lib/sway-artix/session-backups/sway.desktop.original
sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue (Artix dinit)
Exec=/usr/local/bin/sway-full-session
Type=Application
EOF
sudo chmod 755 /usr/local/bin/sway-full-session
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "keyboard-br"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbModel" "abnt2"
EndSection
EOF
