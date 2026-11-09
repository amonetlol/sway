#!/usr/bin/env bash
set -euo pipefail
[[ $(. /etc/os-release; printf %s "$ID") == mocaccinoos ]] || { echo "Requer MocaccinoOS" >&2; exit 1; }
sudo luet install -y --relax repository/mocaccino-community-stable repo-updater/mocaccino-community-stable
sudo luet install -y --relax layers/sway apps/waybar apps/rofi apps/kitty apps/wl-clipboard apps/btop apps/fastfetch apps/neovim apps/grim apps/lightdm apps/xdg-desktop-portal-wlr apps/ripgrep apps/fzf apps/duf apps/htop apps/tree apps/bat apps/xclip apps/tmux devel/cmake apps/nodejs apps/pip development/gcc
sudo systemctl enable sshd
