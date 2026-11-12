#!/usr/bin/env bash
set -euo pipefail
mountdir=$(mktemp -d /run/ff-snapshots.XXXXXX)
cleanup() { mountpoint -q "$mountdir" && umount "$mountdir"; rmdir "$mountdir"; }
trap cleanup EXIT
mount -t btrfs -o subvolid=5 UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c "$mountdir"
store="$mountdir/@snapshots-calamaro"
btrfs subvolume snapshot -r "$mountdir/@calamaro" "$store/auto-$(date +%Y%m%d-%H%M%S)"
mapfile -t snapshots < <(for path in "$store"/auto-*; do [ -d "$path" ] && basename "$path"; done | sort -r)
for ((i=4; i<${#snapshots[@]}; i++)); do btrfs subvolume delete "$store/${snapshots[i]}"; done
