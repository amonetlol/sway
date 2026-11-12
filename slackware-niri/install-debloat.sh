#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo python3 "$here/debloat.py" --remove
python3 "$here/debloat.py" --hide
log 'Debloat aplicado; bibliotecas compartilhadas preservadas e atalhos ocultos.'
