#!/usr/bin/env python3
"""Preserve existing DNF options and configure parallel downloads."""
import configparser, datetime, pathlib, shutil
path=pathlib.Path('/etc/dnf/dnf.conf')
backup=pathlib.Path('/var/backups/sway-fedora/dnf')
backup.mkdir(parents=True,exist_ok=True)
if path.exists(): shutil.copy2(path,backup/('dnf.conf.'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')))
config=configparser.ConfigParser(interpolation=None,strict=False)
config.read(path)
if not config.has_section('main'): config.add_section('main')
config['main']['max_parallel_downloads']='10'
config['main']['fastestmirror']='False'
with path.open('w') as stream: config.write(stream)
print('DNF: 10 parallel downloads; Fedora metalink mirror selection.')
