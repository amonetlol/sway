#!/bin/sh
set -eu
base="$HOME/.config/sway/themes/DarkShadow"
export PATH="$base/runtime/bin:$HOME/.local/bin:$HOME/.bin:/usr/local/bin:/usr/bin:/bin"
export WALLPAPER_DIR="$HOME/Imagens/wallpapers"
export QT_QPA_PLATFORM=wayland QSG_RENDER_LOOP=basic
export LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe
mkdir -p "$base/cache/rice" "$base/config/sway"
touch "$base/cache/rice/settings-open" "$base/cache/rice/wallpaper-open"
python3 "$base/scripts/palette.py" || echo 'DarkShadow: retaining saved palette' >&2
"$base/runtime/bin/rice-lock" apply
exec qs -n -p "$base/quickshell"
