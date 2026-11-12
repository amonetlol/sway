#!/usr/bin/env bash
# Preparar Garuda no subvolume ja populado, sem particionar ou mudar NVRAM.
set -euo pipefail
root=/mnt/ff-garuda
[[ $(findmnt -n -o FSROOT --target "$root") == /@garuda ]]
for d in dev proc sys; do
 mkdir -p "$root/$d"
 mountpoint -q "$root/$d" || { mount --rbind "/$d" "$root/$d"; mount --make-rslave "$root/$d"; }
done
mkdir -p "$root/run" "$root/boot/efi" "$root/home/share"
mountpoint -q "$root/run" || mount -t tmpfs -o mode=755 tmpfs "$root/run"
mountpoint -q "$root/boot/efi" || mount --bind /boot/efi "$root/boot/efi"
mountpoint -q "$root/home/share" || mount -o subvol=@shared UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c "$root/home/share"
cp -L /etc/resolv.conf "$root/etc/resolv.conf"
install -d -m 700 "$root/etc/NetworkManager/system-connections" "$root/etc/ssh"
install -m 600 /etc/NetworkManager/system-connections/two-ethernet.nmconnection "$root/etc/NetworkManager/system-connections/two-ethernet.nmconnection"
cp -a /etc/ssh/ssh_host_* "$root/etc/ssh/"
printf 'two-garuda\n' > "$root/etc/hostname"
printf 'LANG=pt_BR.UTF-8\n' > "$root/etc/locale.conf"
printf 'KEYMAP=br-abnt2\n' > "$root/etc/vconsole.conf"
ln -sfn /usr/share/zoneinfo/America/Sao_Paulo "$root/etc/localtime"
cat > "$root/etc/fstab" <<'EOF'
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c / btrfs defaults,subvol=@garuda,compress=zstd 0 0
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c /home btrfs defaults,subvol=@garuda-home,compress=zstd 0 0
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c /home/share btrfs defaults,subvol=@shared,compress=zstd 0 0
UUID=7197-1FDF /boot/efi vfat umask=0077 0 2
EOF
chroot "$root" bash -c 'getent group pio >/dev/null || groupadd -g 1000 pio; id pio >/dev/null 2>&1 || useradd -m -u 1000 -g pio -G wheel,audio,video,input -s /bin/bash pio'
install -d -o 1000 -g 1000 -m 700 "$root/home/pio/.ssh"
install -o 1000 -g 1000 -m 600 /home/pio/.ssh/authorized_keys "$root/home/pio/.ssh/authorized_keys"
install -d -m 755 "$root/etc/sudoers.d"
printf 'pio ALL=(ALL:ALL) NOPASSWD: ALL\n' > "$root/etc/sudoers.d/99-pio-nopasswd"
chmod 440 "$root/etc/sudoers.d/99-pio-nopasswd"
chroot "$root" visudo -cf /etc/sudoers.d/99-pio-nopasswd
sed -i 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' "$root/etc/locale.gen"
chroot "$root" locale-gen
systemctl --root="$root" enable NetworkManager.service
printf 'Base preparada. Senhas e demais pacotes sao etapas separadas.\n'
