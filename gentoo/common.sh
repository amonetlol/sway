#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RICE_SOURCE="${RICE_SOURCE:-$HERE/../sway-full}"
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
[[ $EUID -ne 0 && -f /etc/gentoo-release ]] || { echo 'Execute como usuario comum no Gentoo, com sudo.' >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
