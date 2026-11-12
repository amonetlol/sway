#!/usr/bin/env bash
# Instala series adicionais no subvolume reservado usando o instalador isolado.
set -euo pipefail
sandbox=/var/tmp/ff-slackware-installer
root=/mnt/ff-slackware
[[ $(findmnt -n -o FSROOT --target "$root") == /@slackware ]]
mountpoint -q "$sandbox/target"
mountpoint -q "$sandbox/source"
for series in ap d l n x xap; do
  echo "FF_SLACKWARE_SERIE_INICIO=$series"
  chroot "$sandbox" /bin/bash -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; /sbin/installpkg --root /target /source/slackware64/'"$series"'/*.txz'
  echo "FF_SLACKWARE_SERIE_CONCLUIDA=$series"
done
