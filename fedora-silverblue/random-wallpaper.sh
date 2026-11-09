#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  while IFS= read -r item; do case "$item" in WAYLAND_DISPLAY=*) export "$item";; esac; done < <(systemctl --user show-environment 2>/dev/null || true)
fi
[[ -n "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] || exit 1
wallpaper=${1:-$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)}
[[ -f "$wallpaper" ]] || exit 1
escaped=${wallpaper//\\/\\\\}
escaped=${escaped//\"/\\\"}
swaymsg "output * background \"$escaped\" fill" >/dev/null
