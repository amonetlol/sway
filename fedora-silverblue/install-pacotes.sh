#!/usr/bin/env bash
set -euo pipefail
[[ -f /run/ostree-booted ]] || { echo 'Este instalador requer Fedora Atomic.' >&2; exit 1; }
sudo rpm-ostree install --allow-inactive --idempotent \
  sway swaybg waybar rofi kitty nautilus pavucontrol mako swayidle swaylock \
  playerctl wl-clipboard wlogout pipewire wireplumber xdg-desktop-portal-wlr \
  xdg-desktop-portal-gtk gnome-keyring NetworkManager grim slurp libnotify \
  ImageMagick xorg-x11-server-Xwayland tmux neovim btop papirus-icon-theme \
  sassc adwaita-icon-theme fontawesome-fonts-all sddm xorg-x11-server-Xorg \
  xorg-x11-xauth qt6-qtsvg qt6-qtdeclarative qt6-qt5compat unzip git curl \
  python3 jq glibc-langpack-pt cliphist eza duf zoxide fastfetch fd-find \
  ripgrep fzf bat brightnessctl
