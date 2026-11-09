#!/bin/sh
set -eu
state="$HOME/.local/state/sway-freebsd"
mkdir -p "$state" "$HOME/.cache/sway-freebsd-modules"
for name in bash bin btop fastfetch fonts starship foot wallpapers recovery-shortcuts; do
 script="$HOME/.cache/sway-freebsd-modules/$name.sh"
 curl -fsSL --retry 3 "https://raw.githubusercontent.com/amonetlol/sh/main/modules/$name.sh" -o "$script"
 bash "$script"
 printf '%s\n' "$name" >> "$state/modules-completed"
done
