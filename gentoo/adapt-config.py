#!/usr/bin/env python3
"""Adapta somente a copia instalada do sway-full para Gentoo/Foot/Micro."""
from pathlib import Path
import json,re,stat,shutil
home=Path.home()
for base in [home/'.local/bin',home/'.config/sway',home/'.config/rofi',home/'.config/rofi-wallpaper']:
    for p in base.rglob('*'):
        if not p.is_file() or p.is_symlink():continue
        try:text=p.read_text()
        except (UnicodeError,OSError):continue
        new=re.sub(r'\bnvim\b','micro',text).replace('kitty-sway','foot-sway')
        if p.name.endswith('.rasi'):new=new.replace('terminal: "kitty"','terminal: "foot"')
        if p.name=='btop-float':new=new.replace('--class btop','--app-id btop')
        if p.name=='recovery-shortcuts':
            new=new.replace('alacritty.desktop Alacritty.desktop kitty.desktop','foot.desktop footclient.desktop foot-server.desktop micro.desktop')
        if p==home/'.config/sway/config':
            new=new.replace('    xkb_variant abnt2\n','').replace('xkb_model pc105','xkb_model abnt2').replace('swaybg_command -\n','')
            new=re.sub(r'(swayosd-client --(?:output-volume|brightness) (?:raise|lower)) 5',r'\1',new)
        if p.name=='start-sway-full':
            new=new.replace('export WLR_NO_HARDWARE_CURSORS=1','export WLR_NO_HARDWARE_CURSORS=1\n  export WLR_RENDERER=pixman')
        if new!=text or p.read_bytes().startswith(b'#!'):p.write_text(new)

def executable(path,text):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(text);path.chmod(0o755)

executable(home/'.local/bin/foot-sway','#!/bin/sh\nexec /usr/bin/foot "$@"\n')
if not shutil.which('firefox') and shutil.which('firefox-bin'):
    executable(home/'.local/bin/firefox','#!/bin/sh\nexec /usr/bin/firefox-bin "$@"\n')
# Compatibilidade com scripts do modulo bin que chamam o nome antigo.
executable(home/'.local/bin/kitty-sway','#!/bin/sh\nexec "$HOME/.local/bin/foot-sway" "$@"\n')
foot=home/'.config/foot/foot.ini';foot.parent.mkdir(parents=True,exist_ok=True)
foot.write_text("""[main]
font=CodeNewRoman Nerd Font Mono:size=12
pad=12x12
[colors]
foreground=c6d0f5
background=303446
regular0=51576d
regular1=e78284
regular2=a6d189
regular3=e5c890
regular4=8caaee
regular5=f4b8e4
regular6=81c8be
regular7=b5bfe2
bright0=626880
bright1=e78284
bright2=a6d189
bright3=e5c890
bright4=8caaee
bright5=f4b8e4
bright6=81c8be
bright7=a5adce
""")
layout=home/'.config/wlogout/layout'
actions=json.loads('['+layout.read_text()+']')
for action in actions:
    if action['label']=='shutdown':action['action']='/usr/bin/systemctl poweroff'
    if action['label']=='reboot':action['action']='/usr/bin/systemctl reboot'
layout.write_text(',\n'.join(json.dumps(a,ensure_ascii=False,indent=2) for a in actions)+'\n')
executable(home/'.local/bin/rofi-network-menu', """#!/usr/bin/env bash
set -euo pipefail
networkctl status ens33 --no-pager | rofi -dmenu -i -p 'Rede (IPv4 fixo)' >/dev/null || true
""")
# O Waybar upstream pode nao fornecer unit no Gentoo.
unit=home/'.config/systemd/user/waybar.service'
unit.write_text("""[Unit]
Description=Waybar na sessao Sway
PartOf=sway-session.target
After=graphical-session-pre.target
[Service]
ExecStart=/usr/bin/waybar
Restart=on-failure
[Install]
WantedBy=sway-session.target
""")

# Backend leve de wallpapers: Sway gerencia o processo swaybg via IPC.
executable(home/'.local/bin/random-wallpaper.sh', """#!/usr/bin/env bash
set -euo pipefail
python3 - "$@" <<'PY_WALL'
from pathlib import Path
import json,random,subprocess,sys
if len(sys.argv)>1:
    image=Path(sys.argv[1]).expanduser()
else:
    images=[p for p in (Path.home()/'Imagens/wallpapers').rglob('*') if p.is_file() and p.suffix.lower() in ('.jpg','.jpeg','.png','.webp')]
    if not images:raise SystemExit('Nenhum wallpaper encontrado')
    image=random.choice(images)
if not image.is_file():raise SystemExit('Wallpaper nao encontrado: '+str(image))
subprocess.run(['swaymsg','-q','output * bg '+json.dumps(str(image),ensure_ascii=False)+' fill'],check=True)
print('Wallpaper aplicado: '+str(image))
PY_WALL
""")
executable(home/'.local/bin/sway-session-init', """#!/usr/bin/env bash
set -euo pipefail
export XDG_CURRENT_DESKTOP=sway GSK_RENDERER=cairo GDK_DISABLE=dmabuf
dbus-update-activation-environment --systemd WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP GSK_RENDERER GDK_DISABLE
systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP GSK_RENDERER GDK_DISABLE
systemctl --user start sway-session.target
systemctl --user restart randow-wallpapers.service randow-wallpapers.timer waybar.service
""")
unit=home/'.config/systemd/user/randow-wallpapers.service'
text=unit.read_text()
text='\n'.join(line for line in text.splitlines() if 'awww.service' not in line)+'\n'
unit.write_text(text)
(home/'.config/systemd/user/awww.service').unlink(missing_ok=True)

with (home/'.bashrc').open('a') as f:
    f.write("\nalias swall='~/.local/bin/random-wallpaper.sh'\nalias swall2='~/.local/bin/rofi-wallpaper'\n")

style=home/'.config/waybar/style.css'
text=style.read_text()
text=re.sub(r'(?m)^  font-family:.*$', '  font-family: "CodeNewRoman Nerd Font Mono", "Symbols Nerd Font Mono", "Font Awesome 6 Free", "Font Awesome 6 Brands";',text,count=1)
style.write_text(text)
