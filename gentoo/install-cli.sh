#!/usr/bin/env bash
# Ferramentas de linha de comando usadas pelos aliases, priorizando binarios.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
sudo emerge --getbinpkg --usepkg --noreplace sys-apps/eza sys-apps/ripgrep sys-apps/bat \
  sys-process/procs sys-process/htop app-text/tree app-arch/zip
if ! command -v duf >/dev/null 2>&1; then
  [[ $(uname -m) == x86_64 ]] || { echo "Instale duf para esta arquitetura pelo Portage." >&2; exit 1; }
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  url=https://github.com/muesli/duf/releases/download/v0.9.1/duf_0.9.1_linux_x86_64.tar.gz
  curl -fLsS --retry 3 "$url" -o "$work/duf.tar.gz"
  printf '%s  %s\n' 5add851e7062c5e56939abb664705e4d14fa2d06289490aff31d51f153832de7 "$work/duf.tar.gz" | sha256sum -c -
  tar -xzf "$work/duf.tar.gz" -C "$work" duf
  install -Dm755 "$work/duf" "$HOME/.local/bin/duf"
fi
# Binarios oficiais para ferramentas instaveis no Portage, com checksum fixo.
install_release() {
  local name="$1" url="$2" sha="$3" member="$4" work
  command -v "$name" >/dev/null 2>&1 && return 0
  [[ $(uname -m) == x86_64 ]] || { echo "Instale $name para esta arquitetura pelo Portage." >&2; return 1; }
  work=$(mktemp -d)
  curl -fLsS --retry 3 "$url" -o "$work/download"
  printf '%s  %s\n' "$sha" "$work/download" | sha256sum -c -
  if [[ -n "$member" ]]; then tar -xzf "$work/download" -C "$work" "$member"; else mv "$work/download" "$work/$name"; member="$name"; fi
  install -Dm755 "$work/$member" "$HOME/.local/bin/$name"
  rm -rf -- "$work"
}
install_release zoxide https://github.com/ajeetdsouza/zoxide/releases/download/v0.10.0/zoxide-0.10.0-x86_64-unknown-linux-musl.tar.gz 2d93385b99f3e82cf2701609a1bffcad863fbeb75aa3fe7eb6be4d29be68b1ae zoxide
install_release tldr https://github.com/tealdeer-rs/tealdeer/releases/download/v1.9.1/tealdeer-linux-x86_64-musl 5a9c3f0691b9cf375ee5c99de802885f3d50498cf686a539e2ddda028eb6b4f6 ''
install_release lazygit https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz 0a23f429a95f0d09db298b3c291536d818de066aa5a85c255806f0490ff6656b lazygit
log 'Ferramentas de terminal instaladas.'
