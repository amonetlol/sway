#!/usr/bin/env python3
"""Atalhos locais e provedores de portal, sem caminhos de usuario fixos."""
from pathlib import Path
import re
import subprocess
import shutil
import sys

home = Path.home()
apps = home / '.local/share/applications'
apps.mkdir(parents=True, exist_ok=True)
backup = Path(sys.argv[1])
def save(path):
    if path.exists():
        target = backup / path.relative_to(home)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
for filename, binary, launcher in [
    ('kitty.desktop', 'kitty', 'kitty-sway'),
    ('org.gnome.Nautilus.desktop', 'nautilus', 'nautilus-sway'),
    ('org.pulseaudio.pavucontrol.desktop', 'pavucontrol', 'pavucontrol'),
]:
    source = Path('/usr/share/applications') / filename
    if not source.exists():
        continue
    text = re.sub(r'^Exec=(?:/usr/bin/)?' + re.escape(binary) + r'\b',
                  f'Exec={home}/.local/bin/{launcher}', source.read_text(), flags=re.M)
    save(apps / filename)
    (apps / filename).write_text(text.replace('DBusActivatable=true', 'DBusActivatable=false'))
for name in ['rofi.desktop', 'rofi-theme-selector.desktop', 'stoken-gui.desktop', 'stoken-gui-small.desktop']:
    source = Path('/usr/share/applications') / name
    if source.exists():
        save(apps / name)
        text = re.sub(r'^NoDisplay=.*\n', '', source.read_text(), flags=re.M)
        (apps / name).write_text(text.replace('[Desktop Entry]', '[Desktop Entry]\nNoDisplay=true', 1))
portals = home / '.config/xdg-desktop-portal'
portals.mkdir(parents=True, exist_ok=True)
save(portals / 'sway-portals.conf')
(portals / 'sway-portals.conf').write_text(
    '[preferred]\ndefault=gtk\norg.freedesktop.impl.portal.ScreenCast=wlr\n'
    'org.freedesktop.impl.portal.Screenshot=wlr\n')
subprocess.run(['update-desktop-database', str(apps)], check=True)
