#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
export DOT_CACHE="$HOME/.cache/base-dot-repo"
mkdir -p "$cache/modules"
if [[ ! -d $DOT_CACHE/.git ]]; then
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$DOT_CACHE"
  git -C "$DOT_CACHE" sparse-checkout set dotfiles/bash dotfiles/bin dotfiles/btop dotfiles/fastfetch dotfiles/starship dotfiles/foot dotfiles/fonts
else
  git -C "$DOT_CACHE" pull --ff-only || true
fi
names=(bash bin btop fastfetch fonts starship foot wallpapers sublime-text hide-shortcuts recovery-shortcuts)
for name in "${names[@]}"; do
  script="$cache/modules/$name.sh"
  curl -fL --retry 3 "https://raw.githubusercontent.com/amonetlol/sh/main/modules/$name.sh" -o "$script"
  sed -i 's/\r$//' "$script"
  bash "$script"
  printf '%s\tupstream\t%s\n' "$name" "$(date -Is)" >> "$state/modules.tsv"
done
log 'Modulos upstream aplicados.'
