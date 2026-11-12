#!/usr/bin/env bash
# Executar como root a partir do Manjaro apos instalar as series do Slackware.
set -euo pipefail
root=/mnt/ff-slackware
[[ $(findmnt -n -o FSROOT --target "$root") == /@slackware ]]
for d in dev proc sys; do
 mkdir -p "$root/$d"
 mountpoint -q "$root/$d" || { mount --rbind "/$d" "$root/$d"; mount --make-rslave "$root/$d"; }
done
mkdir -p "$root/boot/efi" "$root/home/share" "$root/etc/ssh" "$root/etc/sudoers.d"
mountpoint -q "$root/boot/efi" || mount --bind /boot/efi "$root/boot/efi"
mountpoint -q "$root/home/share" || mount -o subvol=@shared UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c "$root/home/share"
cp -L /etc/resolv.conf "$root/etc/resolv.conf"
cp -a /etc/ssh/ssh_host_* "$root/etc/ssh/"
printf 'two-slackware\n' > "$root/etc/HOSTNAME"
ln -sfn /usr/share/zoneinfo/America/Sao_Paulo "$root/etc/localtime"
cat > "$root/etc/fstab" <<'EOF'
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c / btrfs defaults,subvol=@slackware,compress=zstd 0 0
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c /home btrfs defaults,subvol=@slackware-home,compress=zstd 0 0
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c /home/share btrfs defaults,subvol=@shared,compress=zstd 0 0
UUID=7197-1FDF /boot/efi vfat umask=0077 0 2
tmpfs /dev/shm tmpfs defaults,nosuid,nodev,mode=1777 0 0
EOF
chroot "$root" /bin/bash -c 'export PATH=/bin:/sbin:/usr/bin:/usr/sbin; getent group pio >/dev/null || groupadd -g 1000 pio; id pio >/dev/null 2>&1 || useradd -m -u 1000 -g pio -s /bin/bash pio'
install -d -o 1000 -g 1000 -m 700 "$root/home/pio/.ssh"
install -o 1000 -g 1000 -m 600 /home/pio/.ssh/authorized_keys "$root/home/pio/.ssh/authorized_keys"
printf 'pio ALL=(ALL:ALL) NOPASSWD: ALL\n' > "$root/etc/sudoers.d/99-pio-nopasswd"
chmod 440 "$root/etc/sudoers.d/99-pio-nopasswd"
printf 'export LANG=pt_BR.UTF-8\n' > "$root/etc/profile.d/lang-local.sh"
chmod 755 "$root/etc/profile.d/lang-local.sh"
echo 'Base configurada; senha, rede, servi?os e boot ainda pendentes.'
