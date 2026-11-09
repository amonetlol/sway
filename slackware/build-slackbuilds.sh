#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
mkdir -p "$cache/slackbuilds" "$cache/packages"
for entry in multimedia/playerctl libraries/libmspack network/libdnet system/open-vm-tools; do
  name=${entry##*/}
  compgen -G "/var/lib/pkgtools/packages/$name-*-*" >/dev/null && continue
  dir="$cache/slackbuilds/$name"
  mkdir -p "$dir"
  # Download only this package's current SlackBuild; inspectable in the cache.
  python3 - "$entry" "$dir" <<'PY'
import json,sys,subprocess
from pathlib import Path
entry,dest=sys.argv[1],Path(sys.argv[2])
url='https://api.github.com/repos/Ponce/slackbuilds/contents/'+entry+'?ref=current'
def fetch(url):
    return subprocess.check_output(['curl','-4','-fLsS','--retry','3','--max-time','45',
                                    '-A','sway-slackware-installer',url])
for item in json.loads(fetch(url)):
    if item['type']=='file':
        (dest/item['name']).write_bytes(fetch(item['download_url']))
PY
  (
    cd "$dir"
    source "$name.info"
    url=${DOWNLOAD_x86_64:-$DOWNLOAD}
    sum=${MD5SUM_x86_64:-$MD5SUM}
    file=${url##*/}
    download "$url" "$file"
    printf '%s  %s\n' "$sum" "$file" | md5sum -c -
    sudo env MAKEFLAGS=-j2 OUTPUT="$cache/packages" NUMJOBS=-j2 bash "$name.SlackBuild"
  )
  pkg=$(find "$cache/packages" -maxdepth 1 -name "$name-*.t?z" | sort | tail -1)
  [[ -n $pkg ]] || fail "SlackBuild nao produziu pacote: $name"
  sudo /sbin/upgradepkg --install-new "$pkg"
done
