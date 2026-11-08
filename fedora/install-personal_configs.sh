#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install-common.sh"
if [[ $EUID == 0 ]]; then
 require_root
 stage_installer
 runuser -u "$target" -- env HOME="$target_home" bash "$stage/install-personal_configs.sh"
 mkdir -p /root/.config
 if [[ -e /root/.config/nvim || -L /root/.config/nvim ]]; then mv /root/.config/nvim "$backup/nvim-root"; fi
 cp -a "$target_home/.config/nvim" /root/.config/nvim
 chown -R root:root /root/.config/nvim
 exit 0
fi
[[ $(id -un) == "$target" ]] || { echo 'Execute com o usuário de destino.' >&2; exit 1; }
for dependency in git python3 rsync fc-cache; do command -v "$dependency" >/dev/null; done
cache="$HOME/.cache/sway-fedora/upstream"
mkdir -p "$cache"
# Track the remote default branch, without a fixed commit or stale-cache fallback.
sync_repo() {
 local repo=$1 dir="$cache/$1"
 if [[ ! -d "$dir/.git" ]]; then
  git clone --depth 1 "https://github.com/amonetlol/$repo.git" "$dir"
 else
  git -C "$dir" pull --ff-only
 fi
}
for repo in sh dot goodies nvim wall2; do sync_repo "$repo"; done
export DOT_CACHE="$cache/dot" DOT_REPO=https://github.com/amonetlol/dot.git
python3 "$base/scripts/deploy-config.py" --scope personal
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
python3 "$base/scripts/prepare-personal.py" "$cache/sh/modules" "$work"
for module in bash btop fastfetch kitty; do bash "$work/$module.sh"; done
# Kitty Tab and Neovim are copied from their freshly updated repositories.
python3 "$base/scripts/apply-personal.py" "$cache" "$base"
mkdir -p "$HOME/.fonts"
cp -a "$cache/dot/dotfiles/fonts/.fonts/." "$HOME/.fonts/"
cp -a "$cache/dot/dotfiles/starship/.config/." "$HOME/.config/"
if [[ $(readlink "$HOME/Imagens/wallpapers" 2>/dev/null || true) != "$cache/wall2" ]]; then
 if [[ -e "$HOME/Imagens/wallpapers" || -L "$HOME/Imagens/wallpapers" ]]; then
 mv "$HOME/Imagens/wallpapers" "$HOME/Imagens/wallpapers.bak-$(date +%Y%m%d-%H%M%S-%N)"
 fi
 mkdir -p "$HOME/Imagens"
 ln -s "$cache/wall2" "$HOME/Imagens/wallpapers"
fi
for module in hide-shortcuts recovery-shortcuts random-wallpapers; do bash "$work/$module.sh"; done
python3 "$base/scripts/hide-shortcuts.py"
fc-cache -f
echo 'Configurações pessoais atualizadas dos repositórios amonetlol.'
