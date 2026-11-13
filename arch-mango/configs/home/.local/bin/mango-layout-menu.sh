#!/usr/bin/env bash
# Menu de layouts do mango (Super+;). Lista os layouts via mmsg e aplica o escolhido com setlayout.
set -euo pipefail
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
if [[ -z "${MANGO_INSTANCE_SIGNATURE:-}" ]]; then
    MANGO_INSTANCE_SIGNATURE=$(ls "$XDG_RUNTIME_DIR"/mango-*.sock 2>/dev/null | head -1)
    export MANGO_INSTANCE_SIGNATURE
fi
list=$(mmsg get layouts | python3 -c '
import json, sys
for l in json.load(sys.stdin)["layouts"]:
    print("%-4s %s" % (l["symbol"], l["name"]))
')
choice=$(printf '%s\n' "$list" | rofi -dmenu -i -p 'Layout' -no-custom) || exit 0
name=$(printf '%s' "$choice" | awk '{print $NF}')
[[ -n "$name" ]] || exit 0
mmsg dispatch "setlayout,$name"
