#!/bin/sh
log="$HOME/.local/state/sway-themes/config-errors.txt"
cat > "$log"
exec /usr/bin/swaynag "$@" < "$log"
