#!/usr/bin/env bash
set -euo pipefail
choice=$(printf 'Desligar\nReiniciar\nSair\n' | rofi -dmenu -i -p 'Energia') || exit 0
case "$choice" in
    Desligar) systemctl poweroff ;;
    Reiniciar) systemctl reboot ;;
    # Sair: reinicia o SDDM para o greeter voltar (sem isso a tela fica preta)
    Sair) sudo systemctl restart --no-block sddm ;;
esac
