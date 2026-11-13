#!/usr/bin/env bash
if pgrep -x gammastep >/dev/null; then
    pkill -x gammastep
else
    gammastep -O 4000 >/dev/null 2>&1 &
fi