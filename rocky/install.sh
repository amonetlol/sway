#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/common.sh"
# Log em tempo real: acompanhe com tail -f /tmp/distro-install.log
exec > >(tee /tmp/distro-install.log) 2>&1
log '================================================================'
log 'term-hub sera instalado em ~/.local/bin e carregado no .bashrc'
log 'Acompanhe em tempo real: tail -f /tmp/distro-install.log'
log '================================================================'
for stage in pacotes modules sway sddm services; do
  log "Etapa: $stage"
  bash "$here/install-$stage.sh"
done
bash "$here/verify.sh"
