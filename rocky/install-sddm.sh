#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
work=$(mktemp -d); trap 'rm -rf -- "$work"' EXIT
theme=catppuccin-frappe-blue
curl -fLsS --retry 3 https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip -o "$work/theme.zip"
unzip -oq "$work/theme.zip" -d "$work"
test -f "$work/$theme/Main.qml"
sudo install -d /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin
if [[ -d /usr/share/sddm/themes/$theme ]]; then sudo mv "/usr/share/sddm/themes/$theme" "/usr/share/sddm/themes/$theme.bak-$(date +%s)"; fi
sudo cp -a "$work/$theme" /usr/share/sddm/themes/
# EL10 nao tem servidor Xorg. Weston no VMware deixa o ponteiro invisivel.
# O greeter usa o Sway com cursor desenhado no framebuffer.
sudo dnf install -y adwaita-cursor-theme
sudo usermod -aG input sddm || true
getent group video >/dev/null && sudo usermod -aG video sddm || true
cursor=Adwaita
sudo mkdir -p /usr/share/icons/default /etc/sddm /usr/local/bin
printf '[Icon Theme]\nInherits=%s\n' "$cursor" | sudo tee /usr/share/icons/default/index.theme >/dev/null
sudo tee /etc/sddm/sway-greeter.conf >/dev/null <<EOF
output * bg #303446 solid_color
seat * xcursor_theme $cursor 32
EOF
sudo tee /usr/local/bin/sddm-sway-greeter >/dev/null <<EOF
#!/bin/sh
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=pixman
export XCURSOR_THEME=$cursor
export XCURSOR_SIZE=32
exec sway -c /etc/sddm/sway-greeter.conf
EOF
sudo chmod 755 /usr/local/bin/sddm-sway-greeter
printf '[General]\nDisplayServer=wayland\nGreeterEnvironment=XCURSOR_THEME=%s,XCURSOR_SIZE=32,XCURSOR_PATH=/usr/share/icons\n[Wayland]\nCompositorCommand=/usr/local/bin/sddm-sway-greeter\n[Theme]\nCurrent=catppuccin-frappe-blue\nCursorTheme=%s\n[Users]\nRememberLastSession=true\n' "$cursor" "$cursor" | sudo tee /etc/sddm.conf.d/90-sway-full.conf >/dev/null
printf '#!/bin/sh\nexec "$HOME/.local/bin/start-sway-full" "$@"\n' | sudo tee /usr/local/bin/sway-full-session >/dev/null
sudo chmod 755 /usr/local/bin/sway-full-session
cat <<'EOF' | sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
# SDDM e o gerenciador de login; manter somente a entrada Sway.
sudo mkdir -p /var/backups/sddm-sessions
sudo find /usr/share/wayland-sessions /usr/share/xsessions -mindepth 1 -maxdepth 1 -name '*.desktop' ! -name 'sway.desktop' -exec mv {} /var/backups/sddm-sessions/ \; 2>/dev/null || true
for dm in gdm lightdm lxdm sddm-x11; do sudo systemctl disable "$dm" 2>/dev/null || true; done
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
log 'SDDM habilitado para o proximo boot; a sessao atual nao foi interrompida.'
