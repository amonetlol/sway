#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
backup="$state/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/bin"
for name in sway waybar wlogout rofi rofi-wallpaper btop gtk-3.0 gtk-4.0; do
  [[ -d $root/sway-full/.config/$name ]] || continue
  if [[ -e $HOME/.config/$name ]]; then
    mv "$HOME/.config/$name" "$backup/$name"
  fi
  cp -a "$root/sway-full/.config/$name" "$HOME/.config/$name"
done
cp -a "$root/sway-full/.local/bin/." "$HOME/.local/bin/"
find "$HOME/.local/bin" -type f -exec chmod u+x {} +
chmod u+x "$HOME/.config/wlogout/launch.sh" "$HOME/.config/wlogout/session-action.sh"
python3 "$here/adapt-rice.py"
log 'Rice sway-full copiado e adaptado para Foot, Micro e elogind.'
