#!/usr/bin/env python3
from pathlib import Path
import hashlib, subprocess
root=Path(__file__).resolve().parent
folder=Path.home()/'Imagens/wallpapers'; cache=Path.home()/'.cache/sway-mocaccino/thumbnails'
images=sorted(p for p in folder.rglob('*') if p.is_file() and p.suffix.lower() in ('.png','.jpg','.jpeg','.webp') and '\n' not in str(p))
if not images: raise SystemExit('Nenhum wallpaper encontrado em '+str(folder))
rows=[]
for image in images:
 key=hashlib.sha256((str(image.resolve())+str(image.stat().st_mtime_ns)+str(image.stat().st_size)).encode()).hexdigest()
 thumb=cache/(key+'.png')
 rows.append(str(image.relative_to(folder)) + ('\0icon\x1f'+str(thumb) if thumb.is_file() else '')+'\n')
r=subprocess.run(['rofi','-config',str(root/'config.rasi'),'-theme',str(root/'wallpaper.rasi'),'-dmenu','-show-icons','-i','-p','Wallpaper','-format','i','-no-custom'],input=''.join(rows),text=True,stdout=subprocess.PIPE)
if r.returncode or not r.stdout.strip(): raise SystemExit(0)
subprocess.run([str(Path.home()/'.local/bin/random-wallpaper.sh'),str(images[int(r.stdout)])],check=True)
