#!/usr/bin/env bash
# Biblioteca isolada para o Niri, sem substituir a versao do Slackware.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/libdisplay-info-0.3
mkdir -p "$work"
curl -fL --retry 3 https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/0.3.0/libdisplay-info-0.3.0.tar.gz -o /var/tmp/ff-build/libdisplay-info-0.3.tar.gz
tar -xf /var/tmp/ff-build/libdisplay-info-0.3.tar.gz -C "$work" --strip-components=1
rm -rf "$work/build"
meson setup "$work/build" "$work" --prefix=/usr/local/ff-niri-compat --libdir=lib64 --buildtype=release
ninja -C "$work/build" -j2
meson install -C "$work/build" --no-rebuild
