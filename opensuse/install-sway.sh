#!/usr/bin/env bash
# As configs vêm do sway-full. Não há cópia própria nesta pasta.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/../sway-full/install-sway.sh" ]] || { echo "Não encontrei sway-full." >&2; exit 1; }
bash "$here/../sway-full/install-sway.sh"

# SwayOSD 0.3 recebe a mudanca de volume/brilho sem argumento extra.
python3 - <<'PY'
from pathlib import Path
import re
p = Path.home() / '.config/sway/config'
s = p.read_text()
s = re.sub(r'(swayosd-client --(?:output-volume|brightness) (?:raise|lower)) 5', r'\1', s)
s = s.replace('bindsym $mod+m exec', 'bindsym --no-repeat $mod+m exec')
s = s.replace('include /etc/sway/config.d/*', '# openSUSE system defaults omitted for sway-full')
p.write_text(s)
PY
