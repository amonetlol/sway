#!/usr/bin/env python3
from pathlib import Path
import os, subprocess, time
root=Path(__file__).resolve().parent
folder=Path.home()/'Imagens/wallpapers'
images=sorted(p for p in folder.rglob('*') if p.is_file() and p.suffix.lower() in ('.png','.jpg','.jpeg','.webp') and '\n' not in str(p))
if not images: raise SystemExit('Nenhum wallpaper encontrado em '+str(folder))
rows=''.join(str(p.relative_to(folder))+'\0icon\x1f'+str(p)+'\n' for p in images)
r=subprocess.run(['rofi','-config',str(root/'config.rasi'),'-theme',str(root/'wallpaper.rasi'),'-dmenu','-show-icons','-i','-p','Wallpaper','-format','i','-no-custom'],input=rows,text=True,stdout=subprocess.PIPE)
if r.returncode or not r.stdout.strip(): raise SystemExit(0)
image=images[int(r.stdout)]
subprocess.run([str(Path.home()/'.local/bin/random-wallpaper.sh'),str(image)],check=True)
