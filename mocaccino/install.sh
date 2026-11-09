#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bash "$here/install-pacotes.sh"
bash "$here/install-modules.sh"
bash "$here/install-extra.sh"
bash "$here/install-thunar.sh"
status=0
bash "$here/install-sway.sh" || status=$?
bash "$here/install-lightdm.sh"
bash "$here/install-debloat.sh"
exit "$status"
