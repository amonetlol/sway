#!/usr/bin/env python3
# Fetch only the upstream SlackBuild files needed for Nautilus.
import concurrent.futures, json, pathlib, urllib.request
names=set('gnome-autoar gnome-desktop exempi libgxps libiptcdata osinfo-db-tools osinfo-db libosinfo libuchardet totem-pl-parser tracker tracker-miners nautilus'.split())
root=pathlib.Path('/var/tmp/ff-slack-sources/slackbuilds')
with urllib.request.urlopen('https://api.github.com/repos/Ponce/slackbuilds/git/trees/current?recursive=1',timeout=30) as f: tree=json.load(f)['tree']
paths=[p['path'] for p in tree if p['type']=='blob' and len(p['path'].split('/'))>=3 and p['path'].split('/')[1] in names]
def fetch(path):
 target=root/path;target.parent.mkdir(parents=True,exist_ok=True)
 with urllib.request.urlopen('https://raw.githubusercontent.com/Ponce/slackbuilds/current/'+path,timeout=40) as f: target.write_bytes(f.read())
 return path
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
 for path in pool.map(fetch,paths):print('Obtido:',path,flush=True)
print('SLACKBUILDS_PRONTOS',len(paths))
