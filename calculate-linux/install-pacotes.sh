#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Em instalacoes Calculate enxutas, a arvore Gentoo pode conter apenas metadados.
repo=$(portageq get_repo_path / gentoo)
if ! compgen -G "$repo/gui-wm/sway/sway-*.ebuild" >/dev/null; then
  target=/var/calculate/repos/gentoo-sway
  if [[ ! -d "$target/.git" ]]; then
    sudo git clone --depth 1 https://github.com/calculatelinux/gentoo.git "$target"
  fi
  [[ -f /etc/portage/repos.conf/zz-calculate.conf && "$repo" == /var/db/repos/gentoo ]] || { echo 'Configuracao Portage nao reconhecida.' >&2; exit 1; }
  sudo cp -n /etc/portage/repos.conf/zz-calculate.conf /etc/portage/zz-calculate.conf.backup-sway
  sudo sed -i 's|location = /var/db/repos/gentoo$|location = /var/calculate/repos/gentoo-sway|' /etc/portage/repos.conf/zz-calculate.conf
fi
if ! portageq get_repo_path / guru >/dev/null 2>&1; then
  target=/var/calculate/repos/guru-sway
  if [[ ! -d "$target/.git" ]]; then
    sudo git clone --depth 1 https://github.com/gentoo-mirror/guru.git "$target"
  fi
  printf '[guru]\nlocation = /var/calculate/repos/guru-sway\nsync-type = git\nsync-uri = https://github.com/gentoo-mirror/guru.git\n' | sudo tee /etc/portage/repos.conf/guru.conf >/dev/null
fi
sudo install -d /etc/portage/package.use /etc/portage/package.accept_keywords
printf 'gui-apps/wlogout ~amd64\ngui-apps/swayosd ~amd64\napp-misc/tealdeer ~amd64\n' | sudo tee /etc/portage/package.accept_keywords/sway-calculate >/dev/null
printf 'gui-apps/waybar network tray mpris\ngui-apps/swaybg gdk-pixbuf\nvirtual/notification-daemon -kde -gnome\n' | sudo tee /etc/portage/package.use/sway-calculate >/dev/null
sudo emerge --getbinpkg --usepkg --noreplace dev-util/wayland-scanner
mapfile -t packages < <(sed 's/#.*//;/^[[:space:]]*$/d' "$HERE/packages.txt")
if grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null; then packages+=(app-emulation/open-vm-tools); fi
packages+=(virtual/notification-daemon)
sudo emerge --getbinpkg --usepkg --noreplace --changed-use "${packages[@]}"
