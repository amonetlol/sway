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
build jsoncpp 1.9.6 https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.6.tar.gz -Dtests=false
build rofi 2.1.0 https://github.com/davatorium/rofi/releases/download/2.1.0/rofi-2.1.0.tar.gz -Dwayland=enabled -Dcheck=disabled
build Waybar 0.16.0 https://github.com/Alexays/Waybar/archive/refs/tags/0.16.0.tar.gz -Dsystemd=disabled -Dlogind=enabled -Dtests=disabled -Dman-pages=disabled -Dpulseaudio=enabled -Dlibnl=enabled -Ddbusmenu-gtk=disabled -Dmpd=disabled -Dcava=disabled -Dgps=disabled -Djack=disabled -Dsndio=disabled
