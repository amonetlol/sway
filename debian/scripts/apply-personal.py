#!/usr/bin/env python3
"""Merge the latest personal dotfiles with the Debian/Sway adaptations."""
from pathlib import Path
import datetime, re, shutil, sys
cache, base = map(Path, sys.argv[1:])
home = Path.home()
stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')

def backup(path):
    if path.exists() or path.is_symlink():path.rename(path.with_name(path.name + '.bak-' + stamp))

target = home / '.config/kitty-tab'
backup(target)
shutil.copytree(cache/'goodies/kitty-tab', target)
config = (target/'kitty.conf').read_text(encoding='utf-8-sig').replace('@CONFIG@', str(target))
config = re.sub(r'(?m)^\s*font_family[^\n]*', 'font_family CodeNewRoman Nerd Font', config, count=1)
config = re.sub(r'(?m)^tab_bar_min_tabs\s+\d+', 'tab_bar_min_tabs 1', config)
(target/'kitty.conf').write_text(config)
(target/'show-hotkeys').chmod(0o755)
kitty = home/'.config/kitty'
shutil.copy2(kitty/'kitty.conf', kitty/'kitty-base.conf')
shutil.copytree(target, kitty, dirs_exist_ok=True)
(kitty/'kitty.conf').write_text(config.replace(str(target), str(kitty)))
bin_dir = home/'.local/bin'
bin_dir.mkdir(parents=True, exist_ok=True)
def executable(name, text):
    path=bin_dir/name;path.write_text(text);path.chmod(0o755)
executable('kitty', '#!/bin/sh\nexec /usr/bin/kitty -o linux_display_server=x11 "$@"\n')
executable('kitty-tab', '#!/bin/sh\nexec /usr/bin/kitty -o linux_display_server=x11 --config "$HOME/.config/kitty/kitty.conf" "$@"\n')
executable('nautilus', '#!/bin/sh\nexec /usr/bin/nautilus "$@"\n')
nvim = home/'.config/nvim'
backup(nvim)
shutil.copytree(cache/'nvim', nvim, ignore=shutil.ignore_patterns('.git'))
for name, command in [('fd','/usr/bin/fdfind'), ('bat','/usr/bin/batcat')]:
    path=bin_dir/name
    if path.is_symlink() or path.is_file():path.unlink()
    path.symlink_to(command)
aliases = home/'.aliases'
text = aliases.read_text().replace("alias tx='gnome-text-editor'", "alias tx='mousepad'")
text = text.replace('nvim ~/.bashrc ~/.aliases ~/.aliases-arch ~/.functions', 'nvim ~/.bashrc ~/.aliases ~/.aliases-debian ~/.functions')
text = text.replace('sudo grub-mkconfig -o /boot/grub/grub.cfg', 'sudo /usr/sbin/update-grub')
aliases.write_text(text)
for name, module in [('hide-shortcuts','hide-shortcuts'), ('recover-shortcuts','recovery-shortcuts'), ('recovery-shortcuts','recovery-shortcuts')]:
    executable(name, '#!/bin/sh\nexec bash "$HOME/.cache/sway-debian/upstream/sh/modules/'+module+'.sh" "$@"\n')
# Upstream mon stays in ~/.bin; add a Sway entry point without freezing that source.
executable('mon', '''#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" != --sway ]] && ! pgrep -u "$(id -u)" -x sway >/dev/null; then
 exec "$HOME/.bin/mon" "$@"
fi
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export SWAYSOCK="${SWAYSOCK:-$(find "$XDG_RUNTIME_DIR" -maxdepth 1 -type s -name 'sway-ipc.*.sock' -print -quit)}"
python3 - <<'PY'
import json, subprocess
outputs=json.loads(subprocess.check_output(['swaymsg','-t','get_outputs','-r']))
active=[o for o in outputs if o.get('active')]
if not active:raise SystemExit('Nenhum monitor Sway ativo')
output=next((o for o in active if o.get('focused')),active[0])
mode=output.get('current_mode',{})
target='1600x900' if (mode.get('width'),mode.get('height'))==(1920,1080) else '1920x1080'
reply=json.loads(subprocess.check_output(['swaymsg','-r','output',output['name'],'mode',target]))
if not all(r.get('success') for r in reply):raise SystemExit(str(reply))
print(target)
PY
''')
