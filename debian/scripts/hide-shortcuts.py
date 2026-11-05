#!/usr/bin/env python3
"""Hide selected launchers through per-user desktop overrides."""
from pathlib import Path
import configparser, datetime, json, shutil, subprocess

base = Path(__file__).resolve().parents[1]
destination = Path.home()/'.local/share/applications'
destination.mkdir(parents=True, exist_ok=True)
backup = Path.home()/'.local/state/sway-debian/backups'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')/'applications'
for pattern in json.loads((base/'manifests/hidden-shortcuts.json').read_text()):
    sources = {}
    for folder in (Path('/usr/share/applications'), Path('/usr/local/share/applications')):
        sources.update({path.name: path for path in folder.glob(pattern)})
    for name, source in sources.items():
        target = destination/name
        data = configparser.ConfigParser(interpolation=None, strict=False)
        data.optionxform = str
        data.read(target if target.exists() else source, encoding='utf-8')
        if not data.has_section('Desktop Entry'):
            raise SystemExit(f'Atalho inválido: {source}')
        if target.exists() and data['Desktop Entry'].get('NoDisplay', '').lower() == 'true':
            continue
        if target.exists():
            backup.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, backup/name)
        data['Desktop Entry']['NoDisplay'] = 'true'
        with target.open('w', encoding='utf-8', newline='\n') as output:
            data.write(output, space_around_delimiters=False)
        print(f'Oculto: {name}')
subprocess.run(['update-desktop-database', str(destination)], check=True)
