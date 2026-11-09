#!/usr/bin/env bash
set -euo pipefail
SWAY_REPO="${SWAY_REPO:-https://github.com/amonetlol/sway.git}"
SWAY_REF="${SWAY_REF:-main}"
RICE_WORK="$(mktemp -d -t sway-full.XXXXXXXX)"
trap 'rm -rf -- "$RICE_WORK"' EXIT
RICE_BACKUP="$HOME/.local/state/sway-full/backups/$(date +%Y%m%d-%H%M%S)-$$"
log() { printf '[*] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }
require_user() { [[ $EUID -ne 0 ]] || fail 'Execute como usuario comum; o script utiliza sudo quando necessario.'; }
require_arch() { [[ -f /etc/arch-release ]] || fail 'Este instalador requer Arch Linux ou derivada.'; }
download() { curl -fLsS --retry 2 "$1" -o "$2"; }
resolve_rice() {
  if [[ -n ${RICE_SOURCE:-} ]]; then
    RICE_SOURCE="$(cd "$RICE_SOURCE" && pwd)"
  elif [[ -d "$RICE_ROOT/.config/sway" ]]; then
    RICE_SOURCE="$RICE_ROOT"
  else
    git clone --depth 1 --filter=blob:none --sparse --branch "$SWAY_REF" "$SWAY_REPO" "$RICE_WORK/repo"
    git -C "$RICE_WORK/repo" sparse-checkout set sway-full
    RICE_SOURCE="$RICE_WORK/repo/sway-full"
  fi
  [[ -f "$RICE_SOURCE/.config/sway/config" ]] || fail 'Nao encontrei a pasta sway-full completa.'
}
backup_path() {
  local path="$1" rel
  [[ "$path" == "$HOME/"* ]] || fail "Destino fora do HOME: $path"
  if [[ -e "$path" || -L "$path" ]]; then
    rel="${path#"$HOME/"}"
    mkdir -p "$(dirname "$RICE_BACKUP/$rel")"
    mv "$path" "$RICE_BACKUP/$rel"
  fi
}
deploy_path() {
  local src="$1" dest="$2"
  backup_path "$dest"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
}
user_systemd_available() {
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
  [[ -S "$XDG_RUNTIME_DIR/bus" ]]
}
install_wallpaper_units() {
  resolve_rice
  mkdir -p "$HOME/.config/systemd/user" "$HOME/.local/bin"
  if user_systemd_available; then
    for unit in random-wallpaper.timer random-wallpapers.timer random-wallpaper.service random-wallpapers.service; do
      systemctl --user disable --now "$unit" 2>/dev/null || true
    done
  fi
  install -m755 "$RICE_SOURCE/.local/bin/random-wallpaper.sh" "$HOME/.local/bin/random-wallpaper.sh"
  for unit in awww.service sway-session.target randow-wallpapers.service randow-wallpapers.timer caffeine.service; do
    backup_path "$HOME/.config/systemd/user/$unit"
    install -m644 "$RICE_SOURCE/.config/systemd/user/$unit" "$HOME/.config/systemd/user/$unit"
  done
  if user_systemd_available; then
    systemctl --user daemon-reload
  fi
  if user_systemd_available; then
    systemctl --user --no-reload enable randow-wallpapers.timer caffeine.service
  fi
  # Os servicos graficos somente iniciam quando o Sway importar o display real.
}
