#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/../sway-full/scripts/install-themes.sh" ]] || { echo "Não encontrei sway-full/scripts/install-themes.sh." >&2; exit 1; }
bash "$here/../sway-full/scripts/install-themes.sh"
