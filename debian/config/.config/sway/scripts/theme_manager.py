#!/usr/bin/env python3
import argparse,base64,configparser,fcntl,io,json,os,re,subprocess,sys,tempfile
from pathlib import Path
from datetime import datetime
HOME=Path.home(); ROOT=HOME/'.config/sway'; THEMES=ROOT/'themes'; CURRENT=ROOT/'current'
STATE=HOME/'.local/state/sway-themes'; SCHEMA='org.gnome.desktop.interface'
KEYS=('gtk-theme','icon-theme','cursor-theme','cursor-size','font-name','color-scheme')
BASEFILES=[HOME/'.config'/v/f for v in ('gtk-3.0','gtk-4.0') for f in ('settings.ini','gtk.css','sway-theme.css')]+[HOME/'.config/xsettingsd/xsettingsd.conf']
def run(args,check=True,**kwargs):
 p=subprocess.run(args,text=True,capture_output=True,**kwargs)
 if check and p.returncode:raise RuntimeError((p.stderr or p.stdout or str(args)).strip())
 return p.stdout.strip()
def meta(theme):
 out={}
 for line in (theme/'theme.conf').read_text().splitlines():
  if not line.strip() or line.lstrip().startswith('#'):continue
  k,sep,v=line.partition('=')
  if not sep or not re.fullmatch('[A-Z_]+',k):raise ValueError('theme.conf invalido')
  out[k]=v.strip()
 for k in ('GTK_THEME','ICON_THEME','CURSOR_THEME','CURSOR_SIZE','FONT','FONT_SIZE','COLOR_SCHEME','COMPOSITOR'):
  if not out.get(k):raise ValueError('Campo ausente: '+k)
 if out['COMPOSITOR'] not in ('sway','swayfx'):raise ValueError('COMPOSITOR deve ser sway ou swayfx')
 out.setdefault('BACKEND','waybar')
 if out['BACKEND'] not in ('waybar','quickshell'):raise ValueError('BACKEND invalido')
 if not 1<=int(out['CURSOR_SIZE'])<=256 or not 1<=float(out['FONT_SIZE'])<=200:raise ValueError('Tamanho invalido')
 return out
def validate(name,full=False):
 if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]*',name):raise ValueError('Nome invalido')
 t=THEMES/name
 if not t.is_dir() or t.resolve().parent!=THEMES.resolve():raise ValueError('Tema inexistente')
 m=meta(t)
 required=('theme.conf','sway.conf','binds.conf','rofi/main.rasi','rofi/power.rasi','swaylock/config')
 required+=('quickshell/shell.qml','scripts/run-shell.sh') if m['BACKEND']=='quickshell' else ('waybar/config','waybar/style.css','swaync/config.json','swaync/style.css')
 for f in required:
  if not (t/f).is_file():raise ValueError('Arquivo ausente: '+f)
 if m['BACKEND']=='waybar':
  bars=json.loads((t/'waybar/config').read_text())
  if not isinstance(bars,(dict,list)):raise ValueError('Waybar config invalido')
  json.loads((t/'swaync/config.json').read_text())
 for key,folder in [('GTK_THEME','themes'),('ICON_THEME','icons'),('CURSOR_THEME','icons')]:
  if not any((p/m[key]).is_dir() for p in [HOME/'.local/share'/folder,Path('/usr/share')/folder,Path('/usr/local/share')/folder]):raise ValueError('Recurso nao instalado: '+m[key])
 if full:
  config=(ROOT/'config').read_text().replace('~/.config/sway/current/',str(t)+'/')
  with tempfile.NamedTemporaryFile('w',suffix='.conf',dir=ROOT/'scripts') as f:
   f.write(config);f.flush()
   env=dict(os.environ,WLR_BACKENDS='headless',WLR_RENDERER='pixman')
   run(['sway','--validate','--config',f.name],env=env)
 return t,m
def capture(extra=()):
 return {'files':{str(p):base64.b64encode(p.read_bytes()).decode() if p.exists() else None for p in BASEFILES+list(extra)},'gsettings':{k:run(['gsettings','get',SCHEMA,k]) for k in KEYS}}
def restore(state):
 for name,data in state['files'].items():
  p=Path(name);p.parent.mkdir(parents=True,exist_ok=True)
  if data is None:p.unlink(missing_ok=True)
  else:p.write_bytes(base64.b64decode(data))
 for k,v in state['gsettings'].items():run(['gsettings','set',SCHEMA,k,v],False)
 run(['pkill','-HUP','-u',str(os.getuid()),'-x','xsettingsd'],False)
def point(t):
 p=ROOT/'.current.next';p.unlink(missing_ok=True);p.symlink_to(os.path.relpath(t,ROOT));p.replace(CURRENT)
def running():
 sock=os.environ.get('SWAYSOCK','')
 return bool(sock and Path(sock).is_socket())
def reload_sway():
 answer=json.loads(run(['swaymsg','reload']))
 if not all(a.get('success') for a in answer):raise RuntimeError('Sway recusou a configuracao: '+str(answer))
def desktop(t,m):
 for version in ('gtk-3.0','gtk-4.0'):
  folder=HOME/'.config'/version;folder.mkdir(parents=True,exist_ok=True)
  ini=folder/'settings.ini';parser=configparser.RawConfigParser(strict=False);parser.optionxform=str
  source=t/'gtk'/version/'settings.ini'
  if source.exists():parser.read(source)
  elif ini.exists():parser.read(ini)
  if not parser.has_section('Settings'):parser.add_section('Settings')
  fields={'gtk-theme-name':m['GTK_THEME'],'gtk-icon-theme-name':m['ICON_THEME'],'gtk-cursor-theme-name':m['CURSOR_THEME'],'gtk-cursor-theme-size':m['CURSOR_SIZE'],'gtk-font-name':m['FONT']+' '+m['FONT_SIZE'],'gtk-application-prefer-dark-theme':'1' if m['COLOR_SCHEME']=='prefer-dark' else '0'}
  for k,v in fields.items():parser.set('Settings',k,v)
  stream=io.StringIO();parser.write(stream,space_around_delimiters=False);ini.write_text(stream.getvalue())
  css=folder/'gtk.css';text=css.read_text() if css.exists() else ''
  text=re.sub(r'^@import url\("(?:hypr|sway)-theme\.css"\);\n?','',text,flags=re.M)
  source=t/'gtk'/version/'gtk.css'
  if not source.exists():source=t/'gtk/colors.css'
  managed=folder/'sway-theme.css'
  if source.exists():
   managed.write_bytes(source.read_bytes());text+='\n@import url("sway-theme.css");\n'
  else:managed.unlink(missing_ok=True)
  if text.strip():css.write_text(text.strip()+'\n')
  else:css.unlink(missing_ok=True)
 values={'gtk-theme':m['GTK_THEME'],'icon-theme':m['ICON_THEME'],'cursor-theme':m['CURSOR_THEME'],'cursor-size':int(m['CURSOR_SIZE']),'font-name':m['FONT']+' '+m['FONT_SIZE'],'color-scheme':m['COLOR_SCHEME']}
 for k,v in values.items():run(['gsettings','set',SCHEMA,k,str(v) if isinstance(v,int) else json.dumps(v)])
 xs=HOME/'.config/xsettingsd/xsettingsd.conf';xs.parent.mkdir(parents=True,exist_ok=True)
 text=xs.read_text() if xs.exists() else ''
 for k,v in {'Net/ThemeName':m['GTK_THEME'],'Net/IconThemeName':m['ICON_THEME'],'Gtk/CursorThemeName':m['CURSOR_THEME'],'Gtk/CursorThemeSize':int(m['CURSOR_SIZE']),'Gtk/FontName':m['FONT']+' '+m['FONT_SIZE']}.items():
  line=k+' '+(str(v) if isinstance(v,int) else json.dumps(v));pattern=r'^'+re.escape(k)+r'\s+.*$'
  text=re.sub(pattern,lambda _:line,text,flags=re.M) if re.search(pattern,text,re.M) else text.rstrip()+'\n'+line+'\n'
 xs.write_text(text);run(['pkill','-HUP','-u',str(os.getuid()),'-x','xsettingsd'],False)
 (ROOT/'theme-generated.conf').write_text('seat * xcursor_theme '+m['CURSOR_THEME']+' '+m['CURSOR_SIZE']+'\n')
def apply(name):
 t,m=validate(name,True);previous=CURRENT.resolve()
 if not running():
  point(t);print('Tema salvo para a proxima sessao Sway: '+name);return
 state=capture([ROOT/'theme-generated.conf']);STATE.mkdir(parents=True,exist_ok=True)
 backup=STATE/(datetime.now().strftime('%Y%m%d-%H%M%S-%f')+'.json');backup.write_text(json.dumps(state))
 try:
  point(t);desktop(t,m);reload_sway()
  run([str(ROOT/'scripts/sync-theme.py')])
 except Exception:
  point(previous);restore(state)
  try:reload_sway()
  except Exception:pass
  raise
 print('Tema Sway ativo: '+name)
def main():
 os.environ.setdefault('XDG_RUNTIME_DIR',f'/run/user/{os.getuid()}')
 os.environ.setdefault('DBUS_SESSION_BUS_ADDRESS',f'unix:path=/run/user/{os.getuid()}/bus')
 STATE.mkdir(parents=True,exist_ok=True)
 p=argparse.ArgumentParser();p.add_argument('theme',nargs='?');p.add_argument('--list',action='store_true');p.add_argument('--check');p.add_argument('--save-session',action='store_true');p.add_argument('--restore-session',action='store_true');args=p.parse_args()
 baseline=STATE/'session-baseline.json'
 if args.save_session:baseline.write_text(json.dumps(capture()));return
 if args.restore_session:
  if baseline.exists():restore(json.loads(baseline.read_text()));baseline.unlink()
  return
 if args.list:
  for t in sorted(THEMES.iterdir()):
   try:validate(t.name)
   except Exception:continue
   print(t.name+(' *' if CURRENT.resolve()==t.resolve() else ''))
  return
 if args.check:validate(args.check,True);print('Tema Sway valido: '+args.check);return
 name=args.theme
 if not name:
  if not running():raise RuntimeError('Abra o seletor dentro do Sway.')
  labels=[]
  for t in sorted(THEMES.iterdir()):
   try:validate(t.name)
   except Exception:continue
   labels.append(t.name+(' *' if CURRENT.resolve()==t.resolve() else ''))
  choice=subprocess.run(['rofi','-no-config','-dmenu','-i','-no-custom','-p','Tema Sway','-theme',str(CURRENT/'rofi/main.rasi')],input='\n'.join(labels)+'\n',text=True,capture_output=True)
  if choice.returncode or not choice.stdout.strip():return
  name=choice.stdout.strip().removesuffix(' *')
 with (STATE/'switch.lock').open('w') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB);apply(name)
if __name__=='__main__':
 try:main()
 except Exception as e:print('Erro: '+str(e),file=sys.stderr);sys.exit(1)
