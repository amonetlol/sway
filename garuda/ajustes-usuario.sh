#!/usr/bin/env bash
# Ajustes de usuario da Garuda Sway (rodar como pio, com sudo sem senha).
# Idempotente: pode ser executado de novo sem duplicar linhas.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { printf '[*] %s\n' "$1"; }
ok() { printf '[OK] %s\n' "$1"; }
warn() { printf '[AVISO] %s\n' "$1"; }

[[ "$(id -u)" -ne 0 ]] || { echo "Execute como usuario pio, nao como root." >&2; exit 1; }

# 1. Pacotes: neovim, git e base-devel (para o yay-bin)
log "Instalando pacotes base do neovim e do AUR"
sudo pacman -S --noconfirm --needed neovim git base-devel
ok "pacotes instalados"

# 2. yay-bin (AUR)
if command -v yay >/dev/null 2>&1; then
  ok "yay ja instalado"
else
  log "Instalando yay-bin do AUR"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm --needed)
  rm -rf "$tmp"
  ok "yay-bin instalado"
fi

# 3. Neovim: modulo setup-nvim (amonetlol) para usuario e root
log "Rodando modulo setup-nvim"
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sh/main/modules/setup-nvim.sh)
ok "setup-nvim concluido (rode :Lazy sync na primeira abertura)"

# 4. .aliases-arch (repo amonetlol/dot)
if [[ -f "$HOME/.aliases-arch" ]]; then
  ok ".aliases-arch ja existe"
else
  log "Baixando .aliases-arch do repo amonetlol/dot"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://github.com/amonetlol/dot.git "$tmp/dot"
  sed 's/\r$//' "$tmp/dot/dotfiles/bash/.aliases-arch" > "$HOME/.aliases-arch"
  chmod 600 "$HOME/.aliases-arch"
  rm -rf "$tmp"
  ok ".aliases-arch instalado"
fi

# 5. Editor: micro -> nvim e EDITOR/VISUAL
touch "$HOME/.bashrc"
grep -q "^alias micro='nvim'" "$HOME/.bashrc" || echo "alias micro='nvim'" >> "$HOME/.bashrc"
grep -q "^export EDITOR=nvim" "$HOME/.bashrc" || printf '%s\n' 'export EDITOR=nvim' 'export VISUAL=nvim' >> "$HOME/.bashrc"
ok "alias micro -> nvim e EDITOR=nvim no .bashrc"

# 6. Rofi (powermenu type-1, launcher type-2, hotkeys) e show-hotkeys
ROFI="$HOME/.config/rofi"
mkdir -p "$ROFI/powermenu/type-1" "$ROFI/launchers/type-2/shared" "$ROFI/hotkeys" "$HOME/.local/bin"
cp "$REPO/config/rofi-dummy/powermenu/"* "$ROFI/powermenu/type-1/"
cp "$REPO/config/rofi-dummy/launcher/launcher.sh" "$REPO/config/rofi-dummy/launcher/style-2.rasi" "$REPO/config/rofi-dummy/launcher/style-9.rasi" "$ROFI/launchers/type-2/"
cp "$REPO/config/rofi-dummy/launcher/shared/"*.rasi "$ROFI/launchers/type-2/shared/"
cp "$REPO/config/rofi-dummy/hotkeys/"*.rasi "$ROFI/hotkeys/"
cp "$REPO/config/bin/show-hotkeys" "$HOME/.local/bin/show-hotkeys"
chmod +x "$ROFI/powermenu/type-1/powermenu.sh" "$ROFI/launchers/type-2/launcher.sh" "$HOME/.local/bin/show-hotkeys"
ok "rofi e show-hotkeys copiados"

# 7. Sway: menu do launcher e powermenu apontando para os novos caminhos
SWAY="$HOME/.config/sway/config"
if [[ -f "$SWAY" ]]; then
  sed -i \
    -e 's#launchers/type-4/launcher.sh#launchers/type-2/launcher.sh#' \
    -e 's#powermenu/type-6/powermenu.sh#powermenu/type-1/powermenu.sh#' \
    "$SWAY"
  ok "sway: \$menu e \$power atualizados (recarregue com swaymsg reload)"
else
  warn "$SWAY nao encontrado; ajuste \$menu e \$power manualmente"
fi

# 8. Remover KDE e konsole (mantém sddm e dependências)
# Pacotes que ficam explícitos para não serem levados pela remoção em cascata
KEEP="xorg-xwayland ttf-hack ripgrep hunspell xsettingsd breeze-gtk"
KDE_REMOVE="ark dolphin kscreen kwallet-pam plasma-desktop plasma-login-manager plasma-nm plasma-pa kde-gtk-config konsole"
log "Marcando pacotes a manter como explícitos"
sudo pacman -D --asexplicit $KEEP >/dev/null 2>&1 || warn "Alguns pacotes a manter não estão instalados"
to_remove=""
for p in $KDE_REMOVE; do pacman -Qq "$p" >/dev/null 2>&1 && to_remove="$to_remove $p"; done
if [[ -n "$to_remove" ]]; then
  log "Removendo:$to_remove"
  sudo pacman -Rs --noconfirm $to_remove
  ok "KDE e konsole removidos"
else
  ok "KDE e konsole já removidos"
fi

# 9. Ocultar atalhos do launcher (lista do repo)
log "Ocultando atalhos do launcher"
mkdir -p "$HOME/.local/bin"
cp "$REPO/config/bin/hide-shortcuts" "$HOME/.local/bin/hide-shortcuts"
chmod +x "$HOME/.local/bin/hide-shortcuts"
"$HOME/.local/bin/hide-shortcuts"

log "Concluido."
