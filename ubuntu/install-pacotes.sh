#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo apt-get update
sudo apt-get install -y \
  sway swaybg waybar rofi kitty nautilus firefox pavucontrol \
  mako swayidle swaylock playerctl wl-clipboard wlogout \
  pipewire pipewire-pulse wireplumber \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  gnome-keyring network-manager \
  grim slurp libnotify-bin imagemagick xwayland \
  tmux neovim papirus-icon-theme sassc gnome-themes-extra adwaita-icon-theme \
  fonts-font-awesome fontconfig sddm qt6-svg-plugins \
  qml6-module-qtquick qml6-module-qt5compat \
  unzip git curl ca-certificates python3 jq \
  grub-efi-amd64 locales
for pkg in cliphist nwg-look swayosd awww; do
  sudo apt-get install -y "$pkg" && log "Instalado: $pkg" || warn "Pacote ausente no apt: $pkg"
done
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo sed -i 's/^# *\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
sudo locale-gen || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes Ubuntu instalados. Clipboard: cliphist. GTK: nwg-look."
