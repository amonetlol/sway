#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 - "$ROOT" <<'PY'
from pathlib import Path
import datetime
import shutil
import sys

source = Path(sys.argv[1])
home = Path.home()
target = home / '.config/kitty-tab'
stamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
if target.exists():
    target.rename(str(target) + '.bak.' + stamp)
shutil.copytree(source, target)
config = target / 'kitty.conf'
config.write_text(config.read_text().replace('@CONFIG@', str(target)))
(target / 'show-hotkeys').chmod(0o755)
launcher = home / '.local/bin/kitty-tab'
launcher.parent.mkdir(parents=True, exist_ok=True)
if launcher.exists():
    shutil.copy2(launcher, str(launcher) + '.bak.' + stamp)
launcher.write_text('#!/usr/bin/env bash\nexport KITTY_CONFIG_DIRECTORY="$HOME/.config/kitty-tab"\nexec /usr/bin/kitty --config "$KITTY_CONFIG_DIRECTORY/kitty.conf" "$@"\n')
launcher.chmod(0o755)
print('Instalado:', target)
print('Abra com:', launcher)
PY
