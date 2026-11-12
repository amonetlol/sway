# Manjaro Sway/Niri - progresso

Pendencias para aplicar na maquina:
- Powermenu (Super+X) sem confirmacao Sim/Nao. Repo atualizado em config/rofi-dummy/powermenu/powermenu.sh (dir continua type-6, como no config/niri/binds.kdl). Aplicar em ~/.config/rofi/powermenu/type-6/powermenu.sh, chmod +x, e testar o Super+X.
- Nao aplicado: lista de ocultacao de atalhos e rename Files -> Nautilus da Garuda. Este repo ainda nao tem hide-shortcuts; decidir se entra.

Aplicado na maquina Manjaro (12/11, 12:45):
- SDDM: tema catppuccin-frappe-blue instalado em /usr/share/sddm/themes e ativo por /etc/sddm.conf.d/99-catppuccin.conf.
- Resolucao: niri output Virtual-1 em 1600x900@60 (config.kdl com backup config.kdl.bak-20261112-124525).
- Rofi do dummy: launcher em launchers/type-2 (style-2, 1 coluna); powermenu em powermenu/type-1 (rose-pine, icones + texto PT-BR, Hibernar ausente); hotkeys em ~/.config/rofi/hotkeys; wallpaper atualizado.
- Binds (binds.kdl, backup binds.kdl.bak-20261112-124525): Super+D e Alt+D apontam para launchers/type-2; Super+X e Alt+X para powermenu/type-1; Super+F1 chama ~/.local/bin/show-hotkeys (lista do niri, em vez do overlay padrao).
- Wallpaper (Super+F10): ~/.local/bin/random-wallpaper.sh instalado (o wallpaper.py chamava um script inexistente). Teste de aplicacao OK.
- .aliases-arch instalado a partir de amonetlol/dot (dotfiles/bash/.aliases-arch) e carregado pelo .bashrc.
- GNOME removido com pacman -R (sem -s), 31 pacotes: os 30 aprovados (gnome-shell, gdm, gnome-control-center, gnome-session, gnome-settings-daemon, gnome-browser-connector, gnome-shell-extensions etc.) mais mutter, que bloqueava a transacao. Mantidos: nautilus, gvfs, xdg-user-dirs-gtk, sddm, niri, pipewire, wireplumber, bluez.
- Super+M (Mod+M / Alt+M, toggle de resolucao): o bind chamava ~/.local/bin/mon, que nao existia na maquina. Instalado a partir de garuda/config/bin/mon (igual ao sway-full/.local/bin/mon, com --niri). Testado: 1600x900 <-> 1920x1080, ok.
- yay-bin instalado via makepkg (AUR: aur.archlinux.org/yay-bin.git), yay v13.1.0. base-devel e git instalados antes.
- setup-nvim.sh (amonetlol/sh) executado: config em ~/.config/nvim e /root/.config/nvim (amonetlol/nvim), pacotes via yay. Binario neovim instalado via pacman (v0.12.5), que o script nao instala.
- Aliases: em ~/.aliases (backup ~/.aliases.bak-*), micro trocado por nvim (nv, v, tx, al, al2, aln, alw, ewb, j-edit, fv). ~/.functions: fallback do editor em edit_aliases_distro (al2) e vf passaram a nvim (backup ~/.functions.bak-*). O alias aln segue apontando para ~/.config/micro/settings.json.
- Dependencias orfas deixadas de proposito (audio, Bluetooth, flatpak, ibus, etc.). Sao 35 orfaos; limpeza com pacman -Qdtq fica pendente para decidir depois.