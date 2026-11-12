#!/bin/sh
# Loop que troca o wallpaper a cada 5 minutos, iniciado pelo Niri
while true; do
    "$HOME/.bin/random-wallpaper.sh" || true
    sleep 300
done
# fim
