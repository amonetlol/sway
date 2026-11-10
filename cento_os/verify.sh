#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
for cmd in sway swaymsg foot micro waybar rofi swaybg swayidle swaylock mako wl-copy wl-paste playerctl grim slurp btop fastfetch starship cliphist wlogout swayosd-client swayosd-server nautilus google-chrome-stable pactl wpctl loginctl; do
  command -v "$cmd" >/dev/null || { echo "Comando ausente: $cmd" >&2; exit 1; }
done
python3 - <<'PY_VERIFY'
from pathlib import Path
import json,shlex,shutil
h=Path.home(); actions=json.loads('['+(h/'.config/wlogout/layout').read_text()+']')
expected={'lock':['/usr/bin/swaylock','-f','-c','303446'],'logout':['/usr/bin/swaymsg','exit'],'shutdown':['/usr/bin/loginctl','poweroff'],'reboot':['/usr/bin/loginctl','reboot']}
assert {a['label']:shlex.split(a['action']) for a in actions}==expected
for cmd in expected.values(): assert Path(cmd[0]).is_file(),cmd
for p in ['.config/sway/config','.config/foot/foot.ini','.config/starship-nord.toml','.config/fastfetch/config.jsonc','.local/bin/random-wallpaper.sh','.bin','.aliases-cento_os']:
 assert (h/p).exists(),p
print('wlogout: quatro comandos conferidos; configuracoes presentes')
PY_VERIFY
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate --config "$HOME/.config/sway/config"
systemctl is-enabled sddm
sessions=$(find /usr/share/wayland-sessions /usr/share/xsessions -maxdepth 1 -name '*.desktop' 2>/dev/null)
[[ $(echo "$sessions" | grep -c .) -eq 1 ]]
grep -q '^Name=Sway$' /usr/share/wayland-sessions/sway.desktop
systemctl get-default | grep -q graphical
cat "$HOME/.local/state/sway-cento_os/modules.tsv"
log 'Verificacao concluida; desligamento e reinicio nao foram executados.'
