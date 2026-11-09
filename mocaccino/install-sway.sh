#!/usr/bin/env bash
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ -f "$here/../sway-full/install-sway.sh" ]] || { echo 'A pasta sway-full e necessaria.' >&2; exit 1; }
status=0
bash "$here/../sway-full/install-sway.sh" || status=$?
# loginctl nao implementa poweroff/reboot; use systemctl.
python3 - <<'PY'
from pathlib import Path
p=Path.home()/'.config/wlogout/layout'
s=p.read_text().replace('/usr/bin/loginctl poweroff','/usr/bin/systemctl poweroff').replace('/usr/bin/loginctl reboot','/usr/bin/systemctl reboot')
p.write_text(s)
PY
python3 - <<'PY'
from pathlib import Path
p=Path.home()/'.config/sway/config'
s=p.read_text()
for a,b in {
 'swayosd-client --output-volume raise 5':'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+',
 'swayosd-client --output-volume lower 5':'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-',
 'swayosd-client --output-volume mute-toggle':'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle',
 'swayosd-client --input-volume mute-toggle':'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle',
 'exec swayosd-server':'# swayosd indisponivel no Mocaccino',
 'bindsym $mod+e exec ~/.local/bin/nautilus-sway':'bindsym $mod+e exec thunar',
 '    xkb_variant abnt2\n':'',
 '    xkb_model pc105\n':'    xkb_model abnt2\n',
}.items(): s=s.replace(a,b)
p.write_text(s)
p=Path.home()/'.local/bin/start-sway-full'
s=p.read_text()
old='  export WLR_NO_HARDWARE_CURSORS=1\n'
if old in s and 'export WLR_RENDERER=pixman' not in s:
    p.write_text(s.replace(old,old+'  export WLR_RENDERER=pixman\n',1))
PY
bash "$here/install-adjustments.sh"
exit "$status"
