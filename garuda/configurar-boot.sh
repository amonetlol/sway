#!/usr/bin/env bash
# Executar dentro do Garuda: GRUB proprio, sem alterar a ordem da UEFI.
set -euo pipefail
sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
if ! grep -q 'FF_IGNORE_OTHER_DISTROS' /etc/default/grub-btrfs/config; then
 printf '\n# FF_IGNORE_OTHER_DISTROS\nGRUB_BTRFS_IGNORE_PREFIX_PATH+=("@snapshots-endeavouros" "@snapshots-calamaro" "@snapshots-chimera" "@snapshots-redcore" "@snapshots-calculate" "@snapshots-manjaro" "@snapshots-slackware")\n' >> /etc/default/grub-btrfs/config
fi
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=garuda --no-nvram
grub-mkconfig -o /boot/grub/grub.cfg
grub-script-check /boot/grub/grub.cfg
