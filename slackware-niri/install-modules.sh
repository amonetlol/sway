#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
export DOT_CACHE="$HOME/.cache/base-dot-repo"
mkdir -p "$cache/modules"
if [[ ! -d $DOT_CACHE/.git ]]; then
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$DOT_CACHE"
  git -C "$DOT_CACHE" sparse-checkout set dotfiles/bash dotfiles/bin dotfiles/btop dotfiles/fastfetch dotfiles/starship dotfiles/foot dotfiles/fonts
fi
names=(bash bin btop fastfetch fonts starship foot wallpapers sublime-text hide-shortcuts recovery-shortcuts)
# Adaptacoes em install-sway/services: micro, foot, wallpaper e VMware.
# Snapper/grub-btrfs e dependencias futuras de Neovim nao sao adicionados.
only=${1:-all}
for name in "${names[@]}"; do
  [[ $only == all || $only == --all || $only == "$name" ]] || continue
  script="$cache/modules/$name.sh"
  curl -fL --retry 3 "https://raw.githubusercontent.com/amonetlol/sh/main/modules/$name.sh" -o "$script"
  sed -i 's/\r$//' "$script"
  bash "$script"
  printf '%s\tupstream\t%s\n' "$name" "$(date -Is)" >> "$state/modules.tsv"
done
log 'Modulos upstream aplicados; adaptacoes e verificacao nas proximas etapas.'
