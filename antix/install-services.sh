#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -n true
write_66() {
  local name="$1" exec_line="$2"
  sudo tee "/usr/share/66/service/$name" >/dev/null <<EOF
[Main]
Type = classic
Version = 0.0.1
Description = "$name"
User = ( root )

[Start]
Execute = ( $exec_line )
EOF
  sudo 66 parse "$name"
  sudo 66 enable "$name"
}
sudo install -d /usr/share/66/service
if [[ -x /usr/libexec/elogind ]]; then
  write_66 elogind /usr/libexec/elogind
fi
write_66 sddm /usr/bin/sddm
if [[ -x /usr/bin/vmtoolsd ]]; then
  write_66 vmtoolsd /usr/bin/vmtoolsd
fi
if ! [[ -x /usr/bin/seatd ]]; then
  sudo 66 disable seatd >/dev/null 2>&1 || true
fi
sudo 66 disable slimski >/dev/null 2>&1 || true
log "66: SDDM habilitado. slimski desativado. connman permanece na rede."
