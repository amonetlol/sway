#!/usr/bin/env bash
# Fixes v3 do NixOS: term-hub atualizado, itens do launcher ocultos/renomeados
# (0-default-remove_and_hide.txt) e fonte/GRUB via configuration.nix.
# Idempotente: pode ser executado de novo sem efeito extra.
#   bash nixos/fixes-v3.sh
# Fonte CodeNewRoman fica em configuration.nix (nixos-rebuild switch).
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
export PATH="$HOME/.local/bin:$PATH"

log "term-hub: instalar ou atualizar a partir do repositório atual"
hub_tmp="$(mktemp)"
trap 'rm -f -- "$hub_tmp"' EXIT
if curl -fsSL -o "$hub_tmp" https://raw.githubusercontent.com/amonetlol/sh/main/modules/hub-ssh_term.sh; then
  bash "$hub_tmp" || warn "Falha ao instalar o term-hub; execute o instalador manualmente."
else
  warn "Não foi possível baixar o instalador do term-hub."
fi

# Ocultar (NoDisplay=true) ou renomear um .desktop do sistema.
# Cria override em ~/.local/share/applications; não altera o sistema.
SRC=/run/current-system/sw/share/applications
DST="$HOME/.local/share/applications"
mkdir -p "$DST"

override_desktop() {
  local id="$1" mode="$2"
  local src="$SRC/$id.desktop" dst="$DST/$id.desktop"
  [[ -f $src ]] || return 0
  cp "$src" "$dst"
  if [[ $mode == hide ]]; then
    if grep -q '^NoDisplay=' "$dst"; then
      sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$dst"
    else
      sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$dst"
    fi
    log "Oculto: $id"
  else
    sed -i -e 's/^Name=.*/Name=Nautilus/' -e '/^Name\[/d' "$dst"
    log "Renomeado: $id -> Nautilus"
  fi
}

log "Ocultar itens instalados (seção 1 e ASK respondido)"
for id in avahi-discover assistant qdbusviewer linguist qv4l2 qvidcap designer \
          rofi rofi-theme-selector xcalib btop micro vim nvim htop qt5ct qt6ct \
          bssh bvnc cups lstopo xgps xgpsspeed yad-icon-browser yad-settings \
          garuda-system-maintenance-settings garuda-toolbox reboot-to-uefi \
          setup-assistant snapper-tools suspend-then-hibernate \
          org.gnome.Vte.App.Gtk3 org.gnome.Vte.App.Gtk4 org.gtk.gtk4.NodeEditor \
          org.gtk.PrintEditor4 vulkanCapsViewer ca.desrt.dconf-editor gpa \
          org.freedesktop.IBus.Setup org.gtk.Demo4 org.gtk.WidgetFactory4 \
          wpa_gui fcitx5-configtool org.manjaro.pamac.manager application-utility \
          manjaro-settings-manager msm_notifier_settings stoken-gui stoken-gui-small \
          display-im7.q16 gnome-language-selector slicksddm-customize; do
  override_desktop "$id" hide
done

log "Renomear Files para Nautilus (seção 4)"
[[ -f $SRC/org.gnome.Nautilus.desktop ]] && override_desktop org.gnome.Nautilus rename || true

log "Fixes v3 do NixOS concluídos. Reinicie a sessão Sway para o launcher atualizar."
