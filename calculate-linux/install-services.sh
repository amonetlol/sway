#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# O backend de libinput do GURU fornece unidade systemd, nao OpenRC.
if command -v swayosd-libinput-backend >/dev/null; then
  sudo tee /etc/init.d/swayosd-libinput-backend >/dev/null <<'EOF'
#!/sbin/openrc-run
command="/usr/bin/swayosd-libinput-backend"
command_background="yes"
pidfile="/run/${RC_SVCNAME}.pid"
depend() { need dbus; after elogind; }
EOF
  sudo chmod 755 /etc/init.d/swayosd-libinput-backend
  sudo rc-update add swayosd-libinput-backend default
  sudo rc-service swayosd-libinput-backend start
fi
if grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null && [[ -x /etc/init.d/vmware-tools ]]; then
  sudo rc-update add vmware-tools default
  sudo rc-service vmware-tools start
fi
xdg-user-dirs-update
