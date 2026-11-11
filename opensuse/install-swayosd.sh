#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Execute como usuario comum, com sudo.' >&2; exit 1; }
if command -v swayosd-client >/dev/null && command -v swayosd-server >/dev/null; then
  echo '[OK] SwayOSD ja instalado.'
  exit 0
fi
echo '[*] SwayOSD ausente no repositorio; compilando a versao oficial v0.3.1.'
sudo zypper --non-interactive install --no-recommends meson ninja cargo rust gcc pkgconf-pkg-config \
  gtk4-devel gtk4-layer-shell-devel libpulse-devel libinput-devel libudev-devel dbus-1-devel systemd-devel sassc
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 --branch v0.3.1 https://github.com/ErikReider/SwayOSD.git "$work/swayosd"
meson setup "$work/swayosd/build" "$work/swayosd" --prefix=/usr/local --sysconfdir=/etc --buildtype=release
meson compile -C "$work/swayosd/build" -j 2
sudo meson install -C "$work/swayosd/build"
sudo systemctl daemon-reload
sudo systemctl enable swayosd-libinput-backend.service
