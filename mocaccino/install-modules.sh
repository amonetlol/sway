#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 https://github.com/amonetlol/sh.git "$work/sh"
for module in bash btop fastfetch fonts starship wallpapers; do
  bash "$work/sh/modules/$module.sh"
done
bash "$work/sh/modules/setup-nvim.sh"
