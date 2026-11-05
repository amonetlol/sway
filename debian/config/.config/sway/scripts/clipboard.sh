#!/usr/bin/env bash
set -euo pipefail
selected=$(cliphist list | rofi -no-config -dmenu -i -p Clipboard -theme "$HOME/.config/sway/current/rofi/main.rasi") || exit 0
[[ -n "$selected" ]] || exit 0
printf '%s' "$selected" | cliphist decode | wl-copy
