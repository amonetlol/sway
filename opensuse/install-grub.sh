#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
[[ -d /sys/firmware/efi ]] || { echo "GRUB EFI requer UEFI." >&2; exit 1; }
if [[ -d /boot/grub2 ]]; then
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
else
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg || sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
log "GRUB do openSUSE atualizado."
