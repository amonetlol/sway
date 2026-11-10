#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z ${SWAYSOCK:-} ]]; then
  sock=$(find "$XDG_RUNTIME_DIR" -name 'sway-ipc.*.sock' 2>/dev/null | head -n 1 || true)
  [[ -n ${sock:-} ]] && export SWAYSOCK=$sock
fi
if [[ -z ${WAYLAND_DISPLAY:-} && -S ${XDG_RUNTIME_DIR}/wayland-1 ]]; then
  export WAYLAND_DISPLAY=wayland-1
fi

power() {
  local verb=$1
  if [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null 2>&1; then
    exec systemctl "$verb"
  fi
  if command -v loginctl >/dev/null 2>&1; then
    exec loginctl "$verb"
  fi
  if command -v 66 >/dev/null 2>&1; then
    exec sudo -n 66 "$verb"
  fi
  echo "Não há comando para $verb" >&2
  exit 1
}

case "${1:-}" in
  lock) exec /usr/bin/swaylock -f -c 303446 ;;
  logout) exec /usr/bin/swaymsg exit ;;
  shutdown) power poweroff ;;
  reboot) power reboot ;;
  *) echo 'Uso: session-action.sh lock|logout|shutdown|reboot' >&2; exit 2 ;;
esac
