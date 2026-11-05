#!/usr/bin/env python3
from pathlib import Path
import subprocess
root=Path.home()/'.config/sway'
backend='waybar'
for line in (root/'current/theme.conf').read_text().splitlines():
 if line.startswith('BACKEND='):backend=line.split('=',1)[1].strip()
external_polkit='POLKIT_AGENT=external' in (root/'current/theme.conf').read_text()
subprocess.run(['systemctl','--user', 'stop' if backend=='quickshell' and not external_polkit else 'start','sway-polkit.service'],check=False)
waybar=['sway-themed-waybar.service','sway-themed-notifications.service']
qs=['sway-themed-quickshell.service']
subprocess.run(['systemctl','--user','stop',*(waybar if backend=='quickshell' else qs)],check=True)
subprocess.run(['systemctl','--user','restart',*(qs if backend=='quickshell' else waybar)],check=True)
