#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
sudo -v
sudo install -d /etc/portage/package.use /etc/portage/package.accept_keywords
cat <<'EOF' | sudo tee /etc/portage/package.use/sway-rice >/dev/null
gui-apps/waybar network mpris tray pulseaudio pipewire
gui-apps/swaybg gdk-pixbuf
media-video/pipewire sound-server pipewire-alsa
app-emulation/open-vm-tools gtkmm
EOF
mapfile -t packages < <(sed 's/#.*//;/^[[:space:]]*$/d' "$HERE/packages.txt")
sudo emerge --getbinpkg --usepkg --with-bdeps=n --update --changed-use "${packages[@]}"
# GURU e o repositorio comunitario oficial. Somente estes pacotes recebem ~amd64.
if [[ ! -d /var/db/repos/guru/.git ]]; then
  sudo git clone --depth 1 https://github.com/gentoo/guru.git /var/db/repos/guru
fi
sudo install -d /etc/portage/repos.conf
printf '[guru]\nlocation = /var/db/repos/guru\nsync-type = git\nsync-uri = https://github.com/gentoo/guru.git\n' | sudo tee /etc/portage/repos.conf/guru.conf >/dev/null
printf 'gui-apps/wlogout ~amd64\ngui-apps/swayosd ~amd64\n' | sudo tee /etc/portage/package.accept_keywords/sway-rice >/dev/null
sudo emerge --getbinpkg --usepkg --with-bdeps=n --update --changed-use gui-apps/wlogout gui-apps/swayosd
log 'Pacotes instalados. O Portage usa binarios compativeis e compila somente o que faltar.'
