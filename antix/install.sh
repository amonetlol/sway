#!/usr/bin/env bash
# antiX — mesmo rice do sway-full, com pacotes apt e init 66.
#   bash antix/install.sh
#   INSTALL_SUDO_PASSWORD=... bash antix/install.sh
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-antix-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set antix sway-full
  exec bash "$dest/antix/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
if ! sudo -n true 2>/dev/null; then
  [[ -n ${INSTALL_SUDO_PASSWORD:-} ]] || { echo "sudo pede senha. Exporte INSTALL_SUDO_PASSWORD ou rode em um terminal." >&2; exit 1; }
  user="$(id -un)"
  rule="$(mktemp)"
  printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$user" > "$rule"
  printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -p '' cp "$rule" /etc/sudoers.d/antix-pio
  rm -f "$rule"
  printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -p '' chmod 440 /etc/sudoers.d/antix-pio
  printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -p '' visudo -cf /etc/sudoers.d/antix-pio >/dev/null
  sudo -n true
fi
step "Pacotes antiX"
bash "$here/install-pacotes.sh"
source "$here/install-session.sh"
trap antix_finish_session EXIT
antix_prepare_session
step "GRUB"
bash "$here/install-grub.sh"
step "SDDM e tema"
bash "$here/install-sddm.sh"
step "Debloat"
bash "$here/install-debloat.sh"
step "Módulos atualizados do GitHub"
bash "$here/install-modules.sh" --all
step "Configuração do Sway"
bash "$here/install-sway.sh"
step "Serviços 66"
bash "$here/install-services.sh"
step "Verificação"
bash "$here/install-verify.sh"
printf '\n[OK] Rice antiX aplicado. Entre na sessão Sway no SDDM.\n'
