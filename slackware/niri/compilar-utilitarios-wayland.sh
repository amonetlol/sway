#!/usr/bin/env bash
# Executar dentro do Slackware, apos instalar suas dependencias.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/share/pkgconfig
work=/var/tmp/ff-build/desktop
mkdir -p "$work"
build() {
 local name=$1 version=$2 url=$3; shift 3
 local src="$work/$name-src" stage="$work/$name-stage" pkg="$work/$name-$version-x86_64-1ff.txz"
 mkdir -p "$src" "$stage"
 curl -fL --retry 3 "$url" -o "$work/$name.tar.gz"
 tar -xf "$work/$name.tar.gz" -C "$src" --strip-components=1
 meson setup "$src/build" "$src" --prefix=/usr --libdir=lib64 --sysconfdir=/etc --buildtype=release -Db_lto=false -Dwerror=false "$@"
 ninja -C "$src/build" -j2
 DESTDIR="$stage" meson install -C "$src/build" --no-rebuild
 (cd "$stage"; makepkg -l y -c y "$pkg")
 installpkg "$pkg"
 ldconfig
}
build wl-clipboard 2.2.1 https://github.com/bugaevc/wl-clipboard/archive/refs/tags/v2.2.1.tar.gz
build swaylock 1.8.6 https://github.com/swaywm/swaylock/archive/refs/tags/v1.8.6.tar.gz -Dman-pages=disabled
build grim 1.5.0 https://gitlab.freedesktop.org/emersion/grim/-/archive/v1.5.0/grim-v1.5.0.tar.gz
build slurp 1.5.0 https://github.com/emersion/slurp/archive/refs/tags/v1.5.0.tar.gz -Dman-pages=disabled
