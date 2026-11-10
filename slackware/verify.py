#!/usr/bin/env python3
from pathlib import Path
import json,shlex,shutil,subprocess

home=Path.home(); errors=[];report={}
commands=['sway','swaymsg','swaybg','swaylock','swayidle','waybar','rofi','wlogout','foot','micro',
 'cliphist','wl-copy','wl-paste','mako','playerctl','grim','slurp','pipewire','pipewire-pulse','wireplumber',
 'thunar','firefox','pavucontrol','btop','fastfetch','starship','subl','loginctl','vmtoolsd','vmware-user-suid-wrapper','fd','fzf','fzf-tmux','duf']
for cmd in commands:
    path=shutil.which(cmd)
    report[cmd]=path
    if not path: errors.append('Comando ausente: '+cmd);continue
    data=subprocess.run(['ldd',path],text=True,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL).stdout
    if 'not found' in data:errors.append('Biblioteca ausente em '+cmd+': '+data)
    if cmd in ['fastfetch','duf']:
        version=subprocess.run([path,'--version'],text=True,capture_output=True)
        if version.returncode or cmd not in (version.stdout+version.stderr).lower():
            errors.append('Binario invalido: '+cmd)
paths={
 'bash':'.bashrc','bin':'.bin','btop':'.config/btop/themes','fastfetch':'.config/fastfetch',
 'fonts':'.fonts','starship':'.config/starship-nord.toml','foot':'.config/foot/foot.ini',
 'micro':'.config/micro/settings.json','wallpapers':'Imagens/wallpapers',
 'random-wallpapers':'.local/bin/sway-wallpaper-loop','hide-shortcuts':'.local/bin/hide-shortcuts',
 'recovery-shortcuts':'.local/bin/recovery-shortcuts','sublime-text':'.config/sublime-text/Packages/User/Preferences.sublime-settings'}
for name,rel in paths.items():
    p=home/rel;report['module:'+name]=str(p) if p.exists() else None
    if not p.exists():errors.append('Modulo ausente: '+name)
actions=json.loads('['+(home/'.config/wlogout/layout').read_text()+']')
help_text=subprocess.check_output(['loginctl','--help'],text=True)
for row in actions:
    args=shlex.split(row['action']);p=Path(args[0])
    if not p.is_file():errors.append('Acao wlogout sem executavel: '+row['label'])
    if args[0].endswith('loginctl') and args[1] not in help_text:errors.append('Acao elogind invalida: '+args[1])
    report['wlogout:'+row['label']]=row['action']
for script in [home/'.config/wlogout/launch.sh',home/'.config/wlogout/session-action.sh',home/'.local/bin/start-sway-full',home/'.local/bin/sway-session-init']:
    subprocess.run(['bash','-n',str(script)],check=True)
for file in [home/'.config/waybar/config',home/'.config/micro/settings.json']:
    json.loads(file.read_text())
if not Path('/etc/rc.d/rc.sshd').stat().st_mode & 0o111:errors.append('SSH desabilitado no boot')
if not list((home/'Imagens/wallpapers').glob('*')):errors.append('Pasta de wallpapers vazia')
report['errors']=errors
p=home/'.local/state/sway-slackware/verification.json';p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n')
for k,v in report.items():
    if k!='errors':print(('OK ' if v else 'FALTA ')+k+': '+str(v))
if errors:raise SystemExit('\n'.join(errors))
print('Verificacao direta de pacotes, modulos e comandos wlogout: OK')
