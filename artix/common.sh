#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Execute como usuario comum, com sudo.' >&2; exit 1; }
source /etc/os-release
[[ $ID == artix && $(ps -p 1 -o comm=) == dinit ]] || { echo 'Requer Artix com dinit.' >&2; exit 1; }
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
state="$HOME/.local/state/sway-artix"
mkdir -p "$state"
log() { printf '[*] %s\n' "$*"; }
if [[ -n ${SUDO_ASKPASS:-} ]]; then
  sudo() { command sudo -A "$@"; }
  export -f sudo
fi
