#!/bin/sh
set -eu
base="$HOME/.config/sway/themes/DarkShadow/cache/rice"
mkdir -p "$base"
case "${1:-settings}" in settings|wallpaper) date +%s%N > "$base/$1-open";; *) exit 2;; esac
