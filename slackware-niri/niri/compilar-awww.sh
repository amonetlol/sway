#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CARGO_BUILD_JOBS=1
work=/var/tmp/ff-build/awww
mkdir -p "$work"
tar -xzf /var/tmp/ff-build/awww-0.12.1.tar.gz -C "$work" --strip-components=1
cd "$work"
cargo build --release --locked
install -m 755 target/release/awww /usr/local/bin/awww
install -m 755 target/release/awww-daemon /usr/local/bin/awww-daemon
awww --version
