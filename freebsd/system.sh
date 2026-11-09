#!/bin/sh
set -eu
sysrc dbus_enable=YES seatd_enable=YES sddm_enable=YES vmware_guest_vmblock_enable=YES
service dbus onestart || true
service seatd onestart || true
pw groupmod video -m pio
mkdir -p /usr/local/etc/sudoers.d /usr/local/share/xsessions /usr/local/etc/sddm.conf.d /var/backups/sway-freebsd-sessions
printf '%%wheel ALL=(ALL:ALL) ALL\n%%wheel ALL=(root) NOPASSWD: /sbin/shutdown -p now, /sbin/shutdown -r now\n' > /usr/local/etc/sudoers.d/sway-freebsd
chmod 440 /usr/local/etc/sudoers.d/sway-freebsd
for dir in /usr/local/share/xsessions /usr/local/share/wayland-sessions; do
 [ -d "$dir" ] || continue
 for f in "$dir"/*.desktop; do [ -f "$f" ] && mv "$f" /var/backups/sway-freebsd-sessions/$(basename "$dir")-$(basename "$f"); done
done
cat > /usr/local/share/xsessions/sway.desktop <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway no FreeBSD com backend X11
Exec=/home/pio/.local/bin/start-sway-freebsd
Type=Application
EOF
cat > /usr/local/etc/sddm.conf.d/90-sway.conf <<'EOF'
[General]
DisplayServer=x11
EOF
