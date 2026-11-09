#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
# O Solus inicia pelo clr-boot-manager. Instalar o GRUB aqui não troca o gerenciador.
if command -v clr-boot-manager >/dev/null 2>&1; then
  sudo clr-boot-manager update || true
  warn "Solus usa clr-boot-manager. O GRUB não substituiu a partida atual."
else
  warn "clr-boot-manager não encontrado. Nenhum bootloader foi reinstalado."
fi
log "Partida do Solus conferida."
