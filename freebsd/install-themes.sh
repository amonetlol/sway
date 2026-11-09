#!/bin/sh
set -eu
work="$HOME/.cache/sway-freebsd-themes"
mkdir -p "$work" "$HOME/.local/share/icons"
mkdir -p "$work/tools"
ln -sf "$(command -v gsed)" "$work/tools/sed"
ln -sf "$(command -v gcp)" "$work/tools/cp"
PATH="$work/tools:$PATH"
export PATH
if [ ! -d "$work/colloid/.git" ]; then git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme.git "$work/colloid"; fi
(cd "$work/colloid" && bash install.sh -c dark --tweaks catppuccin -l fixed)
if [ ! -d "$work/vimix/.git" ]; then git clone --depth 1 https://github.com/vinceliuice/Vimix-cursors.git "$work/vimix"; fi
if [ ! -e "$HOME/.local/share/icons/Vimix-cursors" ]; then cp -R "$work/vimix/dist" "$HOME/.local/share/icons/Vimix-cursors"; fi
if [ ! -d "$work/mcmuse/.git" ]; then git clone --depth 1 https://github.com/yeyushengfan258/McMuse-circle.git "$work/mcmuse"; fi
(cd "$work/mcmuse" && bash install.sh)
