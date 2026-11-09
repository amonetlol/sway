#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
if [[ ! -f $here/common.sh ]]; then
  dest="${TMPDIR:-/tmp}/sway-slackware-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set slackware sway-full
  exec bash "$dest/slackware/install.sh" "$@"
fi
steps=(pacotes modules sway sddm services themes debloat verify)
start=${1:-pacotes}
found=0
for step in "${steps[@]}"; do
  [[ $step != "$start" ]] || found=1
  ((found)) || continue
  printf '\n[*] Etapa Slackware: %s\n' "$step"
  bash "$here/install-$step.sh"
done
((found)) || { echo 'Etapa invalida.' >&2; exit 2; }
echo '[OK] Rice Slackware aplicado. Sessao: Sway.'
