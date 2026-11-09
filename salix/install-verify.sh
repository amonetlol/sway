#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
python3 "$here/verify.py"
foot --check-config
runtime="${XDG_RUNTIME_DIR:-$HOME/.cache/sway-salix/runtime}"
mkdir -p "$runtime"
chmod 700 "$runtime"
XDG_RUNTIME_DIR="$runtime" WLR_BACKENDS=headless WLR_RENDERER=pixman sway --validate -c "$HOME/.config/sway/config"
log 'Sway, modulos e comandos do wlogout conferidos.'
