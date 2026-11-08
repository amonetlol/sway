#!/usr/bin/env bash
# Aplica configuration.nix no NixOS já instalado e muda o canal para o rolling.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f /etc/nixos/hardware-configuration.nix ]] || { echo "Falta /etc/nixos/hardware-configuration.nix. Instale o NixOS antes." >&2; exit 1; }
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }

log() { printf '[*] %s\n' "$*"; }
sudo -v
state="$(sed -n 's/.*system.stateVersion = "\([^"]*\)".*/\1/p' /etc/nixos/configuration.nix | head -n 1 || true)"
sudo cp -a /etc/nixos/configuration.nix "/etc/nixos/configuration.nix.bak-$(date +%Y%m%d-%H%M%S)"
sudo install -m 644 "$here/configuration.nix" /etc/nixos/configuration.nix
if [[ -n ${state:-} ]]; then
  sudo sed -i "s/system.stateVersion = \"[^\"]*\";/system.stateVersion = \"$state\";/" /etc/nixos/configuration.nix
  log "stateVersion preservado: $state"
fi

if ! sudo nix-channel --list | grep -q 'nixos-unstable'; then
  log "Trocando o canal para nixos-unstable (rolling)"
  sudo nix-channel --add https://channels.nixos.org/nixos-unstable nixos
  sudo nix-channel --update
fi
log "nixos-rebuild switch"
sudo nixos-rebuild switch --max-jobs 2
log "Sistema atualizado."
