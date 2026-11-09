#!/usr/bin/env python3
from pathlib import Path
import os
import shutil
import sys

src = Path(sys.argv[1])
dest = Path.home() / '.local/bin'
for item in src.rglob('*'):
    target = dest / item.relative_to(src)
    if item.is_dir():
        target.mkdir(parents=True, exist_ok=True)
    elif item.is_file() and not target.exists():
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(item, target)
        target.chmod(target.stat().st_mode | 0o100)

aliases = Path.home() / '.aliases-alpine'
if not aliases.exists():
    aliases.write_text('''# Aliases Alpine equivalentes aos aliases Arch.
alias up2='doas apk update && doas apk upgrade'
alias yay='apk'
alias yin='doas apk add'
alias yse='apk search'
alias ysel='apk info | grep -i'
alias yre='doas apk del'
alias yinfo='apk info -a'
alias cls='doas apk cache clean'
alias rpac='doas micro /etc/apk/repositories'
alias orf='apk info --orphaned'
''')
bashrc = Path.home() / '.bashrc'
if bashrc.exists():
    text = bashrc.read_text()
    marker = '# Aliases Alpine ORCA'
    if marker not in text:
        bashrc.write_text(text + '\n' + marker + '\n[ ! -f "$HOME/.aliases-alpine" ] || . "$HOME/.aliases-alpine"\n')

network = dest / 'rofi-network-menu'
network.write_text('''#!/bin/sh
if command -v nmcli >/dev/null 2>&1 && nmcli -t -f RUNNING general 2>/dev/null | grep -qx running; then
  choice=$(nmcli -g NAME connection show | rofi -dmenu -i -p 'Conexão de rede') || exit 0
  [ -n "$choice" ] && nmcli connection up id "$choice"
else
  { ip -br address; printf '\\nRota padrão:\\n'; ip route show default; } | rofi -dmenu -i -p 'Rede (status)'
fi
''')
network.chmod(0o755)
