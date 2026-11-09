#!/usr/bin/env bash
# Kali Rolling — mesmo rice do sway-full, com pacotes apt.
#   bash kali/install.sh
#   INSTALL_SUDO_PASSWORD=... bash kali/install.sh
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$here/install-pacotes.sh" ]]; then
  command -v git >/dev/null || { echo "git é necessário para baixar o rice." >&2; exit 1; }
  dest="${TMPDIR:-/tmp}/sway-kali-$$"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/sway.git "$dest"
  git -C "$dest" sparse-checkout set kali sway-full
  exec bash "$dest/kali/install.sh" "$@"
fi
step() { printf '\n[*] %s\n' "$*"; }
if ! sudo -n true 2>/dev/null; then
  [[ -n ${INSTALL_SUDO_PASSWORD:-} ]] || { echo "sudo pede senha. Exporte INSTALL_SUDO_PASSWORD ou rode em um terminal." >&2; exit 1; }
  user="$(id -un)"
  { printf '%s\n' "$INSTALL_SUDO_PASSWORD"; printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$user"; } | sudo -S -p '' tee /etc/sudoers.d/kali-pio >/dev/null
  printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -p '' chmod 440 /etc/sudoers.d/kali-pio
  printf '%s\n' "$INSTALL_SUDO_PASSWORD" | sudo -S -p '' visudo -cf /etc/sudoers.d/kali-pio >/dev/null
fi
step "Pacotes Kali"
bash "$here/install-pacotes.sh"
source "$here/install-session.sh"
trap kali_finish_session EXIT
kali_prepare_session
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
step "Serviços systemd"
bash "$here/install-services.sh"
step "Verificação"
bash "$here/install-verify.sh"
printf '\n[OK] Rice Kali aplicado. Entre na sessão Sway no SDDM.\n'
