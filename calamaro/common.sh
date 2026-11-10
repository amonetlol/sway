#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RICE_SOURCE="${RICE_SOURCE:-$HERE/../sway-full}"
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
[[ $EUID -ne 0 && -f /etc/os-release ]] || { echo 'Execute como usuario comum no CalamaroOS, com sudo.' >&2; exit 1; }
[[ -d /etc/calamaroos && $(. /etc/os-release; printf '%s' "$ID") == gentoo ]] || { echo 'Este instalador requer o CalamaroOS (base Gentoo).' >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
# Sudo sem TTY (instalacao via ssh): usa askpass quando fornecido.
if [[ -n ${SUDO_ASKPASS:-} ]]; then
  sudo() { command sudo -A "$@"; }
fi
