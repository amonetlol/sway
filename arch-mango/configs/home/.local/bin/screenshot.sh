#!/usr/bin/env bash
set -euo pipefail
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y%m%d-%H%M%S).png"
case "${1:-region}" in
    full) grim "$file" ;;
    *) geom=$(slurp) || exit 0; grim -g "$geom" "$file" ;;
esac
wl-copy < "$file"