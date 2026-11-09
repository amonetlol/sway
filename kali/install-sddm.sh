#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -n true
backup="/var/backups/sway-kali-sddm-$(date +%Y%m%d-%H%M%S)-$$"
backup_path() {
  if sudo test -e "$1"; then
    sudo mkdir -p "$backup/$(dirname "${1#/}")"
    sudo cp -a "$1" "$backup/${1#/}"
  fi
}
for file in /etc/X11/default-display-manager /etc/sddm.conf /etc/sddm.conf.d/90-sway-full.conf /etc/sddm.conf.d/95-vmware-software.conf /etc/sddm.conf.d/96-sway-session.conf; do
  backup_path "$file"
done
theme=catppuccin-frappe-blue
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
curl -fL --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
[[ -f "$work/theme/$theme/Main.qml" ]] || { echo "Tema SDDM sem Main.qml." >&2; exit 1; }
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions
backup_path "/usr/share/sddm/themes/$theme"
sudo mkdir -p "/usr/share/sddm/themes/$theme"
sudo cp -a "$work/theme/$theme/." "/usr/share/sddm/themes/$theme/"
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
sudo mkdir -p /usr/local/share/sddm/sway-sessions
sudo find /usr/local/share/sddm/sway-sessions -mindepth 1 -maxdepth 1 -exec rm -rf {} +
sudo cp /usr/share/wayland-sessions/sway-full.desktop /usr/local/share/sddm/sway-sessions/sway.desktop
sudo tee /etc/sddm.conf.d/96-sway-session.conf >/dev/null <<'EOF'
[Wayland]
SessionDir=/usr/local/share/sddm/sway-sessions
EOF
if [[ $(systemd-detect-virt --vm 2>/dev/null || true) == vmware ]]; then
  backup_path /etc/X11/xorg.conf.d/20-vmware-modesetting.conf
  sudo mkdir -p /etc/X11/xorg.conf.d
  sudo tee /etc/X11/xorg.conf.d/20-vmware-modesetting.conf >/dev/null <<'EOF'
Section "Device"
    Identifier "VMware modesetting"
    Driver "modesetting"
    Option "AccelMethod" "none"
EndSection
EOF
  # QT_QUICK_BACKEND=software desenha o greeter, mas o Qt deixa de entregar teclas.
  sudo tee /etc/sddm.conf.d/95-vmware-software.conf >/dev/null <<'EOF'
[General]
GreeterEnvironment=LIBGL_ALWAYS_SOFTWARE=1,LANG=pt_BR.UTF-8,LC_ALL=pt_BR.UTF-8
EOF
fi
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "keyboard-br"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
    Option "XkbModel" "pc105"
EndSection
EOF
printf 'sddm shared/default-x-display-manager select sddm\n' | sudo debconf-set-selections
printf '/usr/bin/sddm\n' | sudo tee /etc/X11/default-display-manager >/dev/null
sudo chmod 755 /usr/local/bin/sway-full-session
for dm in gdm gdm3 lightdm lxdm; do
  if systemctl is-enabled "$dm.service" >/dev/null 2>&1; then sudo systemctl disable "$dm.service"; fi
done
sudo systemctl enable --force sddm.service
sudo systemctl set-default graphical.target
log "SDDM habilitado com uma sessão Sway e tema Catppuccin Frappe Blue."
