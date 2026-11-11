#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo dnf install -y \
  sway swaybg waybar rofi kitty nautilus firefox pavucontrol \
  mako swayidle swaylock playerctl wl-clipboard wlogout \
  pipewire pipewire-pulseaudio wireplumber \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  gnome-keyring NetworkManager \
  grim slurp libnotify ImageMagick xorg-x11-server-Xwayland \
  tmux neovim btop papirus-icon-theme sassc adwaita-icon-theme \
  fontawesome-fonts-all sddm xorg-x11-server-Xorg xorg-x11-xauth qt6-qtsvg qt6-qtdeclarative qt6-qt5compat \
  unzip git curl python3 jq fuse selinux-policy-targeted policycoreutils \
  grub2-efi-x64 grub2-tools glibc-langpack-pt
for pkg in gnome-themes-extra cliphist nwg-look swayosd awww; do
  if sudo dnf install -y "$pkg"; then
    log "Instalado: $pkg"
  else
    warn "Pacote ausente no dnf: $pkg"
  fi
done
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$here/install-awww.sh"
bash "$here/install-cli.sh"
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes Fedora instalados. Clipboard: cliphist. GTK: nwg-look."
