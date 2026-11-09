#!/usr/bin/env bash
# Debian — mesmo rice do sway-full, com pacotes apt.
#   bash debian/install.sh
#   bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/debian/install.sh)
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-debian-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set debian sway-full
  exec bash "$dest/debian/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
step "Pacotes Debian"
bash "$here/install-pacotes.sh"
source "$here/install-session.sh"
trap debian_finish_session EXIT
debian_prepare_session
step "GRUB"
bash "$here/install-grub.sh"
step "SDDM e tema"
bash "$here/install-sddm.sh"
step "Debloat do desktop anterior"
bash "$here/install-debloat.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Serviços systemd"
bash "$here/install-services.sh"
# Os temas GTK ja sao instalados pelo instalador compartilhado do Sway.
printf '\n[OK] Rice Debian aplicado. Entre na sessao Sway no SDDM.\n'
