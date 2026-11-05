#!/bin/sh
set -eu
profile=$(readlink -f "$HOME/.config/sway/current")
exec "$profile/scripts/run-shell.sh"
