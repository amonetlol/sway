#!/usr/bin/env python3
"""Install only missing official packages; no distribution-wide upgrades."""
from pathlib import Path
import hashlib, os, subprocess, sys, urllib.request

mirror = os.environ.get('SLACKWARE_MIRROR', 'https://mirrors.slackware.com/slackware/slackware64-current').rstrip('/')
cache = Path.home()/'.cache/sway-slackware/official'
cache.mkdir(parents=True, exist_ok=True)
index = urllib.request.urlopen(mirror+'/PACKAGES.TXT', timeout=45).read().decode()
checks = urllib.request.urlopen(mirror+'/CHECKSUMS.md5', timeout=45).read().decode()
md5 = {}
for line in checks.splitlines():
    fields=line.split()
    if len(fields)==2 and len(fields[0])==32: md5[fields[1].lstrip('*').removeprefix('./')]=fields[0]
packages={}
for block in index.split('\n\n'):
    lines=block.splitlines()
    if not lines or not lines[0].startswith('PACKAGE NAME:'): continue
    filename=lines[0].split(':',1)[1].strip()
    name=filename.rsplit('-',3)[0]
    location=next(l.split(':',1)[1].strip() for l in lines if l.startswith('PACKAGE LOCATION:'))
    packages[name]=(filename,location.removeprefix('./'))
installed={p.name.rsplit('-',3)[0] for p in Path('/var/lib/pkgtools/packages').iterdir()}
for name in sys.argv[1:]:
    if name in installed:
        print('Preservado pacote instalado:',name,flush=True);continue
    if name not in packages: raise SystemExit('Pacote oficial ausente: '+name)
    filename,location=packages[name]; relative=location+'/'+filename; dest=cache/filename
    if not dest.exists():
        print('Baixando pacote oficial:',filename,flush=True)
        with urllib.request.urlopen(mirror+'/'+relative,timeout=90) as r, dest.open('wb') as w:
            while chunk:=r.read(1024*1024): w.write(chunk)
    if hashlib.md5(dest.read_bytes()).hexdigest()!=md5.get(relative):
        dest.unlink();raise SystemExit('Checksum incorreto: '+filename)
    password=os.environ.get('INSTALL_SUDO_PASSWORD')
    args=['sudo']+(['-S','-p',''] if password else [])+['/sbin/upgradepkg','--install-new',str(dest)]
    subprocess.run(args,input=(password+'\n').encode() if password else None,check=True)
