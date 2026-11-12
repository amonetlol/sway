#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
[[ $EUID -ne 0 && -f /etc/slackware-version ]] || { echo 'Execute como usuario comum no Slackware.' >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }
if [[ -n ${INSTALL_SUDO_PASSWORD:-} ]]; then
  export SUDO_ASKPASS="$HOME/.cache/sway-slackware/askpass"
  mkdir -p "$(dirname "$SUDO_ASKPASS")"
  printf '#!/bin/sh\nprintf "%%s\\n" "$INSTALL_SUDO_PASSWORD"\n' > "$SUDO_ASKPASS"
  chmod 700 "$SUDO_ASKPASS"
  sudo() { command sudo -A "$@"; }
  export -f sudo
fi
state="$HOME/.local/state/sway-slackware"
cache="$HOME/.cache/sway-slackware"
backup="$state/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$cache" "$state" "$HOME/.local/bin"
download() {
  [[ ! -s $2 ]] || return 0
  curl -4 -fsSL --retry 2 --connect-timeout 15 --max-time 180 --speed-time 30 --speed-limit 1024 "$1" -o "$2.part"
  mv "$2.part" "$2"
}
save_path() {
  if [[ -e $1 || -L $1 ]]; then
    mkdir -p "$backup/$(dirname "${1#"$HOME/"}")"
    cp -a "$1" "$backup/${1#"$HOME/"}"
  fi
}
