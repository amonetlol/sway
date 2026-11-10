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
for p in ['.config/sway/config','.config/foot/foot.ini','.config/starship-nord.toml','.config/fastfetch/config.jsonc','.local/bin/random-wallpaper.sh','.bin']:
 assert (h/p).exists(),p
for p in ['.local/share/applications/org.fontforge.FontForge.desktop','.local/share/applications/xcalib.desktop']:
 assert (h/p).is_file() and 'NoDisplay=true' in (h/p).read_text(),p
if Path('/usr/share/applications/Gentoo-system-config-printer.desktop').exists():
 p=h/'.local/share/applications/Gentoo-system-config-printer.desktop'
 assert p.is_file() and 'NoDisplay=true' in p.read_text(),p
print('wlogout: quatro comandos conferidos; configuracoes presentes')
PY_VERIFY
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate --config "$HOME/.config/sway/config"
rc-service swayosd-libinput-backend status
if grep -qi vmware /sys/class/dmi/id/sys_vendor 2>/dev/null; then
  command -v vmware-user-suid-wrapper >/dev/null
  rc-service vmware-tools status
fi
[[ $(find /usr/local/share/wayland-sessions /usr/local/share/xsessions -maxdepth 1 -name '*.desktop' | wc -l) -eq 1 ]]
grep -q '^Name=Sway$' /usr/local/share/wayland-sessions/sway.desktop
grep -q '^DISPLAYMANAGER="sddm"' /etc/conf.d/display-manager
cat "$HOME/.local/state/sway-calculate/modules.tsv"
log 'Verificacao concluida; desligamento e reinicio nao foram executados.'
