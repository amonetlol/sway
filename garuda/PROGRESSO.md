# Instalação Garuda Sway na TWO

Status: instalação e configuração preparadas; boot, login e aparência ainda não foram testados na VM. O usuário verificará o visual posteriormente.

- ISO: garuda-kde-lite-linux-garuda-260819.iso; SHA-256 686b69d506bcfa105cd09b873e6e6e5b7b5b5a45a72c7ed974f4999d5e682764.
- Raiz @garuda, home @garuda-home, compartilhamento @shared, snapshots @snapshots-garuda. Primeiro snapshot criado; timer diário mantém quatro automáticos.
- Instalação baseada nas camadas rootfs, desktopfs e ghtfs da ISO. Pacotes e atualizações concluíram com código 0. O chroot usou /run isolado e proteção das variáveis EFI.
- Sway, Waybar, Kitty, Firefox, Nautilus, Rofi, Micro, eza, duf, fd, fzf, starship, awww, ferramentas Wayland, VMware Tools e term-hub preparados. Configuração em config/ deriva de sway-full e ../dummy; sway -C passou com backend headless. A sessão e os aplicativos não foram testados graficamente.
- Usuário pio, sudo, SSH, NetworkManager, SDDM com Catppuccin Frappe Blue, idioma pt-BR, teclado e timezone configurados. Micro com Catppuccin Frappe. Links para wallpapers, ícones, temas e fontes compartilhados preparados.
- GRUB instalado em EFI/garuda com --no-nvram; initramfs do kernel gerado, grub-script-check passou e entrada adicionada ao Aarambh. Boot não testado; Aarambh permanece primeiro na UEFI.
- A ISO trouxe configuração Snapper incompleta; os hooks de pre/post snap-pac foram desativados por overrides e o timer de limpeza Snapper foi desabilitado. A retenção de quatro snapshots é feita pelo script ff-snapshot-garuda.sh e respectivo timer. Outros hooks de pacote foram preservados.
- Monitoramento: /tmp/ff-garuda.log, /tmp/ff-install.log, /tmp/ff-scripts.log e /tmp/ff-downloads.log. Os scripts de instalação e a configuração estão nesta pasta.
- Pendências: testar boot, SSH, SDDM, sessão Sway, Waybar, wallpaper, resolução e aplicativos quando o usuário estiver disponível. Não foram removidos aplicativos; remoções foram deixadas para acompanhamento posterior.
- Ordem definida pelo usuário: Manjaro > Slackware > Garuda.

O usuario iniciou o Garuda e relatou falha ao abrir o Kitty. Os logs mostraram falha de importacao de buffers no Wayland/VMware; configurada abertura pelo XWayland com renderizacao por software, no atalho Sway e nos lancadores. Sway recarregado; aguarda teste do usuario.

Kitty continuou sem abrir e Nautilus tambem falhou. O log mostrou falha de dmabuf no XWayland e permissao negada no atalho do Nautilus. Corrigidas permissoes dos scripts e configurado WLR_RENDERER=pixman via /etc/environment; exige novo login e teste do usuario.

Apos novo login, o usuario confirmou que Kitty e Nautilus abrem com as correcoes aplicadas.

Ajustes de usuario (rofi, hotkeys, nvim, aliases):
- Rofi: powermenu em type-1 com paleta rose-pine e rotulos em pt-BR; launcher em type-2 style-2 (1 coluna, 360px); hotkeys com THEME_FILE em ~/.config/rofi/hotkeys/hotkeys.rasi. Sway usa $menu = launchers/type-2/launcher.sh e $power = powermenu/type-1/powermenu.sh.
- Scripts rofi com LF e bit de execucao (CRLF quebrava o shebang e impedia Super+D).
- Neovim: pacotes via pacman, modulo setup-nvim (amonetlol/sh), yay-bin do AUR; alias micro=nvim e EDITOR/VISUAL=nvim no .bashrc; .aliases-arch de amonetlol/dot. Primeira abertura exige :Lazy sync.
- Tudo reunido em ajustes-usuario.sh (idempotente; testado na Garuda live). Fontes ttf-jetbrains-mono-nerd e ttf-iosevka-nerd instaladas via pacman (extra) na Garuda; verificadas com fc-list.
- Pendencias: causa do travamento de tela (awww-daemon com SIGABRT no encerramento da sessao) ainda em investigacao; testar Super+D, Super+X e Super+F1 apos novo login.

Limpeza de aplicativos (regras em default-remove_and_hide.txt):
- KDE Plasma removido (plasma-desktop, plasma-login-manager, plasma-nm, plasma-pa, kscreen, kwallet-pam, dolphin, ark, kde-gtk-config e dependencias). SDDM, sway, kitty e xorg-xwayland mantidos; xorg-xwayland, ttf-hack, ripgrep, hunspell, xsettingsd e breeze-gtk marcados como explicitos antes da remocao. konsole removido.
- Ocultados via config/bin/hide-shortcuts: avahi/qt/rofi/btop/nvim/micro/lstopo/xgps e, pelo arquivo de perguntas, yad-icon-browser, yad-settings, garuda-system-maintenance-settings, garuda-toolbox, reboot-to-uefi, setup-assistant, snapper-tools, suspend-then-hibernate.
- Files renomeado para Nautilus (nautilus mantido; kitty e nautilus nao removidos).
- Powermenu (Super+X): removido o segundo menu de confirmacao (Sim/Nao); a acao escolhida executa direto. Aplicado no dummy, no repo garuda (config/rofi-dummy) e na Garuda live.
- ajustes-usuario.sh executa a remocao e o hide-shortcuts; testado na Garuda live.
- Pendencia: alterar o rice dummy (F:\GitHub\sway\dummy) para refletir a lista de ocultacao acima e o rename Files -> Nautilus; o rice dummy ainda nao foi alterado.

Pendencias para aplicar na Garuda (pendente, a maquina TWO esta em Slackware no momento):
- Powermenu (Super+X): restaurar os icones Nerd Font antes dos rotulos. O repo garuda/config/rofi-dummy ja foi corrigido (glifo + texto PT-BR); falta copiar para ~/.config/rofi/powermenu/type-1/powermenu.sh na Garuda live e testar. Hibernar segue comentado.
- Verificar se o tema de icones RoséPine da Garuda tem arquivos SVG que sao apenas texto com o nome de outro icone (links simbolicos copiados como texto, ex.: places/folder.svg). No Slackware havia cerca de 39 mil desses stubs, e 3 image-missing.svg invalidos fizeram o Nautilus abortar. Corrigido no Slackware apontando cada stub para o arquivo real; na Garuda, conferir e aplicar o mesmo ajuste se necessario.
- Testar o Super+E (Nautilus) e o Super+X depois de aplicar.