#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
sudo apt-get update
sudo apt-get install -y --solver=internal --no-install-recommends \
  sway swaybg waybar rofi kitty nautilus firefox firefox-l10n-pt-br pavucontrol \
  mako-notifier swayidle swaylock playerctl wl-clipboard wlogout \
  pipewire pipewire-alsa pipewire-pulse wireplumber alsa-utils \
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  gnome-keyring network-manager \
  grim slurp libnotify-bin imagemagick xwayland \
  tmux neovim btop fastfetch papirus-icon-theme sassc gnome-themes-extra adwaita-icon-theme \
  fonts-font-awesome fontconfig sddm qt6-svg-plugins \
  qml6-module-qtquick qml6-module-qt5compat-graphicaleffects \
  unzip git curl ca-certificates python3 jq \
  xserver-xorg-core xserver-xorg-input-libinput xauth x11-xserver-utils \
  xdg-user-dirs xdg-utils desktop-file-utils mate-polkit \
  qml6-module-qtquick-controls qml6-module-qtquick-window \
  qml6-module-qtquick-templates qml6-module-qtqml-models qml6-module-qtqml-workerscript \
  zip 7zip rsync vim procs xclip zoxide eza fd-find ripgrep fzf duf htop tree tealdeer lazygit bat \
  cmake bc nodejs npm lua5.1 luarocks python3-pip python3-pynvim pipenv \
  tree-sitter-cli python3-virtualenv python3-venv strace unrar-free \
  fonts-noto-core fonts-noto-color-emoji loupe papers gnome-text-editor \
  grub-efi-amd64 locales
for pkg in cliphist nwg-look swayosd; do
  if sudo apt-get install -y --solver=internal --no-install-recommends "$pkg"; then
    log "Instalado: $pkg"
  else
    warn "Pacote ausente no apt: $pkg"
  fi
done
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
for pair in bat:batcat fd:fdfind 7z:7zz unrar:unrar-free; do
  name=${pair%%:*}; target=${pair#*:}
  if ! command -v "$name" >/dev/null && command -v "$target" >/dev/null; then
    [[ -e "$HOME/.local/bin/$name" || -L "$HOME/.local/bin/$name" ]] || ln -s "$(command -v "$target")" "$HOME/.local/bin/$name"
  fi
done
if ! command -v prettier >/dev/null; then npm install --global --prefix "$HOME/.local" prettier; fi
bash "$(dirname "${BASH_SOURCE[0]}")/install-awww.sh"
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo sed -i 's/^# *\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes Debian instalados. Clipboard: cliphist. GTK: nwg-look."
