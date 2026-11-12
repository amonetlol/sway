#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
mountdir=$(mktemp -d /run/ff-slack-snap.XXXXXX)
cleanup() { mountpoint -q "$mountdir" && umount "$mountdir"; rmdir "$mountdir"; }
trap cleanup EXIT
mount -t btrfs -o subvolid=5 UUID=a6e547bd-93fe-4789-8f03-4a8ac451517c "$mountdir"
store="$mountdir/@snapshots-slackware"
btrfs subvolume snapshot -r "$mountdir/@slackware" "$store/auto-$(date +%Y%m%d-%H%M%S)"
mapfile -t snapshots < <(for path in "$store"/auto-*; do [ -d "$path" ] && basename "$path"; done | sort -r)
for ((i=4; i<${#snapshots[@]}; i++)); do btrfs subvolume delete "$store/${snapshots[i]}"; done
