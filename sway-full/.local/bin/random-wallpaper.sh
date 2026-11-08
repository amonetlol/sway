#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  while IFS= read -r item; do
    case "$item" in WAYLAND_DISPLAY=*) export "$item";; esac
  done < <(systemctl --user show-environment)
fi
[[ -n "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] || { echo 'Sessao Wayland indisponivel' >&2; exit 1; }
wallpaper=${1:-$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)}
[[ -f "$wallpaper" ]] || { echo 'Wallpaper nao encontrado' >&2; exit 1; }
systemctl --user start awww.service
for attempt in {1..30}; do
  awww query >/dev/null 2>&1 && break
  sleep 0.1
done
awww img --transition-type fade --transition-duration 2 "$wallpaper"
printf 'Wallpaper aplicado: %s\n' "$wallpaper"
