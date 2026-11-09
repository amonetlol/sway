#!/bin/sh
set -eu
state="$HOME/.local/state/sway-alpine"
mkdir -p "$state" "$HOME/.cache/sway-alpine-modules"
for name in bash bin btop fastfetch fonts starship foot wallpapers hide-shortcuts recovery-shortcuts; do
  grep -qx "$name" "$state/modules-completed" 2>/dev/null && continue
  script="$HOME/.cache/sway-alpine-modules/$name.sh"
  curl -fsSL --retry 3 "https://raw.githubusercontent.com/amonetlol/sh/main/modules/$name.sh" -o "$script"
  if [ "$name" = hide-shortcuts ]; then sed -i 's/micro.desktop //; /log "Renomeando Thunar"/,$d' "$script"; fi
  bash "$script"
  printf '%s\n' "$name" >> "$state/modules-completed"
done
mkdir -p "$HOME/.local/share/applications"
if [ ! -e "$HOME/.local/share/applications/htop.desktop" ]; then
  if [ -e /usr/share/applications/htop.desktop ]; then
    cp /usr/share/applications/htop.desktop "$HOME/.local/share/applications/htop.desktop"
    printf '\nNoDisplay=true\nHidden=true\n' >> "$HOME/.local/share/applications/htop.desktop"
  fi
fi
python3 - <<'PY'
from pathlib import Path
import re
h=Path.home()
p=h/'.aliases'
if p.exists():
    s=p.read_text()
    s=re.sub(r"(?m)^alias aln=.*$", "alias aln='micro ~/.config/micro/settings.json'", s)
    s=re.sub(r'\bnvim\b', 'micro', s)
    p.write_text(s)
p=h/'.bashrc'
if p.exists():
    s=p.read_text()
    if '# Alpine editor' not in s: p.write_text(s+'\n# Alpine editor\nexport EDITOR=micro VISUAL=micro\n')
PY
printf '%s\n' 'VMware e wallpapers de sessão são fornecidos pelos pacotes e pelo sway-session-init.'
