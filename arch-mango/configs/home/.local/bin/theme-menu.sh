#!/usr/bin/env bash
# Seletor de temas (Super+Shift+T): lista direto os temas do waybar e aplica.
set -euo pipefail

APPLY="$HOME/.local/bin/theme-apply.sh"
list=""
for d in "$HOME"/.config/waybar/*/; do
    if [[ -f "$d/config" ]]; then
        list+="$(basename "$d")"$'\n'
    fi
done

theme=$(printf '%s' "$list" | rofi -dmenu -i -p "Waybar") || exit 0
[[ -n "$theme" ]] && "$APPLY" waybar "$theme"
