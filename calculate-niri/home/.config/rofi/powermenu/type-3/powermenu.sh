#!/usr/bin/env bash
# Power menu: adi1090x rofi type-3 style-2, cores laranja (theme-orange)
dir="$HOME/.config/rofi/powermenu/type-3"
theme='style-2'

uptime="$(uptime -p | sed -e 's/up //g')"

shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi"
}

run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

run_cmd() {
    case "$1" in
        --shutdown) exec gdbus call --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 --method org.freedesktop.login1.Manager.PowerOff true ;;
        --reboot)   exec gdbus call --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 --method org.freedesktop.login1.Manager.Reboot true ;;
        --suspend)  exec gdbus call --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1 --method org.freedesktop.login1.Manager.Suspend true ;;
        --logout)   exec niri msg action quit --skip-confirmation ;;
    esac
}
chosen="$(run_rofi)"
case "${chosen}" in
    "$shutdown") run_cmd --shutdown ;;
    "$reboot")   run_cmd --reboot ;;
    "$lock")     if command -v swaylock >/dev/null; then exec swaylock; else exec loginctl lock-session; fi ;;
    "$suspend")  run_cmd --suspend ;;
    "$logout")   run_cmd --logout ;;
esac
