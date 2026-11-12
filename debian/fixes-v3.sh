#!/usr/bin/env bash
# Fixes v3 do Debian: term-hub, pastas padrão em pt-BR e Nautilus em pt-BR.
# O GRUB com o tema bsol fica em install-grub.sh.
# Idempotente: pode ser executado de novo sem efeito extra.
#   bash debian/fixes-v3.sh
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }
sudo -v

log "Dependências do term-hub (git, python3, tmux, ssh, curl)"
sudo apt-get install -y git python3 tmux openssh-client curl

log "Nautilus em pt-BR (LANG=pt_BR.UTF-8) e ferramentas de pastas padrão"
sudo apt-get install -y xdg-user-dirs xdg-user-dirs-gtk

log "Pastas padrão em pt-BR"
mkdir -p "$HOME/Área de trabalho" "$HOME/Documentos" "$HOME/Música" \
  "$HOME/Vídeos" "$HOME/Modelos" "$HOME/Público" "$HOME/Downloads" "$HOME/Imagens"

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

log "term-hub: instalar ou atualizar para a versão atual do repositório"
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sh/main/modules/hub-ssh_term.sh) \
  || warn "Falha ao instalar o term-hub; execute o instalador manualmente."

log "Fixes v3 do Debian concluídos. Reinicie a sessão Sway para o Nautilus usar pt-BR."
