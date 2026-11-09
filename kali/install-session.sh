#!/usr/bin/env bash
# Mantém o barramento do usuário disponível durante instalações por SSH.
kali_prepare_session() {
  local user uid before
  user=$(id -un); uid=$(id -u)
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$uid}"
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
  KALI_RESTORE_LINGER=0
  before=$(loginctl show-user "$user" -p Linger --value 2>/dev/null || true)
  if [[ $before != yes ]]; then
    sudo loginctl enable-linger "$user"
    KALI_RESTORE_LINGER=1
  fi
  sudo systemctl start "user@$uid.service"
  if [[ ! -S "$XDG_RUNTIME_DIR/bus" ]]; then
    sudo systemctl restart "user@$uid.service"
  fi
  [[ -S "$XDG_RUNTIME_DIR/bus" ]] || { echo "Barramento do usuário indisponível." >&2; return 1; }
}

kali_finish_session() {
  if [[ ${KALI_RESTORE_LINGER:-0} == 1 ]]; then
    sudo loginctl disable-linger "$(id -un)" || true
  fi
}
