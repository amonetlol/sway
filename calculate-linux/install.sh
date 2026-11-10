#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/common.sh"
for stage in pacotes modules sway sddm services; do
  log "Etapa: $stage"
  bash "$here/install-$stage.sh"
done
bash "$here/verify.sh"
bash "$here/remove-kde.sh"
bash "$here/hide-menu-apps.sh"
bash "$here/verify.sh"
