#!/usr/bin/env bash
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
for path in \
 t/thunar/thunar_4.20.2-1+deb13u1_amd64.deb \
 t/thunar/libthunarx-3-0_4.20.2-1+deb13u1_amd64.deb \
 t/thunar/thunar-data_4.20.2-1+deb13u1_all.deb \
 e/exo/libexo-2-0_4.20.0-1_amd64.deb \
 e/exo/libexo-common_4.20.0-1_all.deb \
 libx/libxfce4ui/libxfce4ui-2-0_4.20.1-1_amd64.deb \
 libx/libxfce4ui/libxfce4ui-common_4.20.1-1_all.deb \
 libx/libxfce4util/libxfce4util7_4.20.1-1_amd64.deb \
 libx/libxfce4util/libxfce4util-common_4.20.1-1_all.deb \
 x/xfconf/libxfconf-0-3_4.20.0-1_amd64.deb \
 x/xfconf/xfconf_4.20.0-1_amd64.deb; do
  file="$work/${path##*/}"
  curl -fsSL "https://deb.debian.org/debian/pool/main/$path" -o "$file"
  bsdtar -xOf "$file" data.tar.xz | tar -xJf - -C "$work"
done
libs="$work/usr/lib/x86_64-linux-gnu"
if LD_LIBRARY_PATH="$libs" ldd "$work/usr/bin/thunar" | grep -q 'not found'; then echo 'Dependencias do Thunar ausentes' >&2; exit 1; fi
base="$HOME/.local/opt/mocaccino-thunar"
if [[ -e "$base" ]]; then mv "$base" "$base.bak-$(date +%Y%m%d-%H%M%S)"; fi
mkdir -p "$base" "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/dbus-1/services"
cp -a "$work/usr" "$base/"
cat > "$HOME/.local/bin/thunar" <<'WRAPPER'
#!/bin/sh
base="$HOME/.local/opt/mocaccino-thunar/usr"
export LD_LIBRARY_PATH="$base/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="$base/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "$base/bin/thunar" "$@"
WRAPPER
cat > "$HOME/.local/bin/mocaccino-xfconfd" <<'WRAPPER'
#!/bin/sh
base="$HOME/.local/opt/mocaccino-thunar/usr"
export LD_LIBRARY_PATH="$base/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="$base/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
exec "$base/lib/x86_64-linux-gnu/xfce4/xfconf/xfconfd" "$@"
WRAPPER
chmod 755 "$HOME/.local/bin/thunar" "$HOME/.local/bin/mocaccino-xfconfd"
printf '[D-BUS Service]\nName=org.xfce.Xfconf\nExec=%s/.local/bin/mocaccino-xfconfd\n' "$HOME" > "$HOME/.local/share/dbus-1/services/org.xfce.Xfconf.service"
for n in org.xfce.Thunar org.freedesktop.FileManager1 org.xfce.FileManager; do
 printf '[D-BUS Service]\nName=%s\nExec=%s/.local/bin/thunar --gapplication-service\n' "$n" "$HOME" > "$HOME/.local/share/dbus-1/services/$n.service"
done
cp "$base/usr/share/applications/thunar.desktop" "$HOME/.local/share/applications/thunar.desktop"
python3 - <<'PY'
from pathlib import Path
apps=Path.home()/'.local/share/applications'
p=apps/'thunar.desktop';head,sep,tail=p.read_text().partition('\n[Desktop Action')
lines=[]
for line in head.splitlines():
 if line.startswith(('Name=','Name[')): line=line.split('=',1)[0]+'=Thunar'
 elif line.startswith('Icon='): line='Icon=org.gnome.Nautilus'
 lines.append(line)
p.write_text('\n'.join(lines)+'\n'+(sep+tail if sep else ''))
p=apps/'org.gnome.Nautilus.desktop'
if p.exists():
 head,sep,tail=p.read_text().partition('\n[Desktop Action')
 lines=[line for line in head.splitlines() if not line.startswith('NoDisplay=')]
 lines.insert(lines.index('[Desktop Entry]')+1,'NoDisplay=true')
 p.write_text('\n'.join(lines)+'\n'+(sep+tail if sep else ''))
PY
sudo install -Dm644 "$base/usr/share/locale/pt_BR/LC_MESSAGES/thunar.mo" /usr/share/locale/pt_BR/LC_MESSAGES/thunar.mo
"$HOME/.local/bin/thunar" --version | head -1
