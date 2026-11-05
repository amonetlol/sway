#!/usr/bin/env bash
# Shared argument handling; source from an installer.
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
target=${SUDO_USER:-${USER:-}}
if [[ ${1:-} == --user ]]; then target=${2:?Informe o usuário}; shift 2; fi
[[ $# == 0 ]] || { echo "Uso: bash $0 [--user USUARIO]" >&2; exit 2; }
[[ -n "$target" && "$target" != root ]] || { echo 'Informe --user USUARIO.' >&2; exit 1; }
id "$target" >/dev/null
target_home=$(getent passwd "$target" | cut -d: -f6)
. /etc/os-release
[[ $ID == debian && ( ${VERSION_ID:-} == 13 || $(cat /etc/debian_version) == */sid ) ]] || { echo 'Requer Debian 13 ou Sid.' >&2; exit 1; }
require_root() {
 [[ $EUID == 0 ]] || { echo 'Execute como root ou com sudo.' >&2; exit 1; }
 export DEBIAN_FRONTEND=noninteractive LC_ALL=C
 backup="/var/backups/sway-debian/$(date +%Y%m%d-%H%M%S-%N)"
 mkdir -p "$backup"
}
stage_installer() {
 stage=/opt/sway-debian/installer
 mkdir -p "$stage"
 if [[ $(readlink -f "$base") != $(readlink -f "$stage") ]]; then cp -a "$base/." "$stage/"; fi
 chmod -R a+rX "$stage"
}
