#!/bin/bash
export LANG=pt_BR.UTF-8 LC_TIME=pt_BR.UTF-8
pkill -x polybar
for i in $(seq 1 20); do pgrep -x polybar >/dev/null || break; sleep 0.2; done
pkill -9 -x polybar 2>/dev/null
polybar --reload google-top >/dev/null 2>&1 &
polybar struthelper >/dev/null 2>&1 &
exit 0
