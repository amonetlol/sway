#!/usr/bin/env bash
# Fixes v3 do Fedora: remove apps, pasta padrao pt-BR e Nautilus em pt-BR.
# Idempotente: pode ser executado de novo sem efeito extra.
#   bash fedora/fixes-v3.sh
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }

log "Remover apps: blackbox-terminal, ulauncher, foot"
remove=()
for pkg in blackbox-terminal ulauncher foot; do
  rpm -q "$pkg" >/dev/null 2>&1 && remove+=("$pkg")
done
if ((${#remove[@]})); then
  sudo dnf remove -y "${remove[@]}"
else
  log "Nenhum dos apps está instalado."
fi

log "Nautilus em pt-BR e ferramentas de pastas padrão"
sudo dnf install -y langpacks-pt_BR xdg-user-dirs xdg-user-dirs-gtk

log "Pastas padrão em pt-BR (renomeia só as vazias)"
cd "$HOME"
for pair in "Desktop:Área de trabalho" "Documents:Documentos" "Music:Música" \
            "Videos:Vídeos" "Templates:Modelos" "Public:Público"; do
  old="${pair%%:*}"
  new="${pair#*:}"
  if [[ -d "$old" && -z "$(ls -A "$old")" ]]; then
    mv "$old" "$new"
    log "Renomeado: $old -> $new"
  else
    mkdir -p "$new"
  fi
done
if [[ -d Pictures && -z "$(ls -A Pictures)" ]]; then
  rmdir Pictures
  log "Removida Pictures vazia (Imagens é a pasta em uso)"
fi
mkdir -p Downloads Imagens

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

log "term-hub: atualizar para a versão atual do repositório"
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sh/main/modules/hub-ssh_term.sh) \
  || warn "Falha ao atualizar o term-hub; execute o instalador manualmente."

log "Fixes v3 do Fedora concluídos. Reinicie a sessão Sway para o Nautilus usar pt-BR."
