#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
export CFLAGS="-O2" CXXFLAGS="-O2" MAKEFLAGS="-j2"
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
mkdir -p "$cache/sources" "$cache/build" "$cache/packages"
package_stage() {
  local name=$1 version=$2 stage=$3
  local pkg="$cache/packages/$name-$version-x86_64-1sway.txz"
  (cd "$stage"; sudo /sbin/makepkg -l y -c y "$pkg")
  sudo /sbin/upgradepkg --install-new "$pkg"
  sudo /sbin/ldconfig
}
build() {
  local name=$1 version=$2 url=$3; shift 3
  [[ ! -f /var/lib/pkgtools/packages/$name-$version-x86_64-1sway ]] || { log "Preservado: $name $version"; return; }
  local archive="$cache/sources/$name-$version.tar.gz" src="$cache/build/$name-$version" stage="$cache/build/$name-$version-stage"
  log "Compilando: $name $version (2 jobs)"
  download "$url" "$archive"
  mkdir -p "$src"
  [[ -f $src/meson.build ]] || tar -xf "$archive" -C "$src" --strip-components=1
  if [[ ! -f $src/build/build.ninja ]]; then
    meson setup "$src/build" "$src" --prefix=/usr --libdir=lib64 --sysconfdir=/etc --buildtype=release -Db_lto=false -Dwerror=false "$@"
  fi
  ninja -C "$src/build" -j2
  mkdir -p "$stage"
  DESTDIR="$stage" meson install -C "$src/build" --no-rebuild
  package_stage "$name" "$version" "$stage"
}
build tllist 1.1.0 https://codeberg.org/dnkl/tllist/releases/download/1.1.0/tllist-1.1.0.tar.gz
build fcft 3.3.3 https://codeberg.org/dnkl/fcft/releases/download/3.3.3/fcft-3.3.3.tar.gz -Ddocs=disabled
build foot 1.28.0 https://codeberg.org/dnkl/foot/releases/download/1.28.0/foot-1.28.0.tar.gz -Ddocs=disabled -Dtests=false -Dutmp-backend=none
build sway 1.12 https://github.com/swaywm/sway/archive/refs/tags/1.12.tar.gz -Dman-pages=disabled
build swaybg 1.2.2 https://github.com/swaywm/swaybg/archive/refs/tags/v1.2.2.tar.gz -Dman-pages=disabled
build swayidle 1.8.0 https://github.com/swaywm/swayidle/archive/refs/tags/1.8.0.tar.gz -Dman-pages=disabled -Dlogind=enabled -Dlogind-provider=elogind
build swaylock 1.8.6 https://github.com/swaywm/swaylock/archive/refs/tags/v1.8.6.tar.gz -Dman-pages=disabled
build wl-clipboard 2.2.1 https://github.com/bugaevc/wl-clipboard/archive/refs/tags/v2.2.1.tar.gz
build grim 1.5.0 https://gitlab.freedesktop.org/emersion/grim/-/archive/v1.5.0/grim-v1.5.0.tar.gz
build slurp 1.5.0 https://github.com/emersion/slurp/archive/refs/tags/v1.5.0.tar.gz -Dman-pages=disabled
build mako 1.10.0 https://github.com/emersion/mako/archive/refs/tags/v1.10.0.tar.gz -Dman-pages=disabled -Dsd-bus-provider=libelogind
build wlogout 1.2.2 https://github.com/ArtsyMacaw/wlogout/archive/refs/tags/1.2.2.tar.gz
build rofi 2.1.0 https://github.com/davatorium/rofi/releases/download/2.1.0/rofi-2.1.0.tar.gz -Dwayland=enabled -Dcheck=disabled
build jsoncpp 1.9.6 https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.6.tar.gz -Dtests=false
build Waybar 0.16.0 https://github.com/Alexays/Waybar/archive/refs/tags/0.16.0.tar.gz \
  -Dsystemd=disabled -Dlogind=enabled -Dtests=disabled -Dman-pages=disabled \
  -Dpulseaudio=enabled -Dlibnl=enabled -Ddbusmenu-gtk=disabled \
  -Dmpd=disabled -Dcava=disabled -Dgps=disabled -Djack=disabled -Dsndio=disabled
build xdg-desktop-portal-wlr 0.7.1 https://github.com/emersion/xdg-desktop-portal-wlr/archive/refs/tags/v0.7.1.tar.gz -Dman-pages=disabled -Dsystemd=disabled

# Releases oficiais prontas: nenhuma compilacao Go/Rust para editor, clipboard ou prompt.
download https://github.com/micro-editor/micro/releases/download/v2.0.15/micro-2.0.15-linux64-static.tar.gz "$cache/sources/micro.tar.gz"
mkdir -p "$cache/build/micro"
tar -xf "$cache/sources/micro.tar.gz" -C "$cache/build/micro"
install -m755 "$cache/build/micro/micro-2.0.15/micro" "$HOME/.local/bin/micro"
download https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64 "$cache/sources/cliphist"
install -m755 "$cache/sources/cliphist" "$HOME/.local/bin/cliphist"
download https://github.com/fastfetch-cli/fastfetch/releases/download/2.71.0/fastfetch-linux-amd64.tar.gz "$cache/sources/fastfetch.tar.gz"
mkdir -p "$cache/build/fastfetch"
tar -xf "$cache/sources/fastfetch.tar.gz" -C "$cache/build/fastfetch"
install -m755 "$cache/build/fastfetch/fastfetch-linux-amd64/usr/bin/fastfetch" "$HOME/.local/bin/fastfetch"
if ! command -v subl >/dev/null; then
  sublime_build=$(curl -fsSL https://www.sublimetext.com/updates/4/stable_update_check | python3 -c 'import json,sys; print(json.load(sys.stdin)["latest_version"])')
  download "https://download.sublimetext.com/sublime_text_build_${sublime_build}_x64.tar.xz" "$cache/sources/sublime.tar.xz"
  sublime_stage="$cache/build/sublime-stage"
  mkdir -p "$sublime_stage/opt" "$sublime_stage/usr/bin" "$sublime_stage/usr/share/applications"
  tar -xf "$cache/sources/sublime.tar.xz" -C "$sublime_stage/opt"
  ln -sfn /opt/sublime_text/sublime_text "$sublime_stage/usr/bin/subl"
  cp "$sublime_stage/opt/sublime_text/sublime_text.desktop" "$sublime_stage/usr/share/applications/"
  package_stage sublime-text "$sublime_build" "$sublime_stage"
fi
# playerctl e ferramentas VMware usam os SlackBuilds atuais, com registro em pkgtools.
bash "$here/build-slackbuilds.sh"
log 'Compilacoes concluidas e registradas em pkgtools.'
