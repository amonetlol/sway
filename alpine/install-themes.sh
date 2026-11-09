#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
sudo() { doas "$@"; }
export -f sudo
bash "$here/../sway-full/scripts/install-themes.sh"
