#!/usr/bin/env bash
# Clipboard: historico do cliphist em rofi, paleta da maquina.
set -euo pipefail
choice=$(cliphist list | rofi -config "$HOME/.config/rofi/config.rasi" -dmenu -i -p Clipboard) || exit 0
[[ -n "$choice" ]] && printf '%s' "$choice" | cliphist decode | wl-copy
