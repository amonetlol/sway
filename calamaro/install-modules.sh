#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$HOME/.local/bin" "$HOME/.local/state/sway-calamaro"
: > "$HOME/.local/state/sway-calamaro/modules.tsv"
# Micro oficial precompilado: sem Go, Node, Lua ou plugins de Neovim.
if ! command -v micro >/dev/null; then
  version=2.0.15
  url="https://github.com/micro-editor/micro/releases/download/v$version/micro-$version-linux64.tar.gz"
  curl -fLsS --retry 3 "$url" -o "$work/micro.tar.gz"
  curl -fLsS --retry 3 "$url.sha" -o "$work/micro.sha"
  (cd "$work"; expected=$(awk '{print $1; exit}' micro.sha); printf '%s  micro.tar.gz\n' "$expected" | sha256sum -c -)
  tar xf "$work/micro.tar.gz" -C "$work"
  install -m755 "$work/micro-$version/micro" "$HOME/.local/bin/micro"
fi
# Baixar somente os diretorios de configuracao usados neste rice.
export DOT_CACHE="${DOT_CACHE:-$HOME/.cache/base-dot-repo}"
if [[ ! -d "$DOT_CACHE/.git" ]]; then
  mkdir -p "$(dirname "$DOT_CACHE")"
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$DOT_CACHE"
  git -C "$DOT_CACHE" sparse-checkout set dotfiles/bash dotfiles/bin dotfiles/btop dotfiles/fastfetch dotfiles/starship dotfiles/fonts/.fonts/CodeNewRoman
else
  git -C "$DOT_CACHE" pull --ff-only 2>/dev/null || true
fi
# Configuracoes atuais do autor, sem executarmos instaladores de outras distros.
for name in bash btop fastfetch fonts starship wallpapers; do
  if [[ "$name" == fonts ]]; then
    mkdir -p "$HOME/.local/share/fonts/CodeNewRoman"
    cp -a "$DOT_CACHE/dotfiles/fonts/.fonts/CodeNewRoman/." "$HOME/.local/share/fonts/CodeNewRoman/"
    fc-cache -f
    printf 'fonts\tinstalled\n' >> "$HOME/.local/state/sway-calamaro/modules.tsv"
    continue
  fi
  curl -fLsS --retry 3 "https://raw.githubusercontent.com/amonetlol/sh/main/modules/$name.sh" -o "$work/$name.sh"
  sed -i 's/\r$//' "$work/$name.sh"
  bash "$work/$name.sh"
  printf '%s\tinstalled\n' "$name" >> "$HOME/.local/state/sway-calamaro/modules.tsv"
done
# bash.sh instala tambem ~/.bin e ~/.aliases-calamaro; os launchers Sway vem do sway-full.
printf 'bin\tinstalled\neditor\tmicro\nterminal\tfoot\n' >> "$HOME/.local/state/sway-calamaro/modules.tsv"
export EDITOR=micro VISUAL=micro
mkdir -p "$HOME/.config/environment.d"
printf 'EDITOR=micro\nVISUAL=micro\n' > "$HOME/.config/environment.d/60-editor.conf"
# Os atalhos existentes do usuario passam a chamar o editor escolhido.
python3 - <<'PY'
from pathlib import Path
import re
for root in [Path.home()/'.bin', Path.home()/'.aliases', Path.home()/'.functions']:
    paths=root.rglob('*') if root.is_dir() else [root]
    for p in paths:
        if not p.is_file() or p.is_symlink(): continue
        try: text=p.read_text()
        except (UnicodeError,OSError): continue
        new=re.sub(r'\bnvim\b','micro',text)
        if new!=text:p.write_text(new)
p=Path.home()/'.bashrc'
with p.open('a') as f:f.write('''
export EDITOR=micro VISUAL=micro
export PATH="$HOME/.local/bin:$HOME/.bin:$PATH"
# Ferramentas opcionais nao justificam aliases quebrados no CalamaroOS.
command -v bat >/dev/null || unalias cat 2>/dev/null || true
command -v eza >/dev/null || unalias ls ll lr 2>/dev/null || true
command -v duf >/dev/null || unalias df duf 2>/dev/null || true
command -v procs >/dev/null || unalias ps 2>/dev/null || true
command -v tldr >/dev/null || unalias man 2>/dev/null || true
alias nv=micro v=micro tx=micro
alias aln='micro ~/.config/micro/settings.json'
alias alw='micro ~/.config/waybar/config ~/.config/waybar/style.css'
alias al2='micro ~/.bashrc ~/.aliases ~/.aliases-calamaro ~/.functions'
alias gfont2='fc-list : family | sort -u'
''')
PY
