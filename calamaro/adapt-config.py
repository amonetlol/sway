#!/usr/bin/env python3
"""Adapta somente a copia instalada do sway-full para CalamaroOS/Foot/Micro."""
from pathlib import Path
import glob, re

def polkit_agent():
    for pattern in ['/usr/bin/lxqt-policykit-agent', '/usr/lib*/exec/*polkit*kde*', '/usr/lib*/polkit*/polkit-*-authentication-agent-1']:
        found = sorted(glob.glob(pattern))
        if found: return found[0]
    raise SystemExit('Nenhum agente polkit encontrado')

home = Path.home()
for base in [home/'.local/bin', home/'.config/sway', home/'.config/rofi', home/'.config/rofi-wallpaper']:
    for p in base.rglob('*'):
        if not p.is_file() or p.is_symlink(): continue
        try: text = p.read_text()
        except (UnicodeError, OSError): continue
        new = re.sub(r'\bnvim\b', 'micro', text).replace('kitty-sway', 'foot-sway')
        if p.name.endswith('.rasi'): new = new.replace('terminal: "kitty"', 'terminal: "foot"')
        if p.name == 'btop-float': new = new.replace('--class btop', '--app-id btop')
        if p.name == 'recovery-shortcuts':
            new = new.replace('alacritty.desktop Alacritty.desktop kitty.desktop', 'foot.desktop footclient.desktop foot-server.desktop micro.desktop')
        if p == home/'.config/sway/config':
            new = new.replace('swaybg_command -\n', '')
            new = re.sub(r'(swayosd-client --(?:output-volume|brightness) (?:raise|lower)) 5', r'\1', new)
            # Sem open-vm-tools no CalamaroOS: remove o exec do wrapper da VMware.
            new = new.replace('exec /usr/bin/vmware-user-suid-wrapper\n', '')
            # Agente de autenticacao presente no CalamaroOS.
            new = re.sub(r"exec sh -c 'exec /usr/libexec/polkit-gnome-authentication-agent-1 \|\| exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1'",
                         'exec ' + polkit_agent(), new)
            # firefox-bin nao cria o atalho firefox.
            new = new.replace('exec firefox', 'exec firefox-bin')
        if new != text or p.read_bytes().startswith(b'#!'): p.write_text(new)

def executable(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text); path.chmod(0o755)

executable(home/'.local/bin/foot-sway', '#!/bin/sh\nexec /usr/bin/foot "$@"\n')
# Compatibilidade com scripts do modulo bin que chamam o nome antigo.
executable(home/'.local/bin/kitty-sway', '#!/bin/sh\nexec "$HOME/.local/bin/foot-sway" "$@"\n')
foot = home/'.config/foot/foot.ini'; foot.parent.mkdir(parents=True, exist_ok=True)
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
style = home/'.config/waybar/style.css'
text = style.read_text()
text = re.sub(r'(?m)^  font-family:.*$', '  font-family: "CodeNewRoman Nerd Font Mono", "Symbols Nerd Font Mono", "Font Awesome 6 Free", "Font Awesome 6 Brands";', text, count=1)
style.write_text(text)
with (home/'.bashrc').open('a') as f:
    f.write("\nalias swall='~/.local/bin/random-wallpaper.sh'\nalias swall2='~/.local/bin/rofi-wallpaper'\n")
