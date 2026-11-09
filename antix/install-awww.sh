#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
if command -v awww >/dev/null && command -v awww-daemon >/dev/null; then
  exit 0
fi
if sudo apt-get install -y --solver=internal --no-install-recommends awww; then
  exit 0
fi

echo '[*] awww ausente no apt; compilando a versão oficial v0.12.1.'
sudo apt-get install -y --solver=internal --no-install-recommends build-essential pkg-config liblz4-dev libwayland-dev wayland-protocols
rust_minor=0
if command -v rustc >/dev/null; then rust_minor=$(rustc --version | awk '{split($2,v,"."); print v[2]}'); fi
if (( rust_minor < 89 )); then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
fi
# shellcheck disable=SC1091
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
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
echo '[OK] awww instalado em /usr/local/bin.'
