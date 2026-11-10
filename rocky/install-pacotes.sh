#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb 2>/dev/null || sudo dnf config-manager crb --set-enabled
rpm -q epel-release >/dev/null 2>&1 || sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
# git e curl sao necessarios antes das compilacoes locais deste script.
sudo dnf install -y git curl
# Repositorios comunitarios liberados pelo usuario: RPM Fusion free e nonfree.
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
  sudo dnf install -y "https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm"
fi
if ! rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
  sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm"
fi
# COPRs com builds comunitarias para EL10 (ecossistema wlroots e starship).
add_repo() {
  owner=$1; project=$2; pkgs=$3
  file=/etc/yum.repos.d/$(echo "$owner$project" | tr -d '@').repo
  id=$(echo "$owner:$project" | tr -d '@')
  sudo tee "$file" >/dev/null <<EOF
[copr:$id]
name=$owner/$project for EL10
baseurl=https://download.copr.fedorainfracloud.org/results/$owner/$project/epel-10-\$basearch/
enabled=1
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/$owner/$project/pubkey.gpg
includepkgs=$pkgs
EOF
}
add_repo yselkowitz wlroots-epel 'waybar rofi rofi-themes cliphist wlogout swaybg swayidle swaylock brightnessctl playerctl playerctl-libs sway foot foot-libs grim slurp xdg-desktop-portal-wlr wlroots wlroots0.19 fcft tllist xcb-imdkit libmpdclient gtk-layer-shell jsoncpp sway-config-minimal'
add_repo '@sway-sig' epel 'mako libscfg'
add_repo atim starship 'starship'
sudo dnf makecache -y --refresh
# SwayOSD 0.3.2 compilado localmente: sem pacote EL10 em nenhum repositorio.
# gtk4-layer-shell tambem e compilado; nao existe pacote para EL10.
if ! pkg-config --exists gtk4-layer-shell-0; then
  sudo dnf install -y gtk4-devel wayland-devel wayland-protocols-devel meson ninja-build pkgconf-pkg-config gcc gcc-c++ gobject-introspection-devel vala
  lwork=$(mktemp -d -t layer-shell.XXXXXXXX)
  git clone --depth 1 --branch v1.1.1 https://github.com/wmww/gtk4-layer-shell.git "$lwork/gtk4-layer-shell"
  meson setup "$lwork/gtk4-layer-shell/build" "$lwork/gtk4-layer-shell" --prefix /usr --buildtype=release
  meson compile -C "$lwork/gtk4-layer-shell/build"
  sudo meson install -C "$lwork/gtk4-layer-shell/build"
  sudo rm -rf "$lwork"
  pkg-config --exists gtk4-layer-shell-0
fi
if ! command -v swayosd-client >/dev/null; then
  sudo dnf install -y rust cargo meson ninja-build gcc git curl sassc gtk4-devel libadwaita-devel pulseaudio-libs-devel libevdev-devel libinput-devel dbus-devel pkgconf-pkg-config systemd-devel
  work=$(mktemp -d -t swayosd.XXXXXXXX); trap 'rm -rf -- "$work"' EXIT
  git clone --depth 1 --branch v0.3.2 https://github.com/ErikReider/SwayOSD.git "$work/SwayOSD"
  meson setup "$work/SwayOSD/build" "$work/SwayOSD" --prefix /usr --buildtype=release
  meson compile -C "$work/SwayOSD/build"
  sudo meson install -C "$work/SwayOSD/build"
  test -x /usr/bin/swayosd-client && test -x /usr/bin/swayosd-server
  sudo dnf remove -y rust cargo meson ninja-build gtk4-devel libadwaita-devel pulseaudio-libs-devel libevdev-devel libinput-devel dbus-devel pkgconf-pkg-config systemd-devel gcc gcc-c++ 2>/dev/null || true
fi
# Chrome pelo RPM oficial do Google (adiciona o repositorio google-chrome).
rpm -q google-chrome-stable >/dev/null 2>&1 || sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
mapfile -t packages < <(sed 's/#.*//;/^[[:space:]]*$/d' "$HERE/packages.txt")
sudo dnf install -y --setopt=install_weak_deps=False "${packages[@]}"
