#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wlogout >/dev/null 2>&1; then
  pkill -x wlogout
  exit 0
fi

buttons=4
dimensions=""

if [[ -n "${SWAYSOCK:-}" ]] && command -v swaymsg >/dev/null 2>&1; then
  dimensions=$(swaymsg -r -t get_outputs | jq -er 'map(select(.active)) | (map(select(.focused))[0] // .[0]) | "\(.rect.width) \(.rect.height)"' 2>/dev/null || true)
elif [[ -n "${NIRI_SOCKET:-}" ]] && command -v niri >/dev/null 2>&1; then
  dimensions=$(niri msg --json focused-output | jq -er '.logical | "\(.width) \(.height)"' 2>/dev/null || true)
elif [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
  dimensions=$(hyprctl -j monitors | jq -er '.[] | select(.focused == true) | "\((.width / .scale) | floor) \((.height / .scale) | floor)"' 2>/dev/null || true)
fi

if [[ -z "$dimensions" ]] && command -v xrandr >/dev/null 2>&1; then
  dimensions=$(xrandr --current 2>/dev/null | awk '/ connected/ { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+x[0-9]+/) { split($i, mode, /[x+]/); print mode[1], mode[2]; exit } }' || true)
fi

if [[ -n "$dimensions" ]]; then
  read -r width height <<< "$dimensions"
else
  width=${WLOGOUT_WIDTH:-1600}
  height=${WLOGOUT_HEIGHT:-900}
fi

card_h=$((height / 2))
(( card_h < 240 )) && card_h=240
(( card_h > 500 )) && card_h=500

card_w=$((card_h * 56 / 100))
(( card_w < 200 )) && card_w=200
row_width=$((buttons * card_w))
top=$(((height - card_h) / 2))
left=$(((width - row_width) / 2))
if (( left < 0 )); then
  left=20
  card_w=$(((width - 40) / buttons))
  (( card_w < 80 )) && card_w=80
  row_width=$((buttons * card_w))
  card_h=$((card_w * 100 / 56))
  (( card_h > height - 40 )) && card_h=$((height - 40))
  top=$(((height - card_h) / 2))
fi

protocol=layer-shell
desktop=$(printf '%s %s' "${XDG_CURRENT_DESKTOP:-}" "${XDG_SESSION_DESKTOP:-}" | tr '[:upper:]' '[:lower:]')
case "$desktop" in
  *gnome*|*kde*|*plasma*) protocol=xdg ;;
esac

exec /usr/bin/wlogout --protocol "$protocol" --layout "$HOME/.config/wlogout/layout" --css "$HOME/.config/wlogout/style.css" --buttons-per-row "$buttons" -T "$top" -B "$top" -L "$left" -R "$left"
