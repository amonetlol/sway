#!/usr/bin/env bash
# Void — mesmo rice do sway-full, com xbps e runit.
#   bash void-qtile/install.sh
#   bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/void-qtile/install.sh)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-void-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set void-qtile sway-full bsol
  exec bash "$dest/void-qtile/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
step "Pacotes Void"
bash "$here/install-pacotes.sh"
step "GRUB"
bash "$here/install-grub.sh"
step "SDDM e tema"
bash "$here/install-sddm.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Serviços runit"
bash "$here/install-services.sh"
step "Temas GTK, ícones e cursor"
bash "$here/install-themes.sh"
printf '\n[OK] Rice Void aplicado. Entre na sessão Sway Full no SDDM.\n'

