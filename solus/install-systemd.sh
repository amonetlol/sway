#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
sudo systemctl enable sddm.service
sudo systemctl set-default graphical.target
if [[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]]; then
  sudo systemctl enable --now vmtoolsd.service
fi
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -S $XDG_RUNTIME_DIR/bus ]]; then
  systemctl --user daemon-reload || true
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service || true
  systemctl --user enable waybar.service randow-wallpapers.timer caffeine.service || true
fi
log "systemd: SDDM no boot e serviços de usuário do Sway habilitados."
