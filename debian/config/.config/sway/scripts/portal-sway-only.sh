#!/usr/bin/env bash
# D-Bus activation must not start the WLR portal in another desktop.
case ":${XDG_CURRENT_DESKTOP,,}:" in
 *:sway:*) ;;
 *) exit 1 ;;
esac
exec /usr/bin/pgrep -u "$(id -u)" -x sway >/dev/null
