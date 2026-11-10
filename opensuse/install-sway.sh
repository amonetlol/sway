#!/usr/bin/env bash
# As configs vêm do sway-full. Não há cópia própria nesta pasta.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/../sway-full/install-sway.sh" ]] || { echo "Não encontrei sway-full." >&2; exit 1; }
bash "$here/../sway-full/install-sway.sh"
