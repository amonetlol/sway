#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "--wipe" ]]; then
    cliphist wipe
    exit 0
fi
sel=$(cliphist list | rofi -dmenu -i -p 'Clipboard') || exit 0
printf '%s\n' "$sel" | cliphist decode | wl-copy