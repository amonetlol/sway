#!/usr/bin/env bash
# Fixes v3 do Ubuntu: pacotes equivalentes ao rice do Arch, term-hub,
# Nautilus em pt-BR, pastas padrão em pt-BR, ocultar/renomear itens do
# launcher (0-default-remove_and_hide.txt), remover foot e tema GTK/ícones.
# O GRUB com o tema bsol fica em install-grub.sh.
# Idempotente: pode ser executado de novo sem efeito extra.
#   bash ubuntu/fixes-v3.sh
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v

log "Pacotes equivalentes ao rice do Arch (sway-full)"
sudo apt-get install -y \
  mako-notifier policykit-1-gnome libnotify-bin xwayland xauth \
  network-manager fonts-font-awesome libqt6svg6 \
  qml6-module-qt5compat-graphicaleffects libqt6core5compat6 \
  fonts-firacode fonts-nerd-symbols fonts-cantarell gnome-themes-extra \
  alsa-utils

log "term-hub: dependências e instalação/atualização"
sudo apt-get install -y git python3 tmux openssh-client curl
# Baixa para arquivo (process substitution travou nesta máquina).
hub_tmp="$(mktemp)"
trap 'rm -f -- "$hub_tmp"' EXIT
if curl -fsSL -o "$hub_tmp" https://raw.githubusercontent.com/amonetlol/sh/main/modules/hub-ssh_term.sh; then
  bash "$hub_tmp" || warn "Falha ao instalar o term-hub; execute o instalador manualmente."
else
  warn "Não foi possível baixar o instalador do term-hub."
fi

log "Nautilus em pt-BR e ferramentas de pastas padrão"
sudo apt-get install -y language-pack-gnome-pt language-pack-pt \
  xdg-user-dirs xdg-user-dirs-gtk

log "Pastas padrão em pt-BR"
mkdir -p "$HOME/.config" "$HOME/Área de trabalho" "$HOME/Documentos" \
  "$HOME/Música" "$HOME/Vídeos" "$HOME/Modelos" "$HOME/Público" \
  "$HOME/Downloads" "$HOME/Imagens"
cat > "$HOME/.config/user-dirs.dirs" <<'EOF'
XDG_DESKTOP_DIR="$HOME/Área de trabalho"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_TEMPLATES_DIR="$HOME/Modelos"
XDG_PUBLICSHARE_DIR="$HOME/Público"
XDG_DOCUMENTS_DIR="$HOME/Documentos"
XDG_MUSIC_DIR="$HOME/Música"
XDG_PICTURES_DIR="$HOME/Imagens"
XDG_VIDEOS_DIR="$HOME/Vídeos"
EOF
log "user-dirs.dirs gravado em ~/.config"

log "Remover foot (pedido explícito; configs residuais também)"
sudo apt-get purge -y foot || warn "foot não estava instalado."

# Ocultar (NoDisplay=true) ou renomear um .desktop do sistema.
# Cria override em ~/.local/share/applications; não altera /usr/share.
override_desktop() {
  local id="$1" mode="$2"
  local src="/usr/share/applications/$id.desktop"
  local dst="$HOME/.local/share/applications/$id.desktop"
  if [[ ! -f $src ]]; then
    log "Ignorado (não instalado): $id"
    return 0
  fi
  mkdir -p "$HOME/.local/share/applications"
  cp "$src" "$dst"
  if [[ $mode == hide ]]; then
    if grep -q '^NoDisplay=' "$dst"; then
      sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$dst"
    else
      sed -i '/^\[Desktop Entry\]/a NoDisplay=true' "$dst"
    fi
    log "Oculto: $id"
  elif [[ $mode == rename-nautilus ]]; then
    sed -i -e 's/^Name=.*/Name=Nautilus/' -e '/^Name\[/d' "$dst"
    log "Renomeado: $id -> Nautilus"
  fi
}

log "Ocultar itens do launcher (seção 1 e ASK respondido)"
for id in btop micro nvim htop rofi rofi-theme-selector vim \
          org.freedesktop.IBus.Setup display-im7.q16 \
          gnome-language-selector slicksddm-customize; do
  override_desktop "$id" hide
done

log "Renomear Files para Nautilus (seção 4)"
override_desktop org.gnome.Nautilus rename-nautilus

log "Tema GTK e ícones (gsettings)"
if command -v gsettings >/dev/null 2>&1; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || warn "gsettings: color-scheme"
  gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Dark-Catppuccin' || warn "gsettings: gtk-theme"
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' || warn "gsettings: icon-theme"
  gsettings set org.gnome.desktop.interface cursor-theme 'Vimix-cursors' || warn "gsettings: cursor-theme"
else
  warn "gsettings não encontrado; tema GTK não aplicado."
fi

log "Fixes v3 do Ubuntu concluídos. Reinicie a sessão Sway para o Nautilus usar pt-BR."
log "Pendente: setup-nvim.sh (módulo não incluído neste script) e GRUB (install-grub.sh)."
