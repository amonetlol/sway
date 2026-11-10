#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Repo gentoo ausente ou incompleto no CalamaroOS: sincronizar antes de qualquer emerge.
if [[ ! -d /var/db/repos/gentoo/profiles ]] || ! ls /var/db/repos/gentoo/gui-apps/foot/*.ebuild >/dev/null 2>&1; then
  log 'Sincronizando o repositorio gentoo (rsync)...'
  sudo emaint sync -r gentoo
fi
ls /var/db/repos/gentoo/gui-apps/foot/*.ebuild >/dev/null 2>&1 || { echo 'Tree gentoo incompleto apos o sync (foot ausente).' >&2; exit 1; }
sudo emaint sync -r guru 2>/dev/null || true
# Overlay GURU usa ~amd64: liberar os pacotes do rice (e dependencias via autounmask).
sudo mkdir -p /etc/portage/package.accept_keywords
printf '%s\n' \
  'gui-apps/awww ~amd64' \
  'gui-apps/swayosd ~amd64' \
  'gui-apps/wlogout ~amd64' \
  'app-misc/cliphist ~amd64' \
  'app-misc/brightnessctl ~amd64' \
  | sudo tee /etc/portage/package.accept_keywords/90-calamaro-rice >/dev/null
# O perfil original apontava para plasma/systemd; o rice usa desktop/systemd.
current_profile=$(readlink -f /etc/portage/make.profile 2>/dev/null || true)
if [[ "$current_profile" != */desktop/systemd ]]; then
  log 'Ajustando perfil para desktop/systemd...'
  sudo eselect profile set default/linux/amd64/23.0/desktop/systemd
fi
# Remoção do KDE: manter somente sddm (gui-apps) e o tema calamaroos.
kde_pkgs=$(qlist -I | grep -E '^(kde-plasma|kde-apps)/' || true)
if [[ -n "$kde_pkgs" ]]; then
  log 'Removendo KDE (sddm e tema calamaroos permanecem)...'
  # shellcheck disable=SC2086
  sudo emerge --unmerge --quiet $kde_pkgs 2>/dev/null || sudo emerge --unmerge $kde_pkgs
fi
# USEs padrao dos ebuilds + --autounmask-write resolvem o resto do rice.
# Emerges em lote; em caso de conflito, cai para o modo por-pacote.
mapfile -t packages < <(sed 's/#.*//;/^[[:space:]]*$/d' "$HERE/packages.txt")
if ! sudo emerge --noreplace --autounmask-write "${packages[@]}"; then
  log 'Conflito de USE detectado; aplicando arquivos ._cfg e tentando por pacote.'
  sudo bash -c 'for f in $(find /etc/portage -name "._cfg0000_*" 2>/dev/null); do base=${f##*/}; base=${base#._cfg0000_}; mv "$f" "$(dirname "$f")/$base"; done'
  ok_pkgs=(); fail_pkgs=()
  for pkg in "${packages[@]}"; do
    if sudo emerge --noreplace --autounmask-write "$pkg"; then ok_pkgs+=("$pkg"); else fail_pkgs+=("$pkg"); fi
  done
  printf 'Pacotes ok: %s\n' "${ok_pkgs[*]:-nenhum}"
  if ((${#fail_pkgs[@]})); then
    printf 'Pacotes indisponiveis: %s\n' "${fail_pkgs[*]}" >&2
    exit 1
  fi
fi
# Alinhar USEs apos a troca de perfil (plasma -> desktop) com rebuild direcionado,
# sem tocar no resto do world (evita recompilar pacotes como o VLC da imagem).
sudo emerge --update --newuse x11-misc/xdg-utils sys-auth/polkit virtual/notification-daemon
sudo emerge --depclean
