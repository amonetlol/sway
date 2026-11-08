#!/usr/bin/env bash
set -euo pipefail
root="$HOME/.config/sway"
selection=$(printf '%s\n' ' Bloquear' ' Encerrar sessão' ' Suspender' ' Reiniciar' '⏻ Desligar' | rofi -no-config -dmenu -no-custom -format i -p Energia -theme "$root/current/rofi/power.rasi") || exit 0
case "$selection" in
 0) exec swaylock -C "$root/current/swaylock/config" ;;
 1) exec swaymsg exit ;;
 2) exec systemctl suspend ;;
 3) exec systemctl reboot ;;
 4) exec systemctl poweroff ;;
 *) exit 0 ;;
esac
