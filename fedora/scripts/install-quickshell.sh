#!/usr/bin/env bash
set -euo pipefail
work=/opt/sway-fedora/tools
source_dir="$work/quickshell-0.3.2"
mkdir -p "$work"
if [[ ! -d $source_dir/.git ]]; then
 git clone --depth 1 --branch v0.3.2 https://github.com/quickshell-mirror/quickshell.git "$source_dir"
fi
cmake -S "$source_dir" -B "$source_dir/build" -GNinja \
 -DCMAKE_BUILD_TYPE=Release -DCRASH_HANDLER=OFF \
 -DDISTRIBUTOR='Fedora local build for Sway themes' -DINSTALL_QML_PREFIX=lib64/qt6/qml
cmake --build "$source_dir/build" --parallel "${BUILD_JOBS:-3}"
cmake --install "$source_dir/build"
ln -sfn /usr/local/bin/quickshell /usr/local/bin/qs
restorecon /usr/local/bin/quickshell /usr/local/bin/qs
