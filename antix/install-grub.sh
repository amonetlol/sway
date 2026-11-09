#!/usr/bin/env bash
# Preserva o GRUB EFI já instalado no antiX. Não troca o bootloader.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -n true
[[ -d /sys/firmware/efi ]] || { echo "GRUB EFI requer UEFI." >&2; exit 1; }
if ! findmnt /boot/efi >/dev/null; then
  sudo mount /boot/efi
fi
if ! sudo test -d /boot/efi/EFI/antix && ! sudo test -d /boot/efi/EFI/BOOT; then
  echo "Entrada EFI do antiX ausente. O instalador não reinstala o GRUB." >&2
  exit 1
fi
sudo update-grub
log "GRUB do antiX preservado. Menu atualizado, sem grub-install."
