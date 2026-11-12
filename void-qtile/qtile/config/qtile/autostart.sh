#!/bin/sh
setxkbmap -layout br -variant abnt2
# picom --config "$HOME/.config/qtile/picom/picom.conf" &
/usr/libexec/polkit-mate-authentication-agent-1 &
"$HOME/.local/bin/void-wallpaper-timer" &

pulseaudio --start
clipmenud &
"$HOME/.config/polybar/launch.sh" &

xsettingsd &
