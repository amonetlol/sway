# EndeavourOS (host two)

Estado da máquina em 12/11. Configs copiadas do host estão nas pastas `niri/`, `waybar/` e `starship/`.

Aplicado:
- SDDM: tema catppuccin-frappe-blue em /usr/share/sddm/themes, ativo por /etc/sddm.conf.d/99-catppuccin.conf.
- Niri binds: Super+F1 (show-hotkeys), Super+D/Alt+D (launcher type-2 do dummy), Super+X/Alt+X (powermenu type-1 do dummy), Super+F10/Alt+F10 (wallpaper do dummy), Super+V (clipboard do dummy), Super+M (resolução).
- Rofi: launchers/type-2, powermenu/type-1, wallpaper, hotkeys e clipboard copiados do dummy.
- Super+F1: lista de atalhos ajustada com os binds do niri.
- Wallpaper: ~/.local/bin/random-wallpaper.sh instalado e testado.
- Clipboard: coletor `wl-paste --watch cliphist store` adicionado ao spawn-at-startup do niri.
- Starship: ícone EndeavourOS no lugar do CachyOS (em todos os starship-*.toml).
- Waybar: ícone EndeavourOS no launcher da esquerda; workspaces mostram números 1 a 5.
- Default remove/hide: seção 1 (ocultar) aplicada; xterm removido (sem -s, libxaw ficou); Nautilus renomeado; Software Token ocultado; nwg-look mantido.

Pendente:
- Rice dummy para personalizado: ver dummy/PROGRESSO.md. Decidir o que muda nesta máquina (wallpapers, atalhos, lista de apps ocultos e removidos).
- Validar visualmente: SDDM no próximo login, Super+V, Super+F1, Super+D/X/F10, ícones do starship e da waybar.
- Pacotes órfãos e `zint` seguem como decidido no default (zint: ocultar, remoção bloqueada).
