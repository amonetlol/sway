#!/usr/bin/env python3
from pathlib import Path
import json,os,re,shutil,subprocess,sys,time

remove=['xinput_calibrator','glade','cdrdao','soma','joe','lftp','xterm',
        'cups-browsed','cups-filters','gutenprint','hplip','libcupsfilters','libppd',
        'pycups','system-config-printer','gpa']
patterns=['ca.desrt.dconf-editor.desktop','*fcitx*.desktop','ibus-setup*.desktop',
          'org.freedesktop.IBus.Setup.desktop','qt5-*.desktop','qt6-*.desktop',
          'thunar-bulk-rename.desktop','thunar-volman-settings.desktop',
          'org.gnome.Vte.App.*.desktop','vulkanCapsViewer.desktop','zint-qt.desktop',
          'zenmap*.desktop','cups.desktop','gtk3-demo.desktop','gtk3-icon-browser.desktop',
          'gtk3-widget-factory.desktop','org.gtk.Demo4.desktop','org.gtk.WidgetFactory4.desktop',
          'org.gtk.gtk4.NodeEditor.desktop','org.gtk.PrintEditor4.desktop',
          'distccmon-gnome.desktop','xfig.desktop','micro.desktop']
stamp=str(int(time.time()))
if sys.argv[1:] == ['--remove']:
    if os.geteuid()!=0:raise SystemExit('A remocao requer sudo.')
    state=Path('/var/lib/sway-slackware');state.mkdir(exist_ok=True)
    blacklist=Path('/etc/slackpkg/blacklist')
    before=blacklist.read_text()
    start='# BEGIN sway-slackware debloat';end='# END sway-slackware debloat'
    block=start+'\n'+'\n'.join(remove)+'\n'+end
    if start in before:
        updated=re.sub(re.escape(start)+r'.*?'+re.escape(end),block,before,flags=re.S)
    else:updated=before.rstrip()+'\n\n'+block+'\n'
    if before!=updated:
        shutil.copy2(blacklist,state/('blacklist.before-debloat-'+stamp))
        blacklist.write_text(updated)
    for rc,daemon in [('rc.cups','cupsd'),('rc.cups-browsed','cups-browsed')]:
        p=Path('/etc/rc.d')/rc
        if not p.exists():continue
        shutil.copy2(p,state/(rc+'.before-debloat-'+stamp))
        if subprocess.run(['pgrep','-x',daemon],stdout=subprocess.DEVNULL).returncode==0:
            subprocess.run(['/bin/sh',str(p),'stop'],check=True)
        p.chmod(p.stat().st_mode & ~0o111)
    records=Path('/var/lib/pkgtools/packages')
    installed={p.name.rsplit('-',3)[0] for p in records.iterdir()}
    selected=[name for name in remove if name in installed]
    print('Removendo:',', '.join(selected),flush=True)
    if selected:subprocess.run(['/sbin/removepkg','--terse',*selected],check=True)
    remaining={p.name.rsplit('-',3)[0] for p in records.iterdir()}
    assert not set(selected)&remaining,'Pacotes selecionados permaneceram instalados.'
    keep=['cups','vte','vulkan-sdk','zint','gtk+3','gtk4','thunar','thunar-volman','nmap']
    assert set(keep)<=remaining,'Pacote preservado ausente.'
    (state/'debloat.json').write_text(json.dumps({'removed':selected,'preserved':keep,'timestamp':stamp},indent=2)+'\n')
elif sys.argv[1:] == ['--hide']:
    if os.geteuid()==0:raise SystemExit('Oculte atalhos como usuario comum.')
    home=Path.home();dest=home/'.local/share/applications'
    backup=home/'.local/state/sway-slackware/backups'/('debloat-'+stamp)
    dest.mkdir(parents=True,exist_ok=True);hidden=[]
    files={p.name:p for pattern in patterns for p in Path('/usr/share/applications').glob(pattern)}
    files.update({p.name:p for pattern in patterns for p in dest.glob(pattern)})
    # Include overrides left by older rice modules for applications just removed.
    removed_entries=['xinput_calibrator.desktop','org.gnome.Glade.desktop','gcdmaster.desktop',
                     'soma.desktop','joe.desktop','jmacs.desktop','jpico.desktop','jstar.desktop',
                     'lftp.desktop','xterm.desktop','uxterm.desktop','gpa.desktop',
                     'cups.desktop','hplip.desktop','hp-uiscan.desktop','system-config-printer.desktop']
    for name in removed_entries:
        p=dest/name
        if p.exists():files[name]=p
    for name,source in sorted(files.items()):
        target=dest/name
        if target.exists():
            backup.mkdir(parents=True,exist_ok=True);shutil.copy2(target,backup/name)
            text=target.read_text()
        else:text=source.read_text()
        text=re.sub(r'^NoDisplay=.*\n?','',text,flags=re.M)
        text=text.replace('[Desktop Entry]','[Desktop Entry]\nNoDisplay=true',1)
        target.write_text(text);target.chmod(0o644);hidden.append(name)
    subprocess.run(['update-desktop-database',str(dest)],check=True)
    state=home/'.local/state/sway-slackware';state.mkdir(parents=True,exist_ok=True)
    (state/'debloat-hidden.json').write_text(json.dumps({'hidden':hidden,'timestamp':stamp},indent=2)+'\n')
    print('Atalhos ocultos:',len(hidden))
else:raise SystemExit('Uso: debloat.py --remove | --hide')
