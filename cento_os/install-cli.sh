#!/usr/bin/env bash
# Ferramentas que os aliases do repo dot esperam. Sem a cadeia do Neovim.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
bin="$HOME/.local/bin"
mkdir -p "$bin"
if sudo -n true 2>/dev/null; then
  sudo dnf install -y ripgrep || true
  for pkg in duf bat tldr tealdeer; do
    sudo dnf install -y "$pkg" || true
  done
else
  log 'sudo sem senha indisponivel; pacotes dnf ficam para a etapa root.'
fi
fetch() {
  name=$1 repo=$2 pattern=$3
  command -v "$name" >/dev/null && return 0
  [[ -x "$bin/$name" ]] && return 0
  work=$(mktemp -d)
  url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep -o "https://[^\"]*$pattern" | head -n1)
  [[ -n "$url" ]] || { echo "Asset ausente: $name" >&2; rm -rf "$work"; return 0; }
  curl -fL "$url" -o "$work/asset"
  case "$url" in
    *.zip) unzip -oq "$work/asset" -d "$work" ;;
    *) tar -xf "$work/asset" -C "$work" ;;
  esac
  found=$(find "$work" -type f -name "$name" ! -name asset | head -n1)
  if [[ -z "$found" ]] && file "$work/asset" | grep -q ELF; then found=$work/asset; fi
  [[ -n "$found" ]] || { echo "Binario ausente no pacote: $name" >&2; rm -rf "$work"; return 0; }
  install -m755 "$found" "$bin/$name"
  rm -rf "$work"
  log "$name instalado em $bin/$name"
}
fetch eza eza-community/eza 'eza_x86_64-unknown-linux-musl.tar.gz'
fetch duf muesli/duf 'duf_.*_linux_x86_64.tar.gz'
fetch bat sharkdp/bat 'bat-.*-x86_64-unknown-linux-musl.tar.gz'
fetch procs dalance/procs 'procs-.*-x86_64-linux.zip'
fetch zoxide ajeetdsouza/zoxide 'zoxide-.*-x86_64-unknown-linux-musl.tar.gz'
if ! command -v tldr >/dev/null && [[ ! -x "$bin/tldr" ]]; then
  fetch tldr dbrgn/tealdeer 'tealdeer-linux-x86_64-musl'
  [[ -x "$bin/tldr" ]] || { [[ -x "$bin/tealdeer" ]] && ln -sf "$bin/tealdeer" "$bin/tldr"; }
fi
if ! python3 -c 'import subprocess,sys; from pathlib import Path
p=next(Path.home().joinpath(".local/share/fonts/SymbolsNerdFont").glob("*Mono.ttf"), None)
sys.exit(0 if p and ".notdef" not in subprocess.check_output(["hb-shape","--font-file",str(p),"--text",chr(0xF538)], text=True) else 1)'; then
  work=$(mktemp -d)
  curl -fL --retry 3 -o "$work/symbols.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/NerdFontsSymbolsOnly.zip
  dest="$HOME/.local/share/fonts/SymbolsNerdFont"
  rm -rf "$dest"
  mkdir -p "$dest" "$work/out"
  unzip -oq "$work/symbols.zip" -d "$work/out"
  cp "$work/out/Symbols-2048-em Nerd Font Complete Mono.ttf" "$work/out/Symbols-2048-em Nerd Font Complete.ttf" "$dest/"
  fc-cache -f "$dest"
  rm -rf "$work"
  log 'Symbols Nerd Font 2.3.3 instalada.'
fi
log 'CLI dos aliases conferido.'
