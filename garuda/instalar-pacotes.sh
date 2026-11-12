#!/usr/bin/env bash
# Executar dentro do Garuda preparado. Usa os repositorios originais.
set -euo pipefail
pacman -Syu --noconfirm --needed sway waybar kitty firefox nautilus rofi micro eza duf starship tmux sddm wl-clipboard cliphist xdg-user-dirs xdg-desktop-portal-wlr xdg-desktop-portal-gtk grim slurp swaylock swaybg awww polkit-gnome fastfetch openssh sudo btrfs-progs snapper grub dracut swayidle swayosd mako open-vm-tools gnome-keyring xorg-xwayland fd
