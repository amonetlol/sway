#!/usr/bin/env python3
"""Deploy the saved Debian desktop for the invoking user or system."""
import argparse, json, os, pathlib, shutil, tarfile, datetime

base=pathlib.Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser()
parser.add_argument('--system',action='store_true')
parser.add_argument('--scope', choices=('all','sway','personal'), default='all')
args=parser.parse_args()
home=pathlib.Path.home()
stamp=datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
backup=(pathlib.Path('/var/backups/sway-debian/configs') if args.system else home/'.local/state/sway-debian/backups')/stamp

def belongs(name):
    if name.startswith('usr/') != args.system:return False
    if args.scope == 'all':return True
    if args.scope == 'personal':return name.startswith('.config/ghostty/')
    return args.system or name.startswith(('.config/sway/', '.config/gtk-3.0/', '.config/gtk-4.0/', '.config/systemd/', '.local/share/')) or name in ('.bin/random-wallpaper.sh', '.local/bin/mon', '.local/bin/kitty', '.local/bin/nautilus', '.local/bin/sway-polkit-agent')
def destination(name):
    p=pathlib.PurePosixPath(name)
    if p.is_absolute() or '..' in p.parts:raise ValueError(name)
    return (pathlib.Path('/') if args.system else home)/name
def prepare(path):
    path.parent.mkdir(parents=True,exist_ok=True)
    if path.exists() or path.is_symlink():
        rel=path.relative_to('/' if args.system else home)
        saved=backup/rel;saved.parent.mkdir(parents=True,exist_ok=True)
        if path.is_symlink():saved.symlink_to(os.readlink(path));path.unlink()
        elif path.is_file():shutil.copy2(path,saved)
        else:raise RuntimeError(f'Expected a file: {path}')

for asset in sorted((base/'assets').glob('*.tar.gz')):
 with tarfile.open(asset) as archive:
    for member in archive:
        if not belongs(member.name):continue
        if member.issym():
            path=destination(member.name);prepare(path)
            if path.exists() or path.is_symlink():path.unlink()
            path.symlink_to(member.linkname.replace('@@HOME@@',str(home)))
            continue
        if member.islnk():
            path=destination(member.name);prepare(path)
            if path.exists():path.unlink()
            os.link(destination(member.linkname),path)
            continue
        if not member.isfile():continue
        path=destination(member.name);prepare(path)
        with archive.extractfile(member) as source,path.open('wb') as target:shutil.copyfileobj(source,target)
        path.chmod(member.mode)

modes=json.loads((base/'manifests/config-modes.json').read_text())
for name,mode in modes.items():
    if not belongs(name):continue
    path=destination(name);prepare(path)
    path.write_text((base/'config'/name).read_text(encoding='utf-8').replace('@@HOME@@',str(home)),encoding='utf-8')
    path.chmod(mode)
for name,target in json.loads((base/'manifests/config-links.json').read_text()).items():
    if not belongs(name):continue
    path=destination(name);prepare(path)
    if path.exists() or path.is_symlink():path.unlink()
    path.symlink_to(target.replace('@@HOME@@',str(home)))
print(f'Configurações instaladas. Backups: {backup}')
