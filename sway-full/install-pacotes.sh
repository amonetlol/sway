#!/usr/bin/env bash
set -euo pipefail
RICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$RICE_ROOT/scripts/common.sh" ]]; then source "$RICE_ROOT/scripts/common.sh"; else
  helper="$(mktemp)"; curl -fLsS https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/scripts/common.sh -o "$helper"; source "$helper"; rm -f "$helper"
fi
require_user
require_arch
sudo -v
sudo pacman -Syu --needed --noconfirm base-devel git curl python jq unzip
download https://raw.githubusercontent.com/amonetlol/ps/main/arch-pacotes.txt "$RICE_WORK/arch-pacotes.txt"
mapfile -t requested < <(sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//' "$RICE_WORK/arch-pacotes.txt" | sed '/^$/d')
rice=(sway swaybg waybar rofi awww kitty nautilus firefox firefox-i18n-pt-br pavucontrol
  mako swayidle swaylock swayosd playerctl wl-clipboard clipman wlogout
  pipewire pipewire-alsa pipewire-pulse wireplumber alsa-utils
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk xdg-user-dirs xdg-utils
  polkit-gnome gnome-keyring networkmanager grim slurp libnotify imagemagick
  xorg-xwayland xorg-server xorg-xauth desktop-file-utils tmux neovim
  papirus-icon-theme sassc gnome-themes-extra adwaita-cursors cantarell-fonts
  ttf-firacode-nerd otf-font-awesome fontconfig sddm qt6-svg qt6-declarative qt6-5compat)
if [[ $(findmnt -no FSTYPE /) == btrfs ]]; then rice+=(btrfs-progs snapper snap-pac grub-btrfs inotify-tools); fi
repo=(); aur=(); declare -A seen=()
for package in "${requested[@]}" "${rice[@]}"; do
  [[ "$package" =~ ^[a-zA-Z0-9@][a-zA-Z0-9@._+-]*$ ]] || fail "Nome de pacote invalido na lista: $package"
  case "$package" in
    blackbox-terminal|ulauncher|ulancher) continue ;;
    p7zip) package=7zip ;;
    ttf-font-awesome) package=otf-font-awesome ;;
    ttf-geist|ttf-geist-mono) continue ;; # Fontes upstream instaladas abaixo.
  esac
  [[ -z ${seen[$package]:-} ]] || continue
  seen[$package]=1
  if pacman -Si "$package" >/dev/null 2>&1; then repo+=("$package"); else aur+=("$package"); fi
done
sudo pacman -S --needed --noconfirm "${repo[@]}"
if command -v yay >/dev/null 2>&1; then
  log "yay ja disponivel: $(command -v yay)"
else
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$RICE_WORK/yay-bin"
  (cd "$RICE_WORK/yay-bin" && makepkg -si --needed --noconfirm)
fi
if ((${#aur[@]})); then yay -S --needed "${aur[@]}"; fi
# Os antigos pacotes ttf-geist/ttf-geist-mono nao estao no repositorio atual.
download https://api.github.com/repos/vercel/geist-font/releases/latest "$RICE_WORK/geist.json"
url=$(jq -er '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' "$RICE_WORK/geist.json" | head -n1)
download "$url" "$RICE_WORK/geist.zip"
unzip -oq "$RICE_WORK/geist.zip" -d "$RICE_WORK/geist"
mkdir -p "$HOME/.local/share/fonts/geist"
find "$RICE_WORK/geist" -type f -iname '*.ttf' -exec cp {} "$HOME/.local/share/fonts/geist/" \;
fc-cache -f
# O calendario do Waybar depende deste locale instalado.
sudo sed -i 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=pt_BR.UTF-8
sudo localectl set-keymap br-abnt2
sudo localectl set-x11-keymap br abnt2
sudo timedatectl set-timezone America/Sao_Paulo
if user_systemd_available; then systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service; fi
log 'Pacotes instalados; blackbox-terminal e ulauncher excluidos. Wayland inclui XWayland para aplicativos legados.'
