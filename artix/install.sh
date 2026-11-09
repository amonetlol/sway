#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/common.sh" ]]; then
  command -v git >/dev/null || { echo 'Instale git antes de baixar o rice.' >&2; exit 1; }
  dest="$(mktemp -d -t sway-artix.XXXXXXXX)"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set artix sway-full
  exec bash "$dest/artix/install.sh" "$@"
fi
source "$here/common.sh"
start=${1:-pacotes}
run=0
case "$start" in pacotes|grub|sddm|modules|sway|services|verify) ;; *) echo 'Etapa invalida.' >&2; exit 2 ;; esac
for step in pacotes grub sddm modules sway services verify; do
  [[ $step != "$start" ]] || run=1
  ((run)) || continue
  log "Artix: $step"
  bash "$here/install-$step.sh"
  printf '%s\tOK\n' "$step" >> "$state/steps.tsv"
done
log 'Rice instalado. Selecione Sway no SDDM.'
