#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
base=https://raw.githubusercontent.com/amonetlol/sh/main/modules
names=(bash bin btop fastfetch fonts starship nvim hide-shortcuts recovery-shortcuts kitty wallpapers sublime-text)
paths=(bash.sh bin.sh btop.sh fastfetch.sh fonts.sh starship.sh setup-nvim.sh hide-shortcuts.sh recovery-shortcuts.sh kitty.sh wallpapers.sh sublime-text.sh)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
export DOT_CACHE="${DOT_CACHE:-$HOME/.cache/base-dot-repo}"
if [[ ! -d "$DOT_CACHE/.git" ]]; then
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$DOT_CACHE"
  git -C "$DOT_CACHE" sparse-checkout set dotfiles/bash dotfiles/bin dotfiles/btop dotfiles/fastfetch dotfiles/fonts/.fonts dotfiles/starship dotfiles/kitty
fi
touch "$state/modules.tsv"
for i in "${!names[@]}"; do
  name=${names[i]}
  # Permite retomar de um modulo que falhou, sem repetir os anteriores.
  grep -qxF "$name" "$state/modules-completed.txt" 2>/dev/null && continue
  if [[ $name == fonts ]]; then
    # Os pacotes de fontes ja foram instalados; reutiliza o checkout atual.
    mkdir -p "$HOME/.fonts"
    cp -a "$DOT_CACHE/dotfiles/fonts/.fonts/." "$HOME/.fonts/"
    fc-cache -f
  else
    curl -fLsS --retry 3 "$base/${paths[i]}" -o "$work/$name.sh"
    sed -i 's/\r$//' "$work/$name.sh"
    bash "$work/$name.sh"
  fi
  printf '%s\tinstalled\n' "$name" >> "$state/modules.tsv"
  printf '%s\n' "$name" >> "$state/modules-completed.txt"
done
# Os modulos VMware e random-wallpapers upstream dependem de systemctl.
# Seus equivalentes sao instalados pelas etapas services e sway desta pasta.
log 'Modulos upstream aplicados; VMware e wallpapers serao integrados ao dinit/Sway.'
