#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install-common.sh"
require_root
[[ $(dpkg --print-architecture) == amd64 ]] || { echo "Requer amd64." >&2; exit 1; }
cp -a /etc/apt/sources.list "$backup/" 2>/dev/null || true
if [[ -f /etc/apt/apt.conf.d/80-downloads ]]; then cp -a /etc/apt/apt.conf.d/80-downloads "$backup/"; fi
cat >/etc/apt/apt.conf.d/80-downloads <<'EOF'
Acquire::Queue-Mode "host";
Acquire::Retries "3";
Acquire::http::Pipeline-Depth "10";
Acquire::https::Pipeline-Depth "10";
Acquire::Languages "none";
EOF
sed -i '/^deb-src /s/^/# /' /etc/apt/sources.list 2>/dev/null || true
apt-get update
mapfile -t packages < <(sed '/^#/d;/^$/d' "$base/manifests/packages.txt")
if [[ $(cat /etc/debian_version) == */sid ]]; then
 for index in "${!packages[@]}"; do
  [[ ${packages[index]} != network-manager-gnome ]] || packages[index]=network-manager-applet
 done
fi
apt-get install -y --no-install-recommends "${packages[@]}"
usermod -aG sudo "$target"
visudo -c
bash "$base/scripts/install-firefox.sh"
bash "$base/scripts/install-tools.sh"
bash "$base/scripts/debloat-packages.sh"
echo "Pacotes instalados."
