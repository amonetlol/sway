#!/usr/bin/env bash
# Executar dentro do Slackware apos instalar as dependencias de compilacao.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export CARGO_BUILD_JOBS=2
export PKG_CONFIG_PATH=/usr/local/ff-niri-compat/lib64/pkgconfig:/usr/lib64/pkgconfig:/usr/share/pkgconfig
export RUSTFLAGS="-C link-arg=-Wl,-rpath,/usr/local/ff-niri-compat/lib64"
src=/var/tmp/ff-build/niri-26.04
mkdir -p "$src"
tar -xzf /var/tmp/ff-build/niri-26.04.tar.gz -C "$src" --strip-components=1
cd "$src"
cargo build --release --locked --no-default-features --features dbus,xdp-gnome-screencast
install -D -m 755 target/release/niri /usr/local/bin/niri
install -d -m 755 /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/niri.desktop <<'EOF'
[Desktop Entry]
Name=Niri
Comment=Scrollable tiling Wayland compositor
Exec=/usr/bin/dbus-run-session -- /usr/local/bin/niri --session
Type=Application
DesktopNames=niri
EOF
install -D -m 644 resources/niri-portals.conf /usr/share/xdg-desktop-portal/niri-portals.conf
niri --version
