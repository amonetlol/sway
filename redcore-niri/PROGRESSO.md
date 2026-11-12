# Redcore (host two)

Status: 100% Configurado.

Estado da máquina em 12/11. Configs copiadas do host estão nas pastas `niri/`, `waybar/`, `rofi/`, `bin/`, `dunst/`, `gtk/` e `xdg/`.

Aplicado:
- Resolução: Virtual-1 em 1600x900@60 (`niri/config.kdl`). Super+M alterna 1600x900 ↔ 1920x1080 com `bin/mon`, que reaplica o wallpaper e reinicia a Waybar depois da troca.
- Cursor: Vimix-cursors (niri e GTK).
- Super+F1: guia de atalhos (`bin/show-hotkeys`) com o tema da máquina (`rofi/hotkeys/hotkeys.rasi`, paleta Gruvbox, cantos retos, fonte JetBrains Mono para as colunas alinharem).
- Super+V: clipboard com cliphist + wl-clipboard (`rofi/clipboard/launch.sh`, usa o tema da máquina). Startup: `wl-paste --watch cliphist store`.
- Super+F10: seletor de wallpapers em grade (`rofi/wallpaper/`, tema da máquina). Aplica a imagem com `bin/random-wallpaper.sh` (awww).
- Super+X: menu de energia (`bin/power-menu.sh`) com ícone + texto. Desligar/reiniciar/suspender usam `loginctl`, sair usa `niri msg action quit`.
- Super+F12: recarrega a Waybar (`bin/waybar-reload.sh`).
- GTK: tema Colloid-Yellow-Dark-Gruvbox, ícones Gruvbox-Plus-Dark, cursor Vimix, preferência escura (`gtk/`, gsettings).
- Bordas: focus-ring do niri em amarelo Gruvbox (`#fabd2f`) e cinza (`#504945`).
- Waybar: bordas dos módulos e workspace ativo em amarelo Gruvbox (`waybar/theme.css`, `waybar/style.css`).
- Notificações: dunst com paleta Gruvbox e borda amarela (`dunst/dunstrc`).
- Nautilus: pastas padrão XDG (`xdg/user-dirs.dirs`): Desktop, Documents, Downloads, Music, Imagens, Videos.
- Pacotes instalados: wl-clipboard (compilado, log em `/tmp/ff-install.log` e `/tmp/ff-redcore.log`), cliphist (via Go, `~/.local/bin/cliphist`).
- Default remove/hide: seção 1 (ocultar) nos itens instalados; seção 4 (Nautilus renomeado para "Nautilus"); FontForge oculto. Seção 2: nenhum item presente. Seção 3 intacta.

Pendente:
- Ask (`ask-remove_or_hide_or_untouched.txt`, na pasta Downloads, fora do repo): aguardando respostas dos itens da seção A.
