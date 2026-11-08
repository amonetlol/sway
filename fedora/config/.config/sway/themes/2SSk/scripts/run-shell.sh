#!/bin/sh
set -eu
export PATH="@@HOME@@/.config/sway/themes/2SSk/runtime/bin:$HOME/.local/bin:$HOME/.bin:/usr/local/bin:/usr/bin"
export QT_QPA_PLATFORM=wayland QSG_RENDER_LOOP=basic QSG_RHI_BACKEND=opengl
export LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe
"@@HOME@@/.config/sway/themes/2SSk/runtime/bin/theme" apply
exec qs -n -p "@@HOME@@/.config/sway/themes/2SSk/quickshell"
