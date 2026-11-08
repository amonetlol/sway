#!/usr/bin/env python3
import pathlib, re
path=pathlib.Path('/etc/default/grub')
text=path.read_text()
options={'GRUB_THEME':'"/boot/grub2/themes/leaf/theme.txt"','GRUB_GFXMODE':'"1920x1080,auto"','GRUB_TIMEOUT_STYLE':'menu','GRUB_TIMEOUT':'5','GRUB_TERMINAL_OUTPUT':'gfxterm'}
for key,value in options.items():
 pattern=r'(?m)^'+re.escape(key)+r'=.*$'
 if re.search(pattern,text): text=re.sub(pattern,key+'='+value,text)
 else: text+='\n'+key+'='+value+'\n'
path.write_text(text)
