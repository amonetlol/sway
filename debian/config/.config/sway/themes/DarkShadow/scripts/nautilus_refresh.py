from pathlib import Path
import os,re,subprocess,time

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
