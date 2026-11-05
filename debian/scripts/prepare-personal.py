#!/usr/bin/env python3
"""Apply Debian/Sway adjustments to the current upstream modules."""
from pathlib import Path
import sys
source, target = map(Path, sys.argv[1:])
for name in ('bash', 'btop', 'fastfetch', 'kitty', 'hide-shortcuts', 'recovery-shortcuts', 'random-wallpapers'):
    text = (source / f'{name}.sh').read_text(encoding='utf-8-sig')
    if name == 'random-wallpapers':
        text = text.replace('OnBootSec=2min', 'OnStartupSec=15s').replace('OnUnitActiveSec=5min', 'OnUnitActiveSec=90s')
        start = text.index('    command -v awww >/dev/null')
        end = text.index('\n}', start)
        text = text[:start] + '''    export SWAYSOCK="${SWAYSOCK:-$(find "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" -maxdepth 1 -type s -name 'sway-ipc.*.sock' -print -quit)}"
    if grep -qx 'BACKEND=quickshell' "$HOME/.config/sway/current/theme.conf"; then
      "$HOME/.config/sway/themes/2SSk/runtime/bin/desktop" wallpaper set "$wallpaper"
    else
      swaymsg output '*' bg "$wallpaper" fill >/dev/null
    fi
''' + text[end:]
        # Install units even when there is no running user manager yet.
        anchor = 'systemctl --user daemon-reload'
        assert anchor in text
        text = text.replace(anchor, '''if [[ ! -S "$XDG_RUNTIME_DIR/bus" ]]; then
 mkdir -p "$UNIT_DIR/timers.target.wants"
 ln -sfn ../random-wallpaper.timer "$UNIT_DIR/timers.target.wants/random-wallpaper.timer"
 exit 0
fi
''' + anchor, 1)
    (target / f'{name}.sh').write_text(text, encoding='utf-8', newline='\n')
