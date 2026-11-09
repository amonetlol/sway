#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
python3 "$here/verify.py"
foot --check-config
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate -c "$HOME/.config/sway/config"
log 'Configuracao Sway validada; wlogout conferido sem desligar/reiniciar a VM.'
