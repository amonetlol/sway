#!/bin/sh
# Reinicia a waybar (recarrega config e estilo). Usado pelo Super+F12.
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
pkill -x waybar
sleep 0.5
setsid -f waybar >/tmp/waybar.log 2>&1
