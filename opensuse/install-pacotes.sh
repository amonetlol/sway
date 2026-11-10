#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo zypper --non-interactive refresh
core=(
  sway swaybg waybar rofi kitty nautilus pavucontrol
  swayidle swaylock playerctl wl-clipboard wlogout
  pipewire pipewire-pulseaudio wireplumber
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk
  gnome-keyring NetworkManager
  grim slurp libnotify-tools ImageMagick
  tmux neovim papirus-icon-theme sassc gnome-themes-extra adwaita-icon-theme
  fontawesome-fonts sddm
  unzip git curl python3 jq
  grub2-x86_64-efi grub2
)
sudo zypper --non-interactive install --no-recommends "${core[@]}"
for pkg in MozillaFirefox firefox cliphist nwg-look swayosd awww mako; do
  sudo zypper --non-interactive install --no-recommends "$pkg" && log "Instalado: $pkg" || warn "Pacote ausente no zypper: $pkg"
done
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes openSUSE instalados."
