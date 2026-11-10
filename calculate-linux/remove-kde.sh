#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Apenas pacotes KDE de aplicativos/Plasma; Portage protege dependencias ainda necessarias.
mapfile -t kde_packages < <(qlist -IC | grep -E '^kde-(apps|plasma|misc)/|^(app-office/libreoffice|media-gfx/gimp|media-sound/qastools|media-sound/strawberry|media-video/smplayer|net-irc/konversation|net-p2p/ktorrent|sys-block/partitionmanager|gui-apps/xwaylandvideobridge)$' || true)
if ((${#kde_packages[@]})); then
  sudo emerge --depclean "${kde_packages[@]}"
fi
