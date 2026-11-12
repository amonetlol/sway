#!/usr/bin/env bash
# Execute inside the prepared Manjaro root, with logs captured on the host.
set -euo pipefail
if [[ ! -f /etc/pacman.d/gnupg/pubring.gpg && ! -f /etc/pacman.d/gnupg/pubring.kbx ]]; then
  pacman-key --init
  pacman-key --populate archlinux manjaro
fi
pacman -Syu --noconfirm --needed niri waybar kitty firefox nautilus rofi micro eza duf starship tmux sddm wl-clipboard cliphist xdg-user-dirs xdg-desktop-portal-gnome xdg-desktop-portal-gtk grim slurp swaybg openssh sudo btrfs-progs snapper grub efibootmgr awww swaylock fastfetch polkit-gnome qt5-wayland xwayland-satellite
