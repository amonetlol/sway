#!/usr/bin/env bash
set -euo pipefail
dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
choice=$(cliphist list | rofi -config "$dir/config.rasi" -dmenu -p Clipboard) || exit 0
[[ -n "$choice" ]] && printf '%s' "$choice" | cliphist decode | wl-copy
