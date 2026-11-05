#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Execute como root.' >&2; exit 1; }
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export LC_ALL=C DEBIAN_FRONTEND=noninteractive
packages=()
while IFS= read -r package; do
 [[ -n "$package" && $package != \#* ]] || continue
 if [[ $(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true) == installed ]]; then packages+=("$package"); fi
done <"$base/manifests/debloat-packages.txt"
[[ ${#packages[@]} != 0 ]] || exit 0
plan=$(mktemp)
trap 'rm -f -- "$plan"' EXIT
apt-get -s purge "${packages[@]}" >"$plan"
if grep -Eq '^(Remv|Purg) (sddm|sway|quickshell|openssh-server|sudo|network-manager|kitty|systemd|libc6|ibus|imagemagick|qt5ct|qt6ct|rofi|neovim|neovim-runtime|qps)( |:)' "$plan"; then
 cat "$plan" >&2
 echo 'Remoção inesperada de componente necessário; operação interrompida.' >&2
 exit 1
fi
apt-get purge -y "${packages[@]}"
update-desktop-database /usr/share/applications
