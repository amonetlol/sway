#!/usr/bin/env python3
from pathlib import Path
import json, os, shlex, shutil, subprocess

home = Path.home()
errors = []
report = {}
os.environ['PATH'] = f"{home}/.local/bin:{home}/.bin:/usr/local/bin:" + os.environ.get('PATH', '')
commands = [
    'sway', 'swaymsg', 'swaybg', 'swaylock', 'swayidle', 'waybar', 'rofi', 'wlogout', 'foot', 'micro',
    'cliphist', 'wl-copy', 'wl-paste', 'mako', 'playerctl', 'grim', 'slurp', 'thunar', 'firefox',
    'pavucontrol', 'btop', 'fastfetch', 'starship', 'subl', 'loginctl', 'vmtoolsd', 'fd', 'fzf', 'duf', 'pactl',
]
for cmd in commands:
    path = shutil.which(cmd)
    report[cmd] = path
    if not path:
        errors.append('Comando ausente: ' + cmd)
        continue
    data = subprocess.run(['ldd', path], text=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout
    if 'not found' in data:
        errors.append('Biblioteca ausente em ' + cmd)
paths = {
    'bash': '.bashrc', 'bin': '.bin', 'btop': '.config/btop/themes', 'fastfetch': '.config/fastfetch',
    'fonts': '.fonts', 'starship': '.config/starship-nord.toml', 'foot': '.config/foot/foot.ini',
    'micro': '.config/micro/settings.json', 'wallpapers': 'Imagens/wallpapers',
    'hide-shortcuts': '.local/bin/hide-shortcuts', 'recovery-shortcuts': '.local/bin/recovery-shortcuts',
    'sublime-text': '.config/sublime-text/Packages/User/Preferences.sublime-settings',
    'aliases': '.aliases-salix',
}
for name, rel in paths.items():
    p = home / rel
    report['module:' + name] = str(p) if p.exists() else None
    if not p.exists():
        errors.append('Modulo ausente: ' + name)
layout = home / '.config/wlogout/layout'
actions = json.loads('[' + layout.read_text(encoding='utf-8') + ']')
help_text = subprocess.check_output(['loginctl', '--help'], text=True)
for row in actions:
    args = shlex.split(row['action'])
    if not Path(args[0]).is_file():
        errors.append('Acao wlogout sem executavel: ' + row['label'])
    if args[0].endswith('loginctl') and args[1] not in help_text:
        errors.append('Acao elogind invalida: ' + args[1])
    report['wlogout:' + row['label']] = row['action']
for script in [home / '.config/wlogout/launch.sh', home / '.config/wlogout/session-action.sh', home / '.local/bin/start-sway-full', home / '.local/bin/sway-session-init']:
    subprocess.run(['bash', '-n', str(script)], check=True)
for file in [home / '.config/waybar/config', home / '.config/micro/settings.json']:
    json.loads(file.read_text(encoding='utf-8'))
sessions = []
for folder in [Path('/usr/share/wayland-sessions'), Path('/usr/share/xsessions')]:
    if not folder.is_dir():
        continue
    for desktop in folder.glob('*.desktop'):
        for line in desktop.read_text(encoding='utf-8', errors='replace').splitlines():
            if line.startswith('Name='):
                sessions.append(line.split('=', 1)[1].strip())
report['sddm-sessions'] = sessions
if sessions != ['Sway']:
    errors.append('SDDM deve ter apenas a sessao Sway: ' + ', '.join(sessions))
if not Path('/etc/rc.d/rc.sshd').stat().st_mode & 0o111:
    errors.append('SSH desabilitado no boot')
if not list((home / 'Imagens/wallpapers').glob('*')):
    errors.append('Pasta de wallpapers vazia')
report['errors'] = errors
out = home / '.local/state/sway-salix/verification.json'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
for key, value in report.items():
    if key != 'errors':
        print(('OK ' if value else 'FALTA ') + key + ': ' + str(value))
if errors:
    raise SystemExit('\n'.join(errors))
print('Verificacao de pacotes, modulos, SDDM e comandos wlogout: OK')
