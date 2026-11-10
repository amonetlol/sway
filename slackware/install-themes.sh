#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
if [[ ! -d /usr/share/icons/Papirus ]]; then
  download https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/heads/master.tar.gz "$cache/papirus.tar.gz"
  mkdir -p "$cache/papirus"
  tar -xf "$cache/papirus.tar.gz" -C "$cache/papirus" --strip-components=1
  sudo make -C "$cache/papirus" install
fi
bash "$here/../sway-full/scripts/install-themes.sh"
sudo cp -a "$HOME/.local/share/icons/Vimix-cursors" /usr/share/icons/
