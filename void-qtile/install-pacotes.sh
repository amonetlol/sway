#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo xbps-install -Sy -y \
  sway swaybg Waybar rofi kitty nautilus firefox pavucontrol \
  swayidle swaylock playerctl wl-clipboard wlogout \
  pipewire wireplumber \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  gnome-keyring NetworkManager \
  grim slurp libnotify ImageMagick \
  tmux neovim papirus-icon-theme sassc \
  sddm git curl python3 jq unzip \
  grub-x86_64-efi grub \
  dbus elogind
for pkg in cliphist nwg-look swayosd awww mako; do
  sudo xbps-install -y "$pkg" && log "Instalado: $pkg" || warn "Pacote ausente no xbps: $pkg"
done
sudo ln -sfn /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
log "Pacotes Void instalados. Serviços de usuário usam o fallback do sway-session-init, sem systemd."
