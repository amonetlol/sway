from pathlib import Path
import colorsys,configparser,io,os,re,subprocess,time

def icons(profile,family,mode,accent):
 name='2SSk-'+family+'-'+mode
 dest=profile/'icons'/name
 base=Path('/usr/share/icons/Tela-circle-blue-'+mode)
 if not dest.exists():
  dest.mkdir(parents=True)
  def hls(c):return colorsys.rgb_to_hls(*(int(c[i:i+2],16)/255 for i in (1,3,5)))
  ah,al,ats=hls(accent);_,rl,rs=hls('#5677fc')
  al=max(.35,min(.62,al));ats=max(.35,ats)
  def recolor(m):
   ch,cl,cs=hls(m[0])
   if not (.50<=ch<=.76 and cs>.25):return m[0]
   rgb=colorsys.hls_to_rgb(ah,max(.12,min(.80,cl+al-rl)),min(1,cs*ats/rs))
   return '#%02x%02x%02x'%tuple(round(c*255) for c in rgb)
  dirs=[]
  for source in base.glob('*/places'):
   # Resolve symlinks into local files so generic folder aliases keep the palette.
   rel=source.relative_to(base);out=dest/rel;out.mkdir(parents=True,exist_ok=True);dirs.append(str(rel))
   for svg in source.glob('*.svg'):
    if svg.is_file():(out/svg.name).write_text(re.sub(r'#[0-9a-fA-F]{6}\b',recolor,svg.read_text()))
  cfg=configparser.RawConfigParser(strict=False);cfg.optionxform=str;cfg.read(base/'index.theme')
  cfg.set('Icon Theme','Name',name);cfg.set('Icon Theme','Inherits',base.name)
  cfg.set('Icon Theme','Directories',','.join(d for d in dirs if '@' not in d))
  cfg.set('Icon Theme','ScaledDirectories',','.join(d for d in dirs if '@' in d))
  stream=io.StringIO();cfg.write(stream,space_around_delimiters=False);(dest/'index.theme').write_text(stream.getvalue())
  subprocess.run(['gtk-update-icon-cache','-q','-f','-t',str(dest)],check=True)
 link=Path.home()/'.local/share/icons'/name;link.parent.mkdir(parents=True,exist_ok=True)
 if not link.exists():link.symlink_to(dest,target_is_directory=True)
 return name

def refresh_nautilus():
 if subprocess.run(['pgrep','-u',str(os.getuid()),'-x','nautilus'],stdout=subprocess.DEVNULL).returncode:return
 result=subprocess.run(['gdbus','call','--session','--dest','org.freedesktop.FileManager1','--object-path','/org/freedesktop/FileManager1','--method','org.freedesktop.DBus.Properties.Get','org.freedesktop.FileManager1','OpenLocations'],text=True,capture_output=True)
 uris=re.findall(r"'((?:file|trash|recent|network|smb|sftp)://[^']*)'",result.stdout)
 if not uris:return # Preserve existing windows if their locations cannot be recovered.
 subprocess.run(['nautilus','--quit'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 for _ in range(30):
  if subprocess.run(['pgrep','-u',str(os.getuid()),'-x','nautilus'],stdout=subprocess.DEVNULL).returncode:break
  time.sleep(.1)
 else:return
 subprocess.Popen(['nautilus','--new-window',*dict.fromkeys(uris)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,start_new_session=True)
