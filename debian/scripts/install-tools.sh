#!/usr/bin/env bash
set -euo pipefail
work=/opt/sway-debian
mkdir -p "$work"
cd "$work"
ghostty_version=1.3.1-0-ppa2
if ! command -v ghostty >/dev/null; then
 curl -fL --retry 3 "https://github.com/mkasberg/ghostty-ubuntu/releases/download/$ghostty_version/ghostty_1.3.1-0.ppa2_amd64_trixie.deb" -o ghostty.deb
 apt-get install -y --no-install-recommends ./ghostty.deb
fi
if [[ $(cat /etc/debian_version) == */sid ]]; then
 apt-get install -y --no-install-recommends quickshell
 # Use the distro binary, built against the installed Qt.
 if [[ -e /usr/local/bin/quickshell ]]; then
  mv /usr/local/bin/quickshell "$work/quickshell.local.bak-$(date +%Y%m%d-%H%M%S-%N)"
 fi
elif ! command -v quickshell >/dev/null; then
 if [[ ! -d wayland-protocols-1.45 ]]; then
  curl -fL --retry 3 https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/1.45/downloads/wayland-protocols-1.45.tar.xz -o wayland-protocols.tar.xz
  tar -xf wayland-protocols.tar.xz
 fi
 mkdir -p pkgconfig
 printf 'prefix=%s/wayland-protocols-1.45\npkgdatadir=${prefix}\nName: Wayland Protocols\nDescription: Build-only protocols\nVersion: 1.45\n' "$work" >pkgconfig/wayland-protocols.pc
 export PKG_CONFIG_PATH="$work/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
 if [[ ! -d quickshell/.git ]]; then
  git clone --depth 1 --branch v0.3.2 https://github.com/quickshell-mirror/quickshell.git
 fi
 cmake -S quickshell -B quickshell/build -GNinja -DCMAKE_BUILD_TYPE=Release \
   -DCRASH_HANDLER=OFF -DDISTRIBUTOR='Debian local build' -DINSTALL_QML_PREFIX=lib/qt6/qml
 cmake --build quickshell/build --parallel "${BUILD_JOBS:-4}"
 cmake --install quickshell/build
fi
ln -sfn "$(command -v quickshell)" /usr/local/bin/qs
if ! command -v lazygit >/dev/null; then
 url=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | python3 -c 'import json,sys; print(next(a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if a["name"].lower().endswith("linux_x86_64.tar.gz")))')
 curl -fL --retry 3 "$url" -o lazygit.tar.gz
 tar -xzf lazygit.tar.gz lazygit
 install -m755 lazygit /usr/local/bin/lazygit
fi
if ! command -v tree-sitter >/dev/null; then npm install -g tree-sitter-cli; fi
if ! command -v prettier >/dev/null; then npm install -g prettier; fi

# DarkShadow palette generator. Build upstream source rather than copying a host binary.
if [[ ! -x /usr/local/bin/matugen ]]; then
 apt-get install -y --no-install-recommends cargo rustc
 if [[ ! -d matugen-4.2.0/.git ]]; then
  git clone --depth 1 --branch v4.2.0 https://github.com/InioX/matugen.git matugen-4.2.0
 fi
 cargo build --manifest-path "$work/matugen-4.2.0/Cargo.toml" --release --locked --jobs "${BUILD_JOBS:-4}"
 install -m755 "$work/matugen-4.2.0/target/release/matugen" /usr/local/bin/matugen
 install -Dm644 "$work/matugen-4.2.0/LICENSE" /usr/local/share/licenses/matugen/LICENSE
fi
