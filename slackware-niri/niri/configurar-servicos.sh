#!/usr/bin/env bash
# Executar no sistema anfitriao, depois das series n e x do Slackware.
set -euo pipefail
root=/mnt/ff-slackware
[[ $(findmnt -n -o FSROOT --target "$root") == /@slackware ]]
mkdir -p "$root/etc/NetworkManager/system-connections"
install -m 600 /etc/NetworkManager/system-connections/two-ethernet.nmconnection "$root/etc/NetworkManager/system-connections/two-ethernet.nmconnection"
chmod +x "$root/etc/rc.d/rc.networkmanager" "$root/etc/rc.d/rc.sshd" "$root/etc/rc.d/rc.messagebus" "$root/etc/rc.d/rc.elogind"
sed -i 's/^id:3:initdefault:/id:4:initdefault:/' "$root/etc/inittab"
chroot "$root" /bin/bash -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; for group in audio video input wheel plugdev; do getent group "$group" >/dev/null && usermod -a -G "$group" pio; done; visudo -cf /etc/sudoers.d/99-pio-nopasswd'
