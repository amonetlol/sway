#!/usr/bin/env python3
from pathlib import Path
import os,json,fcntl,subprocess,sys,re
P=Path(__file__).resolve().parents[1]
with (P/'cache/palette.lock').open('w') as lock:
 fcntl.flock(lock,fcntl.LOCK_EX)
 image=sys.argv[1] if len(sys.argv)>1 else ''
 if not image:
  try:
   query=subprocess.check_output(['awww','query'],text=True,stderr=subprocess.DEVNULL)
   m=re.search(r'image:\s*(.+)',query);image=m[1].strip() if m else ''
  except (subprocess.SubprocessError, OSError):pass
 if not image or not Path(image).is_file():
  image=next((str(f) for f in (Path.home()/'Imagens/wallpapers').glob('*') if f.suffix.lower() in ['.jpg','.png','.webp','.jpeg']),None)
 if not image:raise SystemExit('Nenhum wallpaper disponivel para a paleta.')
 env=dict(os.environ,PATH=str(P/'runtime/bin')+':'+os.environ.get('PATH','/usr/bin'))
 result=subprocess.run([str(P/'runtime/bin/rice-colors'),'scheme',subprocess.check_output([str(P/'runtime/bin/rice-colors'),'get'],env=env,text=True).strip()],env=env,text=True,capture_output=True)
 fields=result.stdout.split();scheme=fields[0] if fields else 'scheme-tonal-spot';seed=fields[1] if len(fields)>1 else ''
 command=[str(P/'runtime/bin/matugen'),'image',image,'--type',scheme,'--source-color-index','0','-q']
 if seed.startswith('#'):command+=['--source-color',seed]
 subprocess.run(command,env=env,check=True)
 (P/'cache/hyprquickpaper-current').write_text(image+'\n')
 print('DarkShadow: paleta gerada.')
