#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
export RICE_SOURCE="${RICE_SOURCE:-$here/../sway-full}"
[[ -f $RICE_SOURCE/.config/sway/config ]] || fail 'Pasta sway-full ausente.'
mkdir -p "$HOME/.config" "$HOME/.local/bin"
for src in "$RICE_SOURCE/.config/"*; do
  name=${src##*/}
  [[ $name != kitty && $name != systemd ]] || continue
  save_path "$HOME/.config/$name"
  cp -a "$src" "$HOME/.config/"
done
for src in "$RICE_SOURCE/.local/bin/"*; do
  name=${src##*/}
  [[ $name != kitty-sway ]] || continue
  save_path "$HOME/.local/bin/$name"
  if [[ -f $HOME/.local/bin/$name/ssh.conf ]]; then cp "$HOME/.local/bin/$name/ssh.conf" "$cache/$name.ssh.conf"; fi
  cp -a "$src" "$HOME/.local/bin/"
  if [[ -f $cache/$name.ssh.conf ]]; then install -m600 "$cache/$name.ssh.conf" "$HOME/.local/bin/$name/ssh.conf"; fi
done
python3 "$here/adapt-rice.py" "$backup"
while IFS= read -r -d '' file; do
  if [[ $(head -c2 "$file") == '#!' ]]; then sed -i 's/\r$//' "$file"; chmod +x "$file"; fi
done < <(find "$HOME/.local/bin" "$HOME/.config/wlogout" "$HOME/.config/rofi-wallpaper" -type f -print0)
for hub in ssh-hub term-hub; do chmod 700 "$HOME/.local/bin/$hub.d"; chmod 600 "$HOME/.local/bin/$hub.d/ssh.conf"; done
python3 "$RICE_SOURCE/scripts/setup-desktop.py" "$backup"
log "Rice baseado no sway-full aplicado. Backup: $backup"
