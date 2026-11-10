#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Backend de libinput do SwayOSD como servico (systemd de sistema no EL10).
if [[ -f /usr/lib/systemd/system/swayosd-libinput-backend.service ]]; then
  sudo systemctl enable --now swayosd-libinput-backend.service
elif [[ -f /usr/lib/systemd/user/swayosd-libinput-backend.service ]]; then
  if [[ -S "$XDG_RUNTIME_DIR/bus" ]]; then
    systemctl --user enable --now swayosd-libinput-backend.service
  else
    mkdir -p "$HOME/.config/systemd/user/default.target.wants"
    ln -sf /usr/lib/systemd/user/swayosd-libinput-backend.service "$HOME/.config/systemd/user/default.target.wants/swayosd-libinput-backend.service"
    log 'Servico do SwayOSD habilitado; iniciara com a sessao grafica.'
  fi
else
  log 'Unidade do backend SwayOSD nao encontrada; seguindo sem o backend de libinput.'
fi
getent group audio >/dev/null && sudo usermod -aG audio "$USER" || true
xdg-user-dirs-update
