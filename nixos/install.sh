#!/usr/bin/env bash
# NixOS Sway Full — replica o rice da VM (rolling, SDDM, GRUB, módulos do GitHub).
# Uso, a partir de um checkout:
#   bash nixos/install.sh
# Ou direto:
#   bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/nixos/install.sh)
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/configuration.nix" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-nixos-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set nixos sway-full
  exec bash "$dest/nixos/install.sh" "$@"
fi

step() { printf '\n[*] %s\n' "$*"; }
step "Sistema NixOS (canal rolling, SDDM, GRUB, pacotes)"
bash "$here/install-system.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Temas GTK, ícones e cursor"
bash "$here/install-themes.sh"
step "Menu de boot Aarambh (Picker Wheel)"
bash "$here/install-aarambh.sh" || printf '[AVISO] Aarambh não foi instalado. O GRUB do NixOS continua utilizável.\n'
printf '\n[OK] Rice NixOS aplicado. Entre na sessão sway no SDDM.\n'
