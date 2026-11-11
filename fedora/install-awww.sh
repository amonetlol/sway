#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuario comum, com sudo." >&2; exit 1; }
if command -v awww >/dev/null && command -v awww-daemon >/dev/null; then
  daemon="$(command -v awww-daemon)"
  if [[ "$daemon" != /usr/bin/awww-daemon ]]; then
    mkdir -p "$HOME/.config/systemd/user/awww.service.d"
    printf '[Service]\nExecStart=\nExecStart=%s\n' "$daemon" > "$HOME/.config/systemd/user/awww.service.d/90-local-build.conf"
  fi
  exit 0
fi
echo '[*] awww ausente no Fedora; compilando a versao oficial v0.12.1.'
sudo dnf install -y cargo rust gcc pkgconf-pkg-config lz4-devel wayland-devel wayland-protocols-devel
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 --branch v0.12.1 https://codeberg.org/LGFae/awww.git "$work/awww"
(cd "$work/awww" && cargo build --locked --release --jobs 2)
sudo install -m755 "$work/awww/target/release/awww" "$work/awww/target/release/awww-daemon" /usr/local/bin/
mkdir -p "$HOME/.config/systemd/user/awww.service.d"
cat > "$HOME/.config/systemd/user/awww.service.d/90-local-build.conf" <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/local/bin/awww-daemon
EOF
