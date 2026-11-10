#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
[[ -d /sys/firmware/efi ]] || { echo "GRUB EFI requer UEFI." >&2; exit 1; }
efi=/boot/efi
[[ -d $efi ]] || efi=/boot
if [[ ! -f $efi/EFI/ubuntu/grubx64.efi ]]; then
  sudo grub-install --target=x86_64-efi --efi-directory="$efi" --bootloader-id=ubuntu
fi
sudo update-grub
log "GRUB atualizado."
