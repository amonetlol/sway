#!/usr/bin/env python3
"""Verificacao estatica: arquivos, pacotes, executaveis e acoes do wlogout."""
from pathlib import Path
import json
import shlex
import shutil
import subprocess

home = Path.home()
state = home / '.local/state/sway-artix'
errors = []
def check(ok, name):
    print(('OK ' if ok else 'FALTA ') + name)
    if not ok:
        errors.append(name)

for command in ['sway', 'swaymsg', 'swaylock', 'wlogout', 'loginctl', 'elogind-inhibit',
                'kitty', 'waybar', 'awww', 'awww-daemon', 'swayosd-client', 'swayosd-server',
                'pipewire', 'pipewire-pulse', 'wireplumber', 'rofi', 'cliphist', 'nwg-look',
                'nvim', 'btop', 'fastfetch', 'starship', 'vmtoolsd', 'subl']:
    check(shutil.which(command) is not None, command)
for command in ['sway', 'vmtoolsd', 'swayosd-server', 'kitty']:
    binary = shutil.which(command)
    if binary:
        result = subprocess.run(['ldd', binary], capture_output=True, text=True)
        check('not found' not in result.stdout + result.stderr, 'bibliotecas de ' + command)
for path in ['.bashrc', '.aliases', '.functions', '.bin', '.config/btop/themes',
             '.config/fastfetch/config.jsonc', '.config/nvim/init.lua', '.config/kitty/kitty.conf',
             '.config/sway/config', '.config/waybar/config', '.config/wlogout/layout',
             '.local/bin/random-wallpaper.sh', '.local/bin/sway-session-init']:
    check((home / path).exists(), path)
check((home / '.config/starship-nord.toml').exists(), 'configuracao Starship')
check('CodeNewRoman' in subprocess.check_output(
    ['fc-match', '-f', '%{family}', 'CodeNewRoman Nerd Font'], text=True), 'fonte CodeNewRoman')
for package in (state / 'packages.txt').read_text().splitlines():
    if package:
        check(subprocess.run(['pacman', '-Q', package], stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL).returncode == 0, 'pacote ' + package)
layout = home / '.config/wlogout/layout'
actions = json.loads('[' + layout.read_text() + ']')
help_text = subprocess.check_output(['loginctl', '--help'], text=True)
for action in actions:
    argv = shlex.split(action['action'])
    check(shutil.which(argv[0]) is not None, 'wlogout ' + action['label'] + ': ' + argv[0])
    if Path(argv[0]).name == 'loginctl':
        check(argv[1] in help_text, 'loginctl suporta ' + argv[1])
    check('systemctl' not in action['action'], 'wlogout sem systemctl: ' + action['label'])
for service in ['sshd', 'NetworkManager', 'dbus', 'logind', 'vmtoolsd', 'sddm', 'cronie']:
    check((Path('/etc/dinit.d/boot.d') / service).exists(), 'dinit habilitado: ' + service)
for name in ['bash', 'bin', 'btop', 'fastfetch', 'fonts', 'starship', 'nvim', 'hide-shortcuts',
             'recovery-shortcuts', 'kitty', 'wallpapers', 'sublime-text', 'random-wallpapers', 'vmware']:
    check(any(line.startswith(name + '\t') for line in (state / 'modules.tsv').read_text().splitlines()),
          'modulo ' + name)
check(any((home / '.local/share/icons/Papirus-Dark').glob('index.theme')) or
      Path('/usr/share/icons/Papirus-Dark/index.theme').exists(), 'icones Papirus')
check((home / '.local/share/icons/Vimix-cursors/index.theme').exists(), 'cursor Vimix')
check((home / '.local/share/icons/McMuse-circle/index.theme').exists(), 'icones McMuse')
check(any((home / 'Imagens/wallpapers').rglob('*.jpg')) or
      any((home / 'Imagens/wallpapers').rglob('*.png')), 'wallpapers')
if errors:
    raise SystemExit(f'{len(errors)} verificacoes falharam')
print('Pacotes, modulos e comandos wlogout conferidos; acoes de energia nao foram executadas.')
