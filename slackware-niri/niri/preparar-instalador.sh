#!/usr/bin/env bash
# Preparar o ambiente isolado do instalador Slackware e instalar a serie base.
# Executar como root no Manjaro; nao particiona nem formata discos.
set -euo pipefail
root=/mnt/ff-slackware
iso=/mnt/ff-slackware-iso
sandbox=/var/tmp/ff-slackware-installer
[[ $(findmnt -n -o FSROOT --target "$root") == /@slackware ]]
mountpoint -q "$iso"
mkdir -p "$sandbox"
if [[ ! -x "$sandbox/sbin/installpkg" ]]; then
  bsdtar -xpf "$iso/isolinux/initrd.img" -C "$sandbox"
fi
mkdir -p "$sandbox/source" "$sandbox/target"
mountpoint -q "$sandbox/source" || mount --bind "$iso" "$sandbox/source"
mountpoint -q "$sandbox/target" || mount --bind "$root" "$sandbox/target"
chroot "$sandbox" /bin/busybox --install -s /bin
chroot "$sandbox" /bin/bash -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; /sbin/installpkg --root /target /source/slackware64/a/*.txz'
echo FF_SLACKWARE_A_CONCLUIDA
