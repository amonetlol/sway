#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install-common.sh"
require_root
python3 "$base/scripts/optimize-dnf.py"
mapfile -t packages < <(sed '/^#/d;/^$/d' "$base/manifests/packages.txt")
dnf install -y --setopt=install_weak_deps=False "${packages[@]}"
usermod -aG wheel "$target"
visudo -c
bash "$base/scripts/install-firefox.sh"
bash "$base/scripts/install-tools.sh"
bash "$base/scripts/install-matugen.sh"
echo 'Pacotes Fedora instalados.'
