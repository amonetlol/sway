#!/usr/bin/env bash
# Executar dentro do Slackware; downloads oficiais de Kitty e Micro x86_64.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
work=/var/tmp/ff-build/apps
mkdir -p "$work" /opt/kitty /usr/local/bin /usr/local/share/applications
curl -fL --retry 3 https://github.com/kovidgoyal/kitty/releases/download/v0.49.2/kitty-0.49.2-x86_64.txz -o "$work/kitty.txz"
tar -xJf "$work/kitty.txz" -C /opt/kitty
ln -sfn /opt/kitty/bin/kitty /usr/local/bin/kitty
ln -sfn /opt/kitty/bin/kitten /usr/local/bin/kitten
if [[ -f /opt/kitty/share/applications/kitty.desktop ]]; then cp /opt/kitty/share/applications/kitty.desktop /usr/local/share/applications/kitty.desktop; fi
curl -fL --retry 3 https://github.com/micro-editor/micro/releases/download/v2.0.15/micro-2.0.15-linux64-static.tar.gz -o "$work/micro.tar.gz"
tar -xzf "$work/micro.tar.gz" -C "$work"
install -m 755 "$work/micro-2.0.15/micro" /usr/local/bin/micro
kitty --version
micro -version | head -1
