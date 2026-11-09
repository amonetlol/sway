#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
sudo tee /etc/dinit.d/vmtoolsd >/dev/null <<'EOF'
type = process
command = /usr/bin/vmtoolsd
depends-on = local.target
smooth-recovery = true
logfile = /var/log/dinit/vmtoolsd.log
EOF
for service in dbus logind NetworkManager sshd cronie vmtoolsd sddm; do
  if [[ -e /etc/dinit.d/boot.d/$service ]]; then
    sudo dinitctl start "$service"
  else
    sudo dinitctl enable "$service"
  fi
done
if [[ $(findmnt -no FSTYPE /) == btrfs ]]; then
  if ! sudo snapper -c root get-config >/dev/null 2>&1; then sudo snapper -c root create-config /; fi
  sudo snapper -c root set-config NUMBER_LIMIT=6 NUMBER_LIMIT_IMPORTANT=6 TIMELINE_CREATE=no
  printf '17 * * * * root /usr/bin/snapper -c root cleanup number\n' | sudo tee /etc/cron.d/sway-snapper-cleanup >/dev/null
fi
printf 'vmware\tinstalled-dinit\n' >> "$state/modules.tsv"
log 'dinit: SDDM, rede, SSH, elogind e VMware habilitados.'
