# Chimera (host two)

Estado da máquina em 12/11. Configs copiadas do host estão nas pastas `niri/`, `starship/`, `rofi/`, `micro/` e `aliases/`.

Aplicado:
- Niri binds: Super+F1 (show-hotkeys), Super+D/Alt+D (launcher type-2 do dummy), Super+X/Alt+X (powermenu adaptado para esta distro), Super+F10/Alt+F10 (wallpaper do dummy), Super+V (clipboard do dummy), Super+M (resolução).
- Resolução: Virtual-1 em 1600x900@60 (`niri/config.kdl`).
- Rofi: launchers/type-2, powermenu/type-1, wallpaper, hotkeys e clipboard copiados do dummy.
- Powermenu: `systemctl` trocado por `loginctl` (elogind), sair pelo `niri msg action quit`, bloquear pelo `swaylock`.
- Wallpaper: `~/.local/bin/random-wallpaper.sh` usa `awk` no lugar de `shuf`, que não existe nesta distro. Aplicar imagem específica testado.
- Clipboard: coletor `wl-paste --watch cliphist store` no spawn-at-startup do niri.
- Aliases: `~/.aliases-chimera` (mesmo padrão de nomes do `.aliases-arch`, só os comandos mudaram para apk/doas). `nvim` trocado por `micro` em `~/.aliases`. Sem equivalente: yay, rpac, orf.
- Micro: tema catppuccin-frappe em `micro/settings.json` (colorscheme instalado em `~/.config/micro/colorschemes/`).
- Starship: ícone do fantasminha (glyph U+F02A0) na chave `Linux`, que é como o starship detecta esta distro. Chave `Chimera` removida (starship não aceita). Em todos os starship-*.toml.
- Pacotes do rice instalados: eza, grim, slurp, bat, ripgrep, zoxide, neovim, wlogout, mako, swayidle, playerctl, pavucontrol, micro, awww.
- Plasma: removidos 31 pacotes (apps e addons KDE, com dry-run). Mantidos sddm, sddm-dinit, sddm-default-cage, breeze, breeze-icons, bluedevil, kded, kdecoration, kdeclarative, oxygen, plasmashell e kwin (exigidos pelo display manager).
- Default remove/hide, seção 1 (ocultar): rofi, rofi-theme-selector, btop, micro, nvim (só os instalados).
- Default remove/hide, seção 4 (renomear): Nautilus "Files" -> "Nautilus".
- Só nesta distro: ocultados KWalletManager (`org.kde.kwalletmanager`) e Configurações do sistema KDE (`kdesystemsettings`).

Pendente:
- Rice dummy para personalizado: ver dummy/PROGRESSO.md. Decidir o que muda nesta máquina (wallpapers, atalhos, lista de apps ocultos e removidos).
- Pacote `duf` não existe nos repositórios desta distro. Decidir substituto ou ignorar.
- Plasma: plasmashell e kwin continuam instalados porque o SDDM depende deles. Remover de vez exige trocar o display manager.
- Validar visualmente: Super+F1, Super+D/X/V/F10, menu de energia (Super+X), wallpaper pelo rofi, ícone do starship no prompt.
- Ícone do Chimera no starship é o fantasminha genérico, não o logo oficial.
