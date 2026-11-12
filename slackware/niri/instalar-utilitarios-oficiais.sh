#!/usr/bin/env bash
# Utilitarios oficiais x86_64 para o Slackware.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/utilitarios
mkdir -p "$work" /usr/local/bin
curl -fL --retry 3 https://github.com/starship/starship/releases/download/v1.27.0/starship-x86_64-unknown-linux-musl.tar.gz -o "$work/starship.tar.gz"
tar -xzf "$work/starship.tar.gz" -C "$work" starship
install -m 755 "$work/starship" /usr/local/bin/starship
curl -fL --retry 3 https://github.com/eza-community/eza/releases/download/v0.23.5/eza_x86_64-unknown-linux-musl.tar.gz -o "$work/eza.tar.gz"
tar -xzf "$work/eza.tar.gz" -C "$work"
install -m 755 "$work/eza" /usr/local/bin/eza
curl -fL --retry 3 https://github.com/muesli/duf/releases/download/v0.9.1/duf_0.9.1_linux_x86_64.tar.gz -o "$work/duf.tar.gz"
tar -xzf "$work/duf.tar.gz" -C "$work"
install -m 755 "$work/duf" /usr/local/bin/duf
curl -fL --retry 3 https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64 -o "$work/cliphist"
install -m 755 "$work/cliphist" /usr/local/bin/cliphist
for binary in starship eza duf cliphist; do "$binary" --version | head -1 || true; done
