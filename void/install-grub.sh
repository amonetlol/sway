#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
[[ -d /sys/firmware/efi ]] || { echo "GRUB EFI requer UEFI." >&2; exit 1; }
efi=/boot/efi
[[ -d $efi ]] || efi=/boot
if [[ ! -f $efi/EFI/void/grubx64.efi && ! -f $efi/EFI/BOOT/BOOTX64.EFI ]]; then
  sudo grub-install --target=x86_64-efi --efi-directory="$efi" --bootloader-id=void
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg
log "GRUB do Void atualizado."
