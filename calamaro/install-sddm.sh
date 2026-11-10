#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# O tema atual do SDDM (calamaroos) e preservado; apenas a sessao muda.
grep -q '^Current=calamaroos$' /etc/sddm.conf.d/10-session.conf 2>/dev/null || grep -q '^Current=calamaroos$' /etc/sddm.conf 2>/dev/null || log 'AVISO: tema calamaroos nao encontrado na configuracao do SDDM.'
sudo install -d /usr/local/bin /var/backups/sddm-sessions
printf '#!/bin/sh\nexec "$HOME/.local/bin/start-sway-full" "$@"\n' | sudo tee /usr/local/bin/sway-full-session >/dev/null
sudo chmod 755 /usr/local/bin/sway-full-session
cat <<'EOF' | sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
# SDDM e o gerenciador de login; manter somente a entrada Sway.
sudo find /usr/share/wayland-sessions /usr/share/xsessions -mindepth 1 -maxdepth 1 -name '*.desktop' ! -name 'sway.desktop' -exec mv {} /var/backups/sddm-sessions/ \; 2>/dev/null || true
# Sessao padrao do SDDM passa a ser o Sway (inclusive no autologin).
if [[ -f /etc/sddm.conf.d/10-session.conf ]]; then
  sudo sed -i 's/^Session=.*/Session=sway/' /etc/sddm.conf.d/10-session.conf
fi
sudo sed -i 's/^Session=.*/Session=sway/' /etc/sddm.conf
# Garantias: sddm habilitado e boot grafico.
for dm in gdm lightdm lxdm; do sudo systemctl disable "$dm" 2>/dev/null || true; done
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
log 'SDDM habilitado com a unica entrada Sway para o proximo boot; a sessao atual nao foi interrompida.'
