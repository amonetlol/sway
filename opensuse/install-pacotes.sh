#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo zypper --non-interactive refresh
core=(
  sway swaybg waybar rofi kitty kitty-shell-integration kitty-terminfo nautilus nautilus-lang pavucontrol
  swayidle swaylock playerctl wl-clipboard wlogout
  pipewire pipewire-pulseaudio wireplumber
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk
  gnome-keyring NetworkManager
  grim slurp libnotify-tools ImageMagick
  tmux terminfo ncurses-utils neovim papirus-icon-theme sassc adwaita-icon-theme
  fontawesome-fonts sddm sddm-greeter-qt6 xauth xf86-input-libinput xdg-user-dirs xdg-user-dirs-lang iproute2
  unzip git curl python3 jq
  eza duf bat ripgrep fd fzf zoxide procs tealdeer lazygit fastfetch btop
  grub2-x86_64-efi grub2
)
sudo zypper --non-interactive install --no-recommends "${core[@]}"
if [[ $(systemd-detect-virt --vm 2>/dev/null || true) == vmware ]]; then
  sudo zypper --non-interactive install --no-recommends open-vm-tools open-vm-tools-desktop
fi
python_version="$(python3 -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
sudo zypper --non-interactive install --no-recommends "python${python_version}-curses"
for pkg in MozillaFirefox firefox cliphist nwg-look swayosd awww mako; do
  sudo zypper --non-interactive install --no-recommends "$pkg" && log "Instalado: $pkg" || warn "Pacote ausente no zypper: $pkg"
done
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-swayosd.sh"
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
LANG=pt_BR.UTF-8 LC_ALL=pt_BR.UTF-8 xdg-user-dirs-update
log "Pacotes openSUSE instalados."
