#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
sudo pacman -Syu --needed --noconfirm base-devel git curl python jq unzip artix-archlinux-support
sudo pacman-key --populate archlinux
# Extra fica depois dos repositorios Artix; suporte oficial fornece as interfaces
# necessarias sem instalar systemd nem substituir o dinit.
if ! grep -q '^\[extra\]' /etc/pacman.conf; then
  sudo cp -an /etc/pacman.conf /etc/pacman.conf.before-sway-artix
  printf '\n[extra]\nServer = https://geo.mirror.pkgbuild.com/$repo/os/$arch\n' | sudo tee -a /etc/pacman.conf >/dev/null
fi
sudo pacman -Syu --noconfirm
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
curl -fLsS --retry 3 https://raw.githubusercontent.com/amonetlol/ps/main/arch-pacotes.txt -o "$work/packages.txt"
mapfile -t requested < <(sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//' "$work/packages.txt" | sed '/^$/d')
rice=(sway swaybg waybar rofi awww kitty nautilus firefox firefox-i18n-pt-br pavucontrol
  mako swayidle swaylock swayosd playerctl wl-clipboard cliphist wlogout nwg-look
  pipewire pipewire-alsa pipewire-pulse wireplumber alsa-utils
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk xdg-user-dirs xdg-utils
  polkit-gnome gnome-keyring networkmanager networkmanager-dinit elogind-dinit dbus-dinit
  grim slurp libnotify imagemagick xorg-xwayland xorg-server xorg-xauth desktop-file-utils
  tmux neovim papirus-icon-theme sassc gnome-themes-extra adwaita-cursors cantarell-fonts
  ttf-firacode-nerd otf-font-awesome fontconfig sddm sddm-dinit qt6-svg qt6-declarative qt6-5compat
  open-vm-tools gtkmm3 fuse2 fuse3 cronie cronie-dinit)
if [[ $(findmnt -no FSTYPE /) == btrfs ]]; then rice+=(btrfs-progs snapper snap-pac grub-btrfs inotify-tools); fi
repo=(); aur=(); declare -A seen=()
for package in "${requested[@]}" "${rice[@]}"; do
  [[ $package =~ ^[a-zA-Z0-9@][a-zA-Z0-9@._+-]*$ ]] || { echo "Pacote invalido: $package" >&2; exit 1; }
  case "$package" in
    blackbox-terminal|ulauncher|ulancher|ttf-geist|ttf-geist-mono) continue ;;
    p7zip) package=7zip ;;
    ttf-font-awesome) package=otf-font-awesome ;;
  esac
  [[ -z ${seen[$package]:-} ]] || continue
  seen[$package]=1
  if pacman -Si "$package" >/dev/null 2>&1; then repo+=("$package"); else aur+=("$package"); fi
done
sudo pacman -S --needed --noconfirm "${repo[@]}"
for package in "${aur[@]}"; do
  pacman -Q "$package" >/dev/null 2>&1 && continue
  git clone --depth 1 "https://aur.archlinux.org/$package.git" "$work/$package"
  (cd "$work/$package" && makepkg -si --needed --noconfirm)
done
printf '%s\n' "${repo[@]}" "${aur[@]}" > "$state/packages.txt"
curl -fLsS --retry 3 https://api.github.com/repos/vercel/geist-font/releases/latest -o "$work/geist.json"
url=$(jq -er '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' "$work/geist.json" | head -n1)
curl -fLsS --retry 3 "$url" -o "$work/geist.zip"
unzip -oq "$work/geist.zip" -d "$work/geist"
mkdir -p "$HOME/.local/share/fonts/geist"
find "$work/geist" -type f -iname '*.ttf' -exec cp {} "$HOME/.local/share/fonts/geist/" \;
fc-cache -f
sudo sed -i 's/^#\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
printf 'LANG=pt_BR.UTF-8\n' | sudo tee /etc/locale.conf >/dev/null
printf 'KEYMAP=br-abnt2\n' | sudo tee /etc/vconsole.conf >/dev/null
sudo ln -sfn /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
