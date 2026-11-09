#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
source_rice="$here/../sway-full"
[[ -f "$source_rice/.config/sway/config" ]]
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
cp -a "$source_rice/." "$work/"
# O instalador comum conserva as configuracoes, mas seu helper pressupoe systemd.
# Alteramos somente a copia temporaria, preservando sway-full e outras distros.
python3 - "$work" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1])/'scripts/common.sh'
s=p.read_text()
start=s.index('user_systemd_available() {')
end=s.index('\ninstall_wallpaper_units() {',start)
s=s[:start]+'user_systemd_available() { return 1; }\n'+s[end:]
start=s.index('install_wallpaper_units() {')
s=s[:start]+'''install_wallpaper_units() {
  resolve_rice
  install -Dm755 "$RICE_SOURCE/.local/bin/random-wallpaper.sh" "$HOME/.local/bin/random-wallpaper.sh"
}
'''
p.write_text(s)
p=Path(sys.argv[1])/'install-sway.sh'
s=p.read_text()
start=s.index('mkdir -p "$HOME/.config/systemd/user/waybar.service.d"')
end=s.index('python3 "$RICE_SOURCE/scripts/setup-desktop.py"',start)
p.write_text(s[:start]+s[end:])
PY
mkdir -m700 "$work/runtime"
XDG_RUNTIME_DIR="$work/runtime" RICE_SOURCE="$work" bash "$work/install-sway.sh"
python3 "$here/setup-artix.py"
printf 'random-wallpapers\tinstalled-sway-session\n' >> "$state/modules.tsv"
