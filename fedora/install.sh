#!/usr/bin/env bash
# Fedora — mesmo rice do sway-full, com pacotes dnf.
#   bash fedora/install.sh
#   bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/fedora/install.sh)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-fedora-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set fedora sway-full
  exec bash "$dest/fedora/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
step "Pacotes Fedora"
bash "$here/install-pacotes.sh"
step "GRUB"
bash "$here/install-grub.sh"
step "SDDM e tema"
bash "$here/install-sddm.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Serviços systemd"
bash "$here/install-services.sh"
printf '\n[OK] Rice Fedora aplicado. Entre na sessão Sway no SDDM.\n'
