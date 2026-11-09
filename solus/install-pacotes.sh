#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
export LANG=${LANG:-C.UTF-8}
export LC_ALL=C.UTF-8
sudo -v
pkgs=(
  sway swaybg waybar rofi kitty nautilus firefox pavucontrol
  swayidle swaylock playerctl wlogout light
  pipewire wireplumber
  gnome-keyring network-manager
  grim slurp imagemagick
  tmux neovim papirus-icon-theme sassc
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk polkit-gnome
  qt6-5compat qt6-svg qt6-declarative xorg-server xorg-xwayland
  wl-clipboard mako-notify btop fastfetch starship open-vm-tools
  sddm git curl python3 jq unzip
)
sudo eopkg install -y "${pkgs[@]}"
if ! command -v cliphist >/dev/null; then
  [[ $(uname -m) == x86_64 ]] || { echo "cliphist: arquitetura nao suportada" >&2; exit 1; }
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  curl -fL --retry 3 -o "$work/cliphist" https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64
  install -Dm755 "$work/cliphist" "$HOME/.local/bin/cliphist"
fi
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes Solus instalados."
