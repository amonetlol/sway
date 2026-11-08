#!/usr/bin/env bash
set -euo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
for installer in install-pacotes.sh install-sway_configs.sh install-personal_configs.sh; do
 bash "$base/$installer" "$@"
done
