#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo -v
[[ -s /etc/ssl/certs/ca-certificates.crt ]] || sudo /usr/sbin/update-ca-certificates --fresh
python3 "$here/packages.py" \
  mozilla-firefox pavucontrol thunar thunar-volman libxfce4util libxfce4ui libxfce4windowing xfconf exo garcon \
  btop sassc gtk-layer-shell xdg-desktop-portal xdg-desktop-portal-gtk \
  pipewire wireplumber polkit-gnome gnome-keyring NetworkManager sddm
bash "$here/build-packages.sh"
bash "$here/install-tools.sh"
log 'Pacotes essenciais instalados. Foot e micro substituem Kitty e Neovim; sem toolchains/LSP adicionais.'
