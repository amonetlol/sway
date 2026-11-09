#!/usr/bin/env bash
# As configs vêm do sway-full. Não há cópia própria nesta pasta.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$here/../sway-full/install-sway.sh" ]] || { echo "Não encontrei sway-full." >&2; exit 1; }
bash "$here/../sway-full/install-sway.sh"

python3 - <<'PY_POLKIT'
from pathlib import Path
import subprocess, re, datetime, shutil
paths = subprocess.check_output(['dpkg', '-L', 'mate-polkit'], text=True).splitlines()
agent = next(p for p in paths if p.endswith('/polkit-mate-authentication-agent-1') and Path(p).is_file())
config = Path.home()/'.config/sway/config'
text = config.read_text()
text = re.sub(r'^exec(?:_always)? .*polkit-gnome-authentication-agent-1.*$', 'exec '+agent, text, flags=re.M)
config.write_text(text)
backup = Path.home()/'.local/state/sway-full/backups'/('desktop-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
for name in ['display-im7.q16.desktop', 'org.freedesktop.IBus.Setup.desktop']:
    source = Path('/usr/share/applications')/name
    target = Path.home()/'.local/share/applications'/name
    if not source.exists():
        continue
    if target.exists():
        backup.mkdir(parents=True, exist_ok=True)
        shutil.copy2(target, backup/name)
    text = target.read_text() if target.exists() else source.read_text()
    text = re.sub(r'^NoDisplay=.*\n?', '', text, flags=re.M)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text.replace('[Desktop Entry]', '[Desktop Entry]\nNoDisplay=true', 1))
PY_POLKIT
python3 - <<'PY_WLOGOUT'
from pathlib import Path
import subprocess
layout = Path.home()/'.config/wlogout/layout'
text = layout.read_text()
help_text = subprocess.run(['loginctl', '--help'], text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout
changed = text
if 'poweroff' not in help_text:
    changed = changed.replace('/usr/bin/loginctl poweroff', '/usr/bin/systemctl poweroff')
if 'reboot' not in help_text:
    changed = changed.replace('/usr/bin/loginctl reboot', '/usr/bin/systemctl reboot')
if changed != text:
    layout.write_text(changed)
    print('[OK] wlogout usa systemctl para desligar e reiniciar.')
PY_WLOGOUT
update-desktop-database "$HOME/.local/share/applications" || true
if [[ -f "$HOME/.cache/rofi3.druncache" ]]; then rm -f "$HOME/.cache/rofi3.druncache"; fi
