#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  lock) exec /usr/bin/swaylock -f -c 303446 ;;
  logout) exec /usr/bin/swaymsg exit ;;
  *) echo 'Uso: session-action.sh lock|logout' >&2; exit 2 ;;
esac
