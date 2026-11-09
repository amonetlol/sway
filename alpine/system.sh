#!/bin/sh
set -eu
if ! rc-update show boot | grep -q 'udev'; then setup-devd -C udev; fi
for service in dbus elogind sddm; do rc-update add "$service" default || true; done
rc-update add open-vm-tools default || true
mkdir -p /usr/share/wayland-sessions /etc/sddm.conf.d
if [ -f /usr/share/wayland-sessions/sway.desktop ]; then cp -an /usr/share/wayland-sessions/sway.desktop /usr/share/wayland-sessions/sway.desktop.orca-backup; fi
cat > /usr/share/wayland-sessions/sway.desktop <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway Alpine
Exec=/home/pio/.local/bin/start-sway-alpine
Type=Application
EOF
cat > /etc/sddm.conf.d/90-sway.conf <<'EOF'
[General]
DisplayServer=x11
EOF
