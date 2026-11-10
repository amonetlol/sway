#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# Audio: unidades de usuario do PipeWire no systemd do CalamaroOS.
if [[ -S "$XDG_RUNTIME_DIR/bus" ]] && command -v systemctl >/dev/null; then
  systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || \
  systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
else
  log 'Barramento de usuario indisponivel; os servicos do PipeWire iniciam com a proxima sessao.'
fi
# Backend de libinput do SwayOSD como servico de usuario (systemd).
if [[ -f /usr/lib/systemd/user/swayosd-libinput-backend.service ]]; then
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
xdg-user-dirs-update
