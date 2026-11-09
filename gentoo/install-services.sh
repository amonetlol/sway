#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Conservar a rede estatica ja configurada no networkd.
sudo systemctl enable systemd-networkd systemd-resolved sshd
sudo systemctl enable --now vmtoolsd.service
if systemctl list-unit-files --no-legend swayosd-libinput-backend.service | grep -q swayosd-libinput-backend; then
  sudo systemctl enable --now swayosd-libinput-backend.service
fi
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service
sudo localectl set-keymap br-abnt2
sudo localectl set-x11-keymap br abnt2
xdg-user-dirs-update
