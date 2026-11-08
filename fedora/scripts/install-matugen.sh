#!/usr/bin/env bash
set -euo pipefail
# DarkShadow and 2SSk need the matugen 4.x CLI (--source-color-index, --prefer,
# --json); the Fedora package only ships 3.1.0, so build 4.2.0 from the
# official source (GPL-2.0) and install it in /usr/local/bin, like quickshell.
work=/opt/sway-fedora/tools
source_dir="$work/matugen-4.2.0"
mkdir -p "$work"
if [[ ! -d $source_dir/.git ]]; then
 git clone --depth 1 --branch v4.2.0 https://github.com/InioX/matugen.git "$source_dir"
fi
cargo build --release --manifest-path "$source_dir/Cargo.toml"
install -m755 "$source_dir/target/release/matugen" /usr/local/bin/matugen
restorecon /usr/local/bin/matugen
