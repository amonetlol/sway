#!/bin/sh
wallpaper="$1"
if [ -z "$wallpaper" ]; then
 wallpaper=$(find -L "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
fi
[ -f "$wallpaper" ] || exit 1
exec xwallpaper --zoom "$wallpaper"
