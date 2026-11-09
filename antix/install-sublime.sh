#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
sudo apt-get install -y --solver=internal --no-install-recommends flatpak python3-json5
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y --noninteractive flathub com.sublimehq.SublimeText

work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
module=${1:-}
if [[ -z $module ]]; then
  module="$work/sublime-text.sh"
  curl -fL --retry 3 -o "$module" https://raw.githubusercontent.com/amonetlol/sh/main/modules/sublime-text.sh
  sed -i 's/\r$//' "$module"
fi
mkdir -p "$HOME/.local/bin"
if [[ ! -e "$HOME/.local/bin/subl" && ! -L "$HOME/.local/bin/subl" ]]; then
  cat > "$HOME/.local/bin/subl" <<'EOF'
#!/bin/sh
exec flatpak run com.sublimehq.SublimeText "$@"
EOF
  chmod 755 "$HOME/.local/bin/subl"
fi
export PATH="$HOME/.local/bin:$PATH"
config="$HOME/.var/app/com.sublimehq.SublimeText/config"
python3 - "$config" <<'PY_PREFS'
from pathlib import Path
import datetime, json, json5, shutil, sys
prefs = Path(sys.argv[1])/'sublime-text/Packages/User/Preferences.sublime-settings'
if prefs.exists():
    data = json5.loads(prefs.read_text())
    backup = Path.home()/'.local/state/sway-full/backups'/('sublime-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    backup.mkdir(parents=True)
    shutil.copy2(prefs, backup/prefs.name)
    prefs.write_text(json.dumps(data, ensure_ascii=False, indent=4)+'\n')
PY_PREFS
XDG_CONFIG_HOME="$config" bash "$module"

packages="$config/sublime-text/Packages"
python3 - "$packages" <<'PY_LOCALE'
from pathlib import Path
import datetime, json, json5, shutil, sys
settings = Path(sys.argv[1])/'User/LocalizedMenu.sublime-settings'
data = {}
if settings.exists():
    data = json5.loads(settings.read_text())
    backup = Path.home()/'.local/state/sway-full/backups'/('sublime-locale-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    backup.mkdir(parents=True)
    shutil.copy2(settings, backup/settings.name)
data.update(locale='pt_BR', findSimilarVer=True)
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text(json.dumps(data, ensure_ascii=False, indent=4)+'\n')
PY_LOCALE
if [[ -d "$packages/LocalizedMenu/.git" ]]; then
  git -C "$packages/LocalizedMenu" pull --ff-only
elif [[ ! -e "$packages/LocalizedMenu" ]]; then
  git clone --depth 1 https://github.com/zam1024t/LocalizedMenu.git "$packages/LocalizedMenu"
else
  echo "LocalizedMenu existente preservado; configurado para pt_BR."
fi
echo "[OK] Sublime Flatpak: Catppuccin Frappe, Adaptive, CodeNewRoman e menus pt_BR."
echo "[*] Reabra o editor para carregar as configurações. A tradução dos menus é comunitária."
