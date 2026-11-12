#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
for svc in dbus elogind NetworkManager sddm; do
  if [[ -d /etc/sv/$svc ]]; then
    sudo ln -sfn "/etc/sv/$svc" "/var/service/$svc"
    log "runit: $svc"
  fi
done
if [[ -d /etc/sv/NetworkManager && -L /var/service/dhcpcd ]]; then
  sudo rm -f /var/service/dhcpcd
  log "dhcpcd sai do boot. O processo atual segue até o próximo start; o NetworkManager assume depois."
fi
log "Void não usa systemd. Waybar e awww sobem pelo sway-session-init quando o systemctl não existe."
