#!/usr/bin/env bash
# Troca o wallpaper aleatorio no Niri (awww). Adaptado do random-wallpaper original (sem systemd --user).
set -euo pipefail

wallpaper_dir="$HOME/Imagens/wallpapers"
[[ -d "$wallpaper_dir" ]] || exit 0
wallpaper=$(find -L "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
[[ -n "$wallpaper" ]] || exit 0

[[ -n "${WAYLAND_DISPLAY:-}" ]] || { echo "random-wallpaper: WAYLAND_DISPLAY ausente" >&2; exit 1; }
if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 < /dev/null &
    for attempt in $(seq 1 30); do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi
awww img "$wallpaper"
printf 'random-wallpaper: imagem=%s\n' "$wallpaper"
# fim
