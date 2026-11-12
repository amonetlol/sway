#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/polkit-gnome
mkdir -p "$work/src" "$work/stage"
curl -fL --retry 3 https://download.gnome.org/sources/polkit-gnome/0.105/polkit-gnome-0.105.tar.xz -o "$work/source.tar.xz"
tar -xf "$work/source.tar.xz" -C "$work/src" --strip-components=1
cd "$work/src"
./configure --prefix=/usr --libdir=/usr/lib64 --libexecdir=/usr/libexec --sysconfdir=/etc
make -j2
make DESTDIR="$work/stage" install
(cd "$work/stage"; makepkg -l y -c y "$work/polkit-gnome-0.105-x86_64-1ff.txz")
installpkg "$work/polkit-gnome-0.105-x86_64-1ff.txz"
