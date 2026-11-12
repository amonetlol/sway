#!/usr/bin/env bash
# Executar como pio no Garuda. A renderizacao passa a valer no proximo login.
set -euo pipefail
python3 - <<'PYFIX'
from pathlib import Path
import stat
for f in (Path.home()/'.local/bin').iterdir():
 if f.is_file() and not f.is_symlink():
  with f.open('rb') as fp: is_script=fp.read(2)==b'#!'
  if is_script: f.chmod(f.stat().st_mode | stat.S_IXUSR)
PYFIX
if ! sudo grep -q '^WLR_RENDERER=' /etc/environment; then
 printf 'WLR_RENDERER=pixman\n' | sudo tee -a /etc/environment >/dev/null
fi
