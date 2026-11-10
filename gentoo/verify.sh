#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
for cmd in sway swaymsg foot micro waybar rofi swaybg swayidle swaylock mako wl-copy wl-paste playerctl grim slurp btop fastfetch starship cliphist wlogout swayosd-client swayosd-server vmware-user-suid-wrapper nautilus firefox pactl wpctl; do
  command -v "$cmd" >/dev/null || { echo "Comando ausente: $cmd" >&2; exit 1; }
done
python3 - <<'PY'
from pathlib import Path
import json,shlex,shutil,subprocess
home=Path.home()
actions=json.loads('['+(home/'.config/wlogout/layout').read_text()+']')
expected={'lock':'/usr/bin/swaylock -f -c 303446','logout':'/usr/bin/swaymsg exit','shutdown':'/usr/bin/systemctl poweroff','reboot':'/usr/bin/systemctl reboot'}
assert {a['label']:a['action'] for a in actions}==expected
for a in actions:
    assert Path(shlex.split(a['action'])[0]).is_file(),a
for p in [home/'.config/sway/config',home/'.config/foot/foot.ini',home/'.config/starship-nord.toml',home/'.config/fastfetch/config.jsonc',home/'.local/bin/random-wallpaper.sh',home/'.bin']:
    assert p.exists(),str(p)
assert any((home/'Imagens/wallpapers').rglob('*.jpg')) or any((home/'Imagens/wallpapers').rglob('*.png')) or any((home/'Imagens/wallpapers').rglob('*.webp'))
font=subprocess.check_output(['fc-match','-f','%{family}','CodeNewRoman Nerd Font'],text=True)
assert 'CodeNewRoman' in font,font
print('wlogout: 4 acoes validas; fontes, configuracoes e wallpapers presentes.')
PY
WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate --config "$HOME/.config/sway/config"
systemctl is-enabled sddm.service sshd.service systemd-networkd.service
systemctl --user is-enabled waybar.service pipewire.socket pipewire-pulse.socket wireplumber.service randow-wallpapers.timer
cat "$HOME/.local/state/sway-gentoo/modules.tsv"
log 'Comandos e modulos verificados. Acoes de desligar/reiniciar nao foram executadas.'
