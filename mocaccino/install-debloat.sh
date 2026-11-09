#!/usr/bin/env bash
set -euo pipefail
# Entradas de menu ocultas apenas para o usuario atual.
python3 - <<'PY'
from pathlib import Path
names=['btop.desktop','htop.desktop','Gentoo-system-config-printer.desktop','cups.desktop','ca.desrt.dconf-editor.desktop','mocaccino-manual.desktop','nvim.desktop','org.freedesktop.IBus.Setup.desktop','assistant.desktop','designer.desktop','linguist.desktop','qdbusviewer.desktop','vim.desktop','xterm.desktop','org.gnome.ColorProfileViewer.desktop']
dest=Path.home()/'.local/share/applications';dest.mkdir(parents=True,exist_ok=True)
for name in names:
 src=Path('/usr/share/applications')/name; target=dest/name
 if target.exists() or not src.exists(): continue
 head,sep,rest=src.read_text().partition('\n[Desktop Action')
 lines=[x for x in head.splitlines() if not x.startswith('NoDisplay=')]
 lines.insert(lines.index('[Desktop Entry]')+1,'NoDisplay=true')
 target.write_text('\n'.join(lines)+'\n'+(sep+rest if sep else ''))
PY
for pair in 'gnome-disks:gnome-disk-utility' 'drawing:drawing' 'geary:geary' 'gparted:gparted' 'gnome-software:gnome-software'; do
 command_name=${pair%%:*}; package=${pair#*:}
 if command -v "$command_name" >/dev/null; then sudo luet uninstall -y "apps/$package"; fi
done
printf '%s\n' 'xterm e gcm-viewer permanecem nas camadas X e gnome-common e foram ocultados no menu.'
