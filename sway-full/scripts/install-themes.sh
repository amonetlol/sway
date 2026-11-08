#!/usr/bin/env bash
# Dependencias visuais usadas pelas configs: instaladas de suas fontes atuais.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Execute este script como usuario comum.' >&2; exit 1; }
for cmd in git curl sassc fc-match python3; do command -v "$cmd" >/dev/null || { echo "Dependencia ausente: $cmd" >&2; exit 1; }; done
theme_work="$(mktemp -d -t sway-full-themes.XXXXXXXX)"
trap 'rm -rf -- "$theme_work"' EXIT
backup="$HOME/.local/state/sway-full/backups/themes-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$backup" "$HOME/.local/share/icons" "$HOME/.local/share/fonts"
for name in gtk-3.0 gtk-4.0; do [[ ! -e "$HOME/.config/$name" ]] || cp -a "$HOME/.config/$name" "$backup/"; done
git clone --depth 1 https://github.com/vinceliuice/Colloid-gtk-theme.git "$theme_work/colloid"
(cd "$theme_work/colloid" && bash install.sh -c dark --tweaks catppuccin -l fixed)
git clone --depth 1 https://github.com/yeyushengfan258/McMuse-circle.git "$theme_work/mcmuse"
for name in McMuse-circle McMuse-circle-dark; do
  [[ ! -e "$HOME/.local/share/icons/$name" ]] || mv "$HOME/.local/share/icons/$name" "$backup/$name"
done
(cd "$theme_work/mcmuse" && bash install.sh)
git clone --depth 1 https://github.com/vinceliuice/Vimix-cursors.git "$theme_work/vimix"
[[ ! -e "$HOME/.local/share/icons/Vimix-cursors" ]] || mv "$HOME/.local/share/icons/Vimix-cursors" "$backup/Vimix-cursors"
cp -a "$theme_work/vimix/dist" "$HOME/.local/share/icons/Vimix-cursors"
mkdir -p "$HOME/.local/share/icons/default"
[[ ! -e "$HOME/.local/share/icons/default/index.theme" ]] || cp -a "$HOME/.local/share/icons/default/index.theme" "$backup/default-index.theme"
printf '[Icon Theme]\nInherits=Vimix-cursors\n' > "$HOME/.local/share/icons/default/index.theme"
git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$theme_work/papirus-colors"
git clone --depth 1 https://github.com/PapirusDevelopmentTeam/papirus-folders.git "$theme_work/papirus-tool"
[[ -d /usr/share/icons/Papirus ]] || { echo 'Instale papirus-icon-theme com install-pacotes.sh.' >&2; exit 1; }
sudo cp -a "$theme_work/papirus-colors/src/." /usr/share/icons/Papirus/
sudo bash "$theme_work/papirus-tool/papirus-folders" -C cat-frappe-blue --theme Papirus-Dark
sudo gtk-update-icon-cache -f -t /usr/share/icons/Papirus
# O modulo fonts tambem fornece esta fonte. Baixar apenas CodeNewRoman se faltar.
if [[ $(fc-match -f '%{family}' 'CodeNewRoman Nerd Font') != *CodeNewRoman* ]]; then
  git clone --depth 1 --filter=blob:none --sparse https://github.com/amonetlol/dot.git "$theme_work/fonts"
  git -C "$theme_work/fonts" sparse-checkout set dotfiles/fonts/.fonts/CodeNewRoman
  cp -a "$theme_work/fonts/dotfiles/fonts/.fonts/CodeNewRoman" "$HOME/.local/share/fonts/"
fi
fc-cache -f
python3 - <<'PY'
from pathlib import Path
import configparser
for name in ['gtk-3.0','gtk-4.0']:
    p=Path.home()/'.config'/name/'settings.ini';p.parent.mkdir(parents=True,exist_ok=True)
    c=configparser.ConfigParser(interpolation=None);c.read(p)
    if not c.has_section('Settings'):c.add_section('Settings')
    c['Settings'].update({'gtk-theme-name':'Colloid-Dark-Catppuccin','gtk-icon-theme-name':'Papirus-Dark',
                          'gtk-cursor-theme-name':'Vimix-cursors','gtk-cursor-theme-size':'24','gtk-application-prefer-dark-theme':'1'})
    with p.open('w') as f:c.write(f)
PY
set_pref() {
  if [[ -S "/run/user/$(id -u)/bus" ]]; then
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" gsettings set org.gnome.desktop.interface "$1" "$2"
  else
    dbus-run-session -- gsettings set org.gnome.desktop.interface "$1" "$2"
  fi
}
set_pref gtk-theme Colloid-Dark-Catppuccin
set_pref icon-theme Papirus-Dark
set_pref cursor-theme Vimix-cursors
set_pref cursor-size 24
set_pref color-scheme prefer-dark
echo 'Temas instalados: GTK Colloid, Nautilus Papirus Frappe Blue, cursor Vimix; McMuse-circle somente no Rofi.'
