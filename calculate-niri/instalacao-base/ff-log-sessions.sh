#!/usr/bin/env bash
set -euo pipefail
unset TMUX
for name in install scripts downloads endeavouros calamaro chimera; do touch "/tmp/ff-$name.log"; done
if ! tmux has-session -t '=ff' 2>/dev/null; then
 tmux new-session -d -s ff -n logs 'tail -F /tmp/ff-install.log'
 tmux split-window -t ff:logs 'tail -F /tmp/ff-scripts.log'
 tmux split-window -t ff:logs 'tail -F /tmp/ff-downloads.log'
 tmux select-layout -t ff:logs tiled >/dev/null
fi
if ! tmux has-session -t '=ffd' 2>/dev/null; then
 tmux new-session -d -s ffd -n distros 'tail -F /tmp/ff-endeavouros.log'
 tmux split-window -t ffd:distros 'tail -F /tmp/ff-calamaro.log'
 tmux split-window -t ffd:distros 'tail -F /tmp/ff-chimera.log'
 tmux select-layout -t ffd:distros tiled >/dev/null
fi

#FF_REDCORE_CALCULATE
for name in redcore calculate; do
 touch "/tmp/ff-$name.log"
 if ! tmux list-windows -t ffd -F "#{window_name}" | grep -Fxq "$name"; then
  tmux new-window -d -t ffd -n "$name" "tail -F /tmp/ff-$name.log"
 fi
done
