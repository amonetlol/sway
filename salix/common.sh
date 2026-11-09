#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
export PATH="$HOME/.local/bin:$HOME/.bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
[[ $EUID -ne 0 && -f /etc/slackware-version && -x /usr/sbin/slapt-get ]] || {
  echo 'Execute como usuario comum no Salix.' >&2
  exit 1
}
log() { printf '[*] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }
if [[ -n ${INSTALL_SUDO_PASSWORD:-} ]]; then
  export SUDO_ASKPASS="$HOME/.cache/sway-salix/askpass"
  mkdir -p "$(dirname "$SUDO_ASKPASS")"
  printf '#!/bin/sh\nprintf "%%s\\n" "$INSTALL_SUDO_PASSWORD"\n' > "$SUDO_ASKPASS"
  chmod 700 "$SUDO_ASKPASS"
  sudo() { command sudo -A "$@"; }
  export -f sudo
fi
state="$HOME/.local/state/sway-salix"
cache="$HOME/.cache/sway-salix"
mkdir -p "$cache" "$state" "$HOME/.local/bin"
download() {
  [[ ! -s $2 ]] || return 0
  curl -fL --retry 3 --connect-timeout 20 --max-time 300 "$1" -o "$2.part"
  mv "$2.part" "$2"
}
