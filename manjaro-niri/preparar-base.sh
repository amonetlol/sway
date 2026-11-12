#!/usr/bin/env bash
# Prepare an already populated Manjaro subvolume from the running TWO system.
# Does not partition disks, format filesystems, update UEFI, or remove applications.
set -euo pipefail
root=/mnt/ff-manjaro
[[ $(findmnt -n -o FSROOT --target "$root") == /@manjaro ]] || { echo 'Unexpected target mount'; exit 1; }
for d in dev proc sys run; do
  mkdir -p "$root/$d"
  mountpoint -q "$root/$d" || { mount --rbind "/$d" "$root/$d"; mount --make-rslave "$root/$d"; }
done
mkdir -p "$root/boot/efi" "$root/home/share"
mountpoint -q "$root/boot/efi" || mount --bind /boot/efi "$root/boot/efi"
mountpoint -q "$root/home/share" || mount -o subvol=@shared UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c "$root/home/share"
cp -L /etc/resolv.conf "$root/etc/resolv.conf"
install -m 600 /etc/NetworkManager/system-connections/two-ethernet.nmconnection "$root/etc/NetworkManager/system-connections/two-ethernet.nmconnection"
cp -a /etc/ssh/ssh_host_* "$root/etc/ssh/"
printf 'two-manjaro\n' > "$root/etc/hostname"
printf 'LANG=pt_BR.UTF-8\n' > "$root/etc/locale.conf"
printf 'KEYMAP=br-abnt2\n' > "$root/etc/vconsole.conf"
ln -sfn /usr/share/zoneinfo/America/Sao_Paulo "$root/etc/localtime"
cat > "$root/etc/fstab" <<'EOF'
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c / btrfs defaults,subvol=@manjaro,compress=zstd 0 0
UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c /home btrfs defaults,subvol=@manjaro-home,compress=zstd 0 0
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
chroot "$root" systemctl enable NetworkManager sshd
printf 'Manjaro base configured; passwords and desktop still required.\n'
