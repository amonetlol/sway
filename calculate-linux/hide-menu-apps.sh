#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# FontForge, xcalib e as configuracoes de impressao continuam instalados,
# mas saem do menu (rofi -show drun) por override local com NoDisplay/Hidden.
local_app="$HOME/.local/share/applications"
mkdir -p "$local_app"
for name in org.fontforge.FontForge.desktop xcalib.desktop Gentoo-system-config-printer.desktop; do
  src="/usr/share/applications/$name"
  if [[ ! -f "$src" ]]; then
    log "Sem entrada no menu: $name (ignorada)"
    continue
  fi
  cp "$src" "$local_app/$name"
  printf '\nNoDisplay=true\nHidden=true\n' >> "$local_app/$name"
done
command -v update-desktop-database >/dev/null && update-desktop-database "$local_app"
log 'FontForge, xcalib e Print Settings escondidos do menu.'
