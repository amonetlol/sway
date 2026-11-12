#!/bin/sh
# Reinicia o waybar (recarrega config e estilo)
pkill -x waybar
sleep 0.5
waybar >/tmp/waybar.log 2>&1 &
# fim
