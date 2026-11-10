#!/usr/bin/env bash
# Pacotes do modulo pacotes_fedora que ainda nao estao no Rocky.
# Nomes ausentes no EL10 ficam de fora; eza, procs, zoxide e lazygit vem do GitHub.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
bin="$HOME/.local/bin"
mkdir -p "$bin"
export PATH="$bin:$PATH"
repo=(
  gcc gcc-c++ make zip 7zip rsync nano neovim micro bash-completion xclip
  ripgrep duf htop tree tldr bat cmake bc nodejs lua luarocks python3-pip
  net-tools loupe papers
)
log "Instalando pacotes do modulo pacotes_fedora: ${repo[*]}"
sudo dnf install -y "${repo[@]}"
for pkg in vim-enhanced nodejs-npm python3-pynvim pipenv virtualenv; do
  sudo dnf install -y "$pkg" || log "Pacote ausente nos repositorios: $pkg"
done
# blackbox-terminal, ulauncher e xed nao existem no EL10.
fetch() {
  name=$1 repo_name=$2 pattern=$3
  command -v "$name" >/dev/null && return 0
  [[ -x "$bin/$name" ]] && return 0
  work=$(mktemp -d)
  url=$(curl -fsSL -A orca "https://api.github.com/repos/$repo_name/releases/latest" | python3 -c 'import json,sys,re
rel=json.load(sys.stdin)
pat=re.compile(sys.argv[1])
print(next((a["browser_download_url"] for a in rel.get("assets",[]) if pat.search(a["name"])), ""))
' "$pattern" || true)
  [[ -n "$url" ]] || { log "Asset ausente: $name"; rm -rf "$work"; return 0; }
  curl -fL "$url" -o "$work/asset"
  case "$url" in
    *.zip) unzip -oq "$work/asset" -d "$work" ;;
    *) tar -xf "$work/asset" -C "$work" ;;
  esac
  found=$(find "$work" -type f -name "$name" ! -name asset | head -n1)
  if [[ -z "$found" ]] && file "$work/asset" | grep -q ELF; then found=$work/asset; fi
  [[ -n "$found" ]] || { log "Binario ausente no pacote: $name"; rm -rf "$work"; return 0; }
  install -m755 "$found" "$bin/$name"
  rm -rf "$work"
  log "$name instalado em $bin/$name"
}
fetch zoxide ajeetdsouza/zoxide 'zoxide-[^"]*x86_64-unknown-linux-musl\.tar\.gz'
fetch eza eza-community/eza 'eza_x86_64-unknown-linux-gnu\.tar\.gz'
fetch procs dalance/procs 'procs-[^"]*x86_64-linux\.zip'
fetch lazygit jesseduffield/lazygit 'lazygit_[^"]*linux_x86_64\.tar\.gz'
log 'Pacotes do modulo conferidos.'
