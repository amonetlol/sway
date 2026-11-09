#!/usr/bin/env bash
# As configs vêm do sway-full. Não há cópia própria nesta pasta.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/../sway-full/install-sway.sh" ]] || { echo "Não encontrei sway-full." >&2; exit 1; }
bash "$here/../sway-full/install-sway.sh"

# Adaptacoes locais para ferramentas ausentes no repositorio Solus.
python3 - <<'PY_SOLUS'
from pathlib import Path
home = Path.home()
# Adapte somente o layout instalado no Solus; preserve o arquivo compartilhado.
import json
layout = home/'.config/wlogout/layout'
entries = json.loads('[' + layout.read_text() + ']')
for entry in entries:
    if entry.get('label') == 'lock':
        entry['action'] = 'swaylock -f -c 303446'
    elif entry.get('label') == 'logout':
        entry['action'] = 'swaymsg exit'
layout.write_text(',\n'.join(json.dumps(entry, ensure_ascii=False, indent=2) for entry in entries) + '\n')
config = home/'.config/sway/config'
s = config.read_text()
s = s.replace('swaybg_command -', 'swaybg_command /usr/bin/swaybg')
replacements = {
'swayosd-client --output-volume raise 5': 'wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+',
'swayosd-client --output-volume lower 5': 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-',
'swayosd-client --output-volume mute-toggle': 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle',
'swayosd-client --input-volume mute-toggle': 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle',
'swayosd-client --brightness raise 5': 'light -A 5',
'swayosd-client --brightness lower 5': 'light -U 5',
}
for old, new in replacements.items(): s = s.replace(old, new)
s = '\n'.join(line for line in s.splitlines() if 'swayosd-' not in line)+'\n'
config.write_text(s)
launcher=home/'.local/bin/start-sway-full'
s=launcher.read_text()
s=s.replace('  export WLR_NO_HARDWARE_CURSORS=1', '  export WLR_NO_HARDWARE_CURSORS=1\n  export XWAYLAND_NO_GLAMOR=1')
launcher.write_text(s)
init=home/'.local/bin/sway-session-init'
s=init.read_text();s=s.replace('  systemctl --user restart awww.service || true\n','')
init.write_text(s)
unit=home/'.config/systemd/user/sway-session.target'
unit.write_text(unit.read_text().replace('Wants=awww.service randow-wallpapers.timer','Wants=randow-wallpapers.timer'))
unit=home/'.config/systemd/user/randow-wallpapers.service'
unit.write_text(unit.read_text().replace('Requires=awww.service\n','').replace('After=awww.service\n',''))
PY_SOLUS
cat > "$HOME/.local/bin/random-wallpaper.sh" <<'WALLPAPER'
#!/usr/bin/env bash
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
wallpaper=${1:-$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n1)}
[[ -f "$wallpaper" ]] || { echo 'Wallpaper nao encontrado' >&2; exit 1; }
# swaymsg usa JSON para preservar caminhos com espacos e aspas.
command=$(python3 -c 'import json,sys; print("output * bg " + json.dumps(sys.argv[1]) + " fill")' "$wallpaper")
swaymsg "$command"
WALLPAPER
chmod +x "$HOME/.local/bin/random-wallpaper.sh"
systemctl --user daemon-reload
