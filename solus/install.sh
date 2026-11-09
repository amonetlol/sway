#!/usr/bin/env bash
# Solus — mesmo rice do sway-full, com pacotes eopkg.
#   bash solus/install.sh
#   bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/solus/install.sh)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-solus-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set solus sway-full
  exec bash "$dest/solus/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
step "Pacotes Solus"
bash "$here/install-pacotes.sh"
step "Partida nativa (clr-boot-manager)"
bash "$here/install-grub.sh"
step "SDDM e tema"
bash "$here/install-sddm.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Serviços systemd"
bash "$here/install-systemd.sh"
step "Debloat GNOME, LibreOffice, Thunderbird e GParted"
bash "$here/install-debloat.sh"
printf '\n[OK] Rice Solus aplicado. Entre na sessão Sway Full no SDDM.\n'
