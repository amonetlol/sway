#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo -v
printf 'Salix 15.0\n' | sudo tee /etc/salix-version >/dev/null
[[ -s /etc/ssl/certs/ca-certificates.crt ]] || sudo /usr/sbin/update-ca-certificates --fresh
sudo slapt-get -y --add-keys || true
sudo slapt-get -y --update
desktop=(
  sway swaybg waybar foot rofi-lbonn-wayland grim wl-clipboard playerctl imv
  sddm thunar thunar-volman pavucontrol pipewire wireplumber
  xdg-desktop-portal xdg-desktop-portal-gtk polkit-gnome NetworkManager
  mozilla-firefox micro btop jq
  dejavu-fonts-ttf noto-fonts-ttf noto-emoji
  mesa xorg-server xorg-server-xwayland xf86-input-libinput xf86-input-evdev xauth xkbcomp xkeyboard-config qt5 sassc
)
build=(gcc gcc-g++ make meson ninja cmake pkg-config scdoc wayland wayland-protocols wlroots cairo pango gdk-pixbuf2 gtk+3 gtk-layer-shell pam git curl wget rsync infozip)
sudo slapt-get -y --no-upgrade --install "${desktop[@]}"
sudo slapt-get -y --no-upgrade --install "${build[@]}"
if [[ ! -x /usr/bin/pipewire-pulse && ! -x /usr/bin/pulseaudio ]]; then
  sudo slapt-get -y --no-upgrade --install pulseaudio
fi
log 'Pacotes binarios do Salix instalados. Foot e micro substituem Kitty e Neovim.'
