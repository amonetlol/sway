#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/gexiv2
mkdir -p "$work/src" "$work/stage"
curl -fL --retry 3 https://download.gnome.org/sources/gexiv2/0.14/gexiv2-0.14.7.tar.xz -o "$work/source.tar.xz"
tar -xf "$work/source.tar.xz" -C "$work/src" --strip-components=1
meson setup "$work/src/build" "$work/src" --prefix=/usr --libdir=lib64 --buildtype=release
ninja -C "$work/src/build" -j2
DESTDIR="$work/stage" meson install -C "$work/src/build" --no-rebuild
(cd "$work/stage"; makepkg -l y -c y "$work/gexiv2-0.14.7-x86_64-1ff.txz")
installpkg "$work/gexiv2-0.14.7-x86_64-1ff.txz"
ldconfig
