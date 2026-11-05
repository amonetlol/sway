#!/usr/bin/env python3
"""Sway owns GTK/session setup; update only the theme palette here."""
from pathlib import Path
import subprocess, sys
p=Path(__file__).resolve().parent
if '--wallpaper-only' not in sys.argv:
 subprocess.run([sys.executable,str(p/'palette.py')],check=False)
