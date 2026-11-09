#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
export LANG=${LANG:-C.UTF-8}
export LC_ALL=C.UTF-8
sudo -v
pkgs=(
  sway swaybg waybar rofi kitty nautilus firefox pavucontrol
  swayidle swaylock playerctl wlogout light
  pipewire wireplumber
  gnome-keyring network-manager
  grim slurp imagemagick
  tmux neovim papirus-icon-theme sassc
  xdg-desktop-portal-wlr xdg-desktop-portal-gtk polkit-gnome
  qt6-5compat qt6-svg qt6-declarative xorg-server xorg-xwayland
  wl-clipboard mako-notify btop fastfetch starship open-vm-tools
  sddm git curl python3 nodejs jq unzip
  # Equivalentes Solus da lista amonetlol/ps/arch-pacotes.txt.
  wget zip 7zip tar rsync nano vim bash-completion procs less xclip
  zoxide eza fd ripgrep fzf duf htop tree tealdeer lazygit bat
  gcc g++ make cmake pkgconf binutils glibc-devel autoconf automake
  libtool patch bison flex diffstat gettext texinfo bc findutils coreutils
  lua51 luarocks pip pipenv virtualenv python-neovim python3-devel tree-sitter-cli
  fontconfig noto-sans-ttf noto-serif-ttf font-noto-emoji font-awesome-otf cantarell-fonts
  inetutils mesalib loupe papers xed
  alsa-utils xdg-desktop-portal xdg-user-dirs xdg-utils libnotify xauth
  desktop-file-utils gnome-themes-extra adwaita-icon-theme inotify-tools
)
sudo eopkg install -y "${pkgs[@]}"
# npm vem no pacote nodejs; ferramentas globais ficam no HOME.
if [[ ! -x "$HOME/.local/bin/prettier" ]]; then
  npm install --global --prefix "$HOME/.local" prettier
fi
if ! command -v cliphist >/dev/null; then
  [[ $(uname -m) == x86_64 ]] || { echo "cliphist: arquitetura nao suportada" >&2; exit 1; }
  work=$(mktemp -d)
  trap 'rm -rf -- "$work"' EXIT
  curl -fL --retry 3 -o "$work/cliphist" https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64
  install -Dm755 "$work/cliphist" "$HOME/.local/bin/cliphist"
fi
sudo timedatectl set-timezone America/Sao_Paulo || true
sudo localectl set-locale LANG=pt_BR.UTF-8 || true
sudo localectl set-x11-keymap br abnt2 || true
log "Pacotes Solus instalados."
