#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
cfg=/boot/grub2/grub.cfg
[[ -f $cfg ]] || cfg=/boot/grub2/grub.cfg
if [[ -d /boot/grub2 ]]; then
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
else
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
log "GRUB do Fedora atualizado. A entrada EFI existente foi preservada."
