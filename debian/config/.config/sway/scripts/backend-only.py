#!/usr/bin/env python3
import os,sys
from pathlib import Path
root=Path.home()/'.config/sway'
backend='waybar'
for line in (root/'current/theme.conf').read_text().splitlines():
 if line.startswith('BACKEND='):backend=line.split('=',1)[1].strip()
sock=os.environ.get('SWAYSOCK','')
raise SystemExit(0 if sock and Path(sock).is_socket() and backend==sys.argv[1] else 1)
