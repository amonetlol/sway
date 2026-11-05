#!/usr/bin/env bash
set -euo pipefail
mode=${1:-menu}
if [[ "$mode" == menu ]]; then
 selected=$(printf '%s\n' 'Tela inteira' 'Selecionar área' 'Janela ativa' | rofi -no-config -dmenu -no-custom -format i -p Captura -theme "$HOME/.config/sway/current/rofi/main.rasi") || exit 0
 case "$selected" in 0) mode=full ;; 1) mode=area ;; 2) mode=window ;; *) exit 0 ;; esac
fi
args=()
case "$mode" in
 full|full-clipboard) ;;
 area|area-clipboard) area=$(slurp) || exit 0; args=(-g "$area") ;;
 window|window-clipboard)
  area=$(swaymsg -t get_tree | jq -er '.. | objects | select(.focused? == true and (.type == "con" or .type == "floating_con")) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | head -1)
  args=(-g "$area") ;;
 *) exit 2 ;;
esac
if [[ "$mode" == *-clipboard ]]; then
 grim "${args[@]}" - | wl-copy
else
 mkdir -p "$HOME/Pictures/Screenshots"
 image="$HOME/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"
 grim "${args[@]}" "$image"
 notify-send Captura "$image"
fi
