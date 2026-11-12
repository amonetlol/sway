#!/usr/bin/env bash
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/utilitarios-extra
mkdir -p "$work" /usr/local/bin
curl -fL --retry 3 https://github.com/fastfetch-cli/fastfetch/releases/download/2.71.0/fastfetch-linux-amd64.tar.gz -o "$work/fastfetch.tar.gz"
tar -xzf "$work/fastfetch.tar.gz" -C "$work"
install -m 755 "$work/fastfetch-linux-amd64/usr/bin/fastfetch" /usr/local/bin/fastfetch
curl -fL --retry 3 https://github.com/sharkdp/fd/releases/download/v10.5.2/fd-v10.5.2-x86_64-unknown-linux-musl.tar.gz -o "$work/fd.tar.gz"
tar -xzf "$work/fd.tar.gz" -C "$work"
install -m 755 "$work/fd-v10.5.2-x86_64-unknown-linux-musl/fd" /usr/local/bin/fd
curl -fL --retry 3 https://github.com/junegunn/fzf/releases/download/v0.75.0/fzf-0.75.0-linux_amd64.tar.gz -o "$work/fzf.tar.gz"
tar -xzf "$work/fzf.tar.gz" -C "$work"
install -m 755 "$work/fzf" /usr/local/bin/fzf
for b in fastfetch fd fzf; do "$b" --version | head -1; done
