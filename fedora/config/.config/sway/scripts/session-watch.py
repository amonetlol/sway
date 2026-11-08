#!/usr/bin/env python3
import signal,subprocess
from pathlib import Path
root=Path.home()/'.config/sway'
def stop(*_):raise SystemExit
signal.signal(signal.SIGTERM,stop)
try:
 with subprocess.Popen(['swaymsg','-m','-t','subscribe','["shutdown"]'],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True) as child:
  for line in child.stdout:
   if '"change"' in line and 'exit' in line:break
  if child.poll() is None:child.terminate()
finally:
 subprocess.run([str(root/'scripts/set_theme.sh'),'--restore-session'],check=False)
 subprocess.run(['systemctl','--user','--no-block','stop','sway-themed-session.target','xdg-desktop-portal.service','sway-session.target'],check=False)
