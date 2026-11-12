#!/bin/sh
# Menu de energia com rofi para o Niri (icone + texto)
choice=$(printf '%s\n' "  Desligar" "  Reiniciar" "  Suspender" "  Sair do Niri" | rofi -dmenu -i -p "Energia")
case "$choice" in
  *Desligar) loginctl poweroff ;;
  *Reiniciar) loginctl reboot ;;
  *Suspender) loginctl suspend ;;
  *"Sair do Niri") niri msg action quit --skip-confirmation ;;
esac
# fim
