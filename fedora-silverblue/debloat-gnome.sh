#!/usr/bin/env bash
set -euo pipefail
[[ -f /run/ostree-booted ]] || { echo 'Este instalador requer Fedora Atomic.' >&2; exit 1; }
# Nao remove bibliotecas GNOME usadas por Nautilus e aplicativos GTK.
sudo rpm-ostree override remove \
  gdm gnome-browser-connector gnome-classic-session gnome-initial-setup \
  gnome-session gnome-session-wayland-session gnome-shell gnome-shell-common \
  gnome-shell-extension-apps-menu gnome-shell-extension-background-logo \
  gnome-shell-extension-common gnome-shell-extension-launch-new-instance \
  gnome-shell-extension-places-menu gnome-shell-extension-window-list "$@"
