#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageOps
import hashlib, json, random, subprocess, sys
folder=Path.home()/'Imagens/wallpapers'
if len(sys.argv)>1: image=Path(sys.argv[1]).expanduser().resolve()
else:
 images=[p for p in folder.rglob('*') if p.is_file() and p.suffix.lower() in ('.png','.jpg','.jpeg','.webp')]
 if not images: raise SystemExit('Nenhum wallpaper encontrado')
 image=random.choice(images)
if not image.is_file(): raise SystemExit('Wallpaper nao encontrado')
cache=Path.home()/'.cache/sway-mocaccino/wallpapers'; cache.mkdir(parents=True,exist_ok=True)
key=hashlib.sha256((str(image)+str(image.stat().st_mtime_ns)+str(image.stat().st_size)).encode()).hexdigest()
output=cache/(key+'.png')
if not output.is_file():
 with Image.open(image) as img:
  img.draft('RGB',(1920,1080))
  img=ImageOps.exif_transpose(img).convert('RGB')
  img.thumbnail((1920,1080),Image.Resampling.LANCZOS)
  temp=cache/(key+'.tmp.png'); img.save(temp,'PNG',compress_level=3); temp.replace(output)
subprocess.run(['swaymsg','-q','output * bg '+json.dumps(str(output),ensure_ascii=False)+' fill'],check=True)
