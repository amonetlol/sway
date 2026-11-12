#!/usr/bin/env bash
# Executar dentro do Manjaro preparado; nao altera a ordem NVRAM.
set -euo pipefail
mkdir -p /boot/grub
if grep -q '^GRUB_DISABLE_OS_PROBER=' /etc/default/grub; then
  sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
else
  printf '\nGRUB_DISABLE_OS_PROBER=true\n' >> /etc/default/grub
fi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=manjaro --no-nvram
grub-mkconfig -o /boot/grub/grub.cfg
grub-script-check /boot/grub/grub.cfg
