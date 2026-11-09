#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
[[ -f $here/../sway-full/.config/sway/config ]] || { echo 'sway-full ausente ao lado de salix/.' >&2; exit 1; }
steps=(pacotes gaps modules sway sddm services themes verify)
start=${1:-pacotes}
found=0
for step in "${steps[@]}"; do
  [[ $step != "$start" ]] || found=1
  ((found)) || continue
  printf '\n[*] Etapa Salix: %s\n' "$step"
  bash "$here/install-$step.sh"
done
((found)) || { echo 'Etapa invalida.' >&2; exit 2; }
echo '[OK] Rice Salix aplicado. Sessao: Sway.'
