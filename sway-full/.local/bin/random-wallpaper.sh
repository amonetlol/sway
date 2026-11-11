#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z "${WAYLAND_DISPLAY:-}" ]] && command -v systemctl >/dev/null 2>&1; then
  while IFS= read -r item; do
    case "$item" in WAYLAND_DISPLAY=*) export "$item";; esac
  done < <(systemctl --user show-environment 2>/dev/null || true)
fi
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  for sock in "$XDG_RUNTIME_DIR"/wayland-*; do
    [[ -S "$sock" ]] || continue
    name="$(basename "$sock")"
    [[ "$name" == *awww* ]] && continue
    export WAYLAND_DISPLAY="$name"
    break
  done
fi
[[ -n "${WAYLAND_DISPLAY:-}" && -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]] || { echo 'Sessao Wayland indisponivel' >&2; exit 1; }
wallpaper=${1:-$(find -L "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)}
[[ -f "$wallpaper" ]] || { echo 'Wallpaper nao encontrado' >&2; exit 1; }
if ! command -v systemctl >/dev/null 2>&1 || ! systemctl --user start awww.service 2>/dev/null; then
  if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
  fi
fi
for attempt in {1..30}; do
  awww query >/dev/null 2>&1 && break
  sleep 0.1
done
awww img --transition-type fade --transition-duration 2 "$wallpaper"
printf 'Wallpaper aplicado: %s\n' "$wallpaper"
