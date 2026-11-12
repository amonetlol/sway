#!/usr/bin/env bash
# Executar dentro do Slackware. Nao altera a ordem da UEFI.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
mkdir -p /boot/grub
mkinitrd -c -k 7.3.3 -m mptspi -f btrfs -r /dev/sda2 -B -w 5 -o /boot/initrd-7.3.3.gz
cp /boot/initrd-7.3.3.gz /boot/initrd-generic.gz
sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
sed -i 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="rootflags=subvol=@slackware"/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=slackware --no-nvram
grub-mkconfig -o /boot/grub/grub.cfg
grub-script-check /boot/grub/grub.cfg
