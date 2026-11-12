#!/usr/bin/env bash
# Fixes v3 do Void: term-hub, itens do launcher, teclado, atalhos do Qtile (mon, F1, clipboard),
# rofi-power com ícones, F10 com bordas retas e nvim. O GRUB com o tema bsol fica em install-grub.sh.
# Idempotente: pode ser executado de novo sem efeito extra.
#   bash void-qtile/fixes-v3.sh
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v
export PATH="$HOME/.local/bin:$PATH"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log "Dependências do term-hub (git, python3, tmux, openssh, curl)"
sudo xbps-install -Sy git python3 tmux openssh curl

log "Pacotes dos atalhos e do nvim (duf, clipmenu/xsel, nodejs, luarocks, tree-sitter, ripgrep, fd)"
sudo xbps-install -Sy duf clipmenu xsel nodejs luarocks tree-sitter-cli ripgrep fd

log "term-hub: instalar ou atualizar a partir do repositório atual"
hub_tmp="$(mktemp)"
trap 'rm -f -- "$hub_tmp"' EXIT
if curl -fsSL -o "$hub_tmp" https://raw.githubusercontent.com/amonetlol/sh/main/modules/hub-ssh_term.sh; then
  bash "$hub_tmp" || warn "Falha ao instalar o term-hub; execute o instalador manualmente."
else
  warn "Não foi possível baixar o instalador do term-hub."
fi

# Ocultar (NoDisplay=true) ou renomear um .desktop do sistema.
# Cria override em ~/.local/share/applications; não altera /usr/share.
SRC=/usr/share/applications
DST="$HOME/.local/share/applications"
mkdir -p "$DST"

override_desktop() {
  local id="$1" mode="$2"
  local src="$SRC/$id.desktop" dst="$DST/$id.desktop"
  [[ -f $src ]] || { log "Ignorado (não instalado): $id"; return 0; }
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

log "Ocultar itens instalados (seção 1)"
for id in btop micro nvim htop rofi rofi-theme-selector vim avahi-discover \
          assistant qdbusviewer linguist qv4l2 qvidcap designer qt5ct qt6ct \
          bssh bvnc cups lstopo xgps xgpsspeed xcalib yad-icon-browser \
          yad-settings org.freedesktop.IBus.Setup display-im7.q16 \
          gnome-language-selector slicksddm-customize; do
  override_desktop "$id" hide
done

log "Renomear Files para Nautilus (seção 4)"
override_desktop org.gnome.Nautilus rename

# Atalhos e utilitários do Qtile: mon (resolução), show-hotkeys (F1) e rofi-power (ícones).
# config.py, autostart.sh e polybar/config.ini são copiados do repo, como o README descreve.
log "Atalhos do Qtile: mon, show-hotkeys, rofi-power, config.py, autostart e polybar"
mkdir -p "$HOME/.local/bin" "$HOME/.config/qtile" "$HOME/.config/polybar"
install -m755 "$here/../sway-full/.local/bin/mon" "$HOME/.local/bin/mon"
install -m755 "$here/qtile/bin/show-hotkeys" "$HOME/.local/bin/show-hotkeys"
install -m755 "$here/qtile/bin/rofi-power" "$HOME/.local/bin/rofi-power"
install -m644 "$here/qtile/config/qtile/config.py" "$HOME/.config/qtile/config.py"
install -m755 "$here/qtile/config/qtile/autostart.sh" "$HOME/.config/qtile/autostart.sh"
install -m644 "$here/qtile/config/polybar/config.ini" "$HOME/.config/polybar/config.ini"

# Seletor de wallpapers (F10) e guia de atalhos (F1): bordas retas, como os demais rofis.
# Só no Void; o sway-full continua com o arredondamento original.
log "Rofis do Void (wallpaper e atalhos): bordas retas"
for f in "$HOME"/.config/rofi-wallpaper/*.rasi "$HOME/.config/rofi/hotkeys.rasi"; do
  if [[ -f $f ]]; then
    sed -i -E 's/border-radius: *[0-9]+px;/border-radius: 0px;/' "$f"
  fi
done

# Neovim: clone de amonetlol/nvim em ~/.config/nvim (módulo setup-nvim do amonetlol/sh).
log "Neovim: setup-nvim"
nvim_tmp="$(mktemp)"
if curl -fsSL -o "$nvim_tmp" https://raw.githubusercontent.com/amonetlol/sh/main/modules/setup-nvim.sh; then
  sed -i 's/\r$//' "$nvim_tmp"
  bash "$nvim_tmp" || warn "Falha no setup-nvim; execute o módulo manualmente."
else
  warn "Não foi possível baixar o setup-nvim."
fi
rm -f -- "$nvim_tmp"

# Layout do X (SDDM e sessão): teclado ABNT2 do Brasil, conforme o padrão ONE.
log "Teclado do X: br / abnt2"
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
    Option "XkbModel" "pc105"
EndSection
EOF

log "Fixes v3 do Void concluídos. Reinicie a sessão para o launcher atualizar; o layout do SDDM vale após 'sudo sv restart sddm' ou reboot."
