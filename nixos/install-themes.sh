#!/usr/bin/env bash
# Temas do rice em diretórios do usuário. O Papirus do NixOS é só leitura.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
command -v git >/dev/null
work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$HOME/.themes" "$HOME/.local/share/icons" "$HOME/.local/share/themes" "$HOME/.local/share/fonts" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

log "Colloid Dark Catppuccin"
git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme.git "$work/colloid"
(cd "$work/colloid" && bash install.sh -c dark --tweaks catppuccin -l fixed)
ln -sfn "$HOME/.themes/Colloid-Dark-Catppuccin" "$HOME/.local/share/themes/Colloid-Dark-Catppuccin"

log "McMuse-circle (somente Rofi)"
git clone --depth 1 https://github.com/yeyushengfan258/McMuse-circle.git "$work/mcmuse"
(cd "$work/mcmuse" && bash install.sh) || warn "cache de ícones do McMuse ignorado"

log "Cursor Vimix"
git clone --depth 1 https://github.com/vinceliuice/Vimix-cursors.git "$work/vimix"
rm -rf "$HOME/.local/share/icons/Vimix-cursors"
cp -a "$work/vimix/dist" "$HOME/.local/share/icons/Vimix-cursors"
mkdir -p "$HOME/.local/share/icons/default"
printf '[Icon Theme]\nInherits=Vimix-cursors\n' > "$HOME/.local/share/icons/default/index.theme"

log "Papirus-Dark com pastas Frappe Blue"
for name in Papirus Papirus-Dark; do
  src="/run/current-system/sw/share/icons/$name"
  [[ -d $src ]] || continue
  rm -rf "$HOME/.local/share/icons/$name"
  cp -aL "$src" "$HOME/.local/share/icons/$name"
done
git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$work/papirus-colors"
git clone --depth 1 https://github.com/PapirusDevelopmentTeam/papirus-folders.git "$work/papirus-tool"
if [[ -d $HOME/.local/share/icons/Papirus ]]; then
  cp -a "$work/papirus-colors/src/." "$HOME/.local/share/icons/Papirus/"
  bash "$work/papirus-tool/papirus-folders" -C cat-frappe-blue --theme Papirus-Dark || warn "papirus-folders"
fi

python3 - <<'PY'
from pathlib import Path
import configparser
for name in ("gtk-3.0", "gtk-4.0"):
    p = Path.home() / ".config" / name / "settings.ini"
    p.parent.mkdir(parents=True, exist_ok=True)
    c = configparser.ConfigParser(interpolation=None)
    c.read(p)
    if not c.has_section("Settings"):
        c.add_section("Settings")
    c["Settings"].update({
        "gtk-theme-name": "Colloid-Dark-Catppuccin",
        "gtk-icon-theme-name": "Papirus-Dark",
        "gtk-cursor-theme-name": "Vimix-cursors",
        "gtk-cursor-theme-size": "24",
        "gtk-application-prefer-dark-theme": "1",
    })
    with p.open("w") as f:
        c.write(f)
PY

schema="$(find /run/current-system/sw/share/gsettings-schemas -path '*gsettings-desktop-schemas*' -name gschemas.compiled -print -quit 2>/dev/null || true)"
if [[ -n $schema ]] && command -v gsettings >/dev/null; then
  export GSETTINGS_SCHEMA_DIR="$(dirname "$schema")"
  dbus-run-session gsettings set org.gnome.desktop.interface gtk-theme Colloid-Dark-Catppuccin
  dbus-run-session gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
  dbus-run-session gsettings set org.gnome.desktop.interface cursor-theme Vimix-cursors
  dbus-run-session gsettings set org.gnome.desktop.interface cursor-size 24
  dbus-run-session gsettings set org.gnome.desktop.interface color-scheme prefer-dark
fi
fc-cache -f >/dev/null || true
log "Temas aplicados: Colloid, Papirus-Dark, Vimix."
