#!/bin/sh
set -eu
sysrc dbus_enable=YES seatd_enable=YES sddm_enable=YES vmware_guest_vmblock_enable=YES vmware_guestd_enable=YES
service dbus onestart || true
service seatd onestart || true
service vmware-guestd onestart || true
pw groupmod video -m pio
mkdir -p /usr/local/etc/sudoers.d /usr/local/share/xsessions /usr/local/etc/sddm.conf.d /usr/local/etc/X11/xorg.conf.d /usr/local/share/sddm/themes /var/backups/sway-freebsd-sessions
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
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fLsS --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
theme=catppuccin-frappe-blue
test -f "$work/theme/$theme/Main.qml"
if [ -e "/usr/local/share/sddm/themes/$theme" ]; then
  mv "/usr/local/share/sddm/themes/$theme" "/usr/local/share/sddm/themes/$theme.backup-$(date +%Y%m%d-%H%M%S)"
fi
cp -a "$work/theme/$theme" /usr/local/share/sddm/themes/
cat > /usr/local/etc/sddm.conf.d/90-sway.conf <<'EOF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=catppuccin-frappe-blue
CursorTheme=Vimix-cursors
CursorSize=24
[Users]
RememberLastSession=true
EOF
cat > /usr/local/etc/X11/xorg.conf.d/10-vmware.conf <<'EOF'
Section "Device"
    Identifier "VMware"
    Driver "vmware"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    HorizSync 1-10000
    VertRefresh 1-10000
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "VMware"
    Monitor "Monitor0"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF
