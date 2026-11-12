# Slackware Niri na TWO

Status: instalação e configuração preparadas; boot, login e aparência ainda não foram testados na VM. O usuário verificará o visual posteriormente.

- ISO: slackware64-current-install-dvd.iso; SHA-256 7244830701bd6704a7093f15e36b038ae0117e56be5246e1e38405a37f58ea73.
- Raiz @slackware, home @slackware-home, compartilhamento @shared, snapshots @snapshots-slackware. Primeiro snapshot criado; rotina diária mantém quatro automáticos.
- Séries a, ap, d, l, n, x e xap instaladas. Sistema 64 bits, sem systemd; usuário pio, SSH, sudo, NetworkManager, SDDM, locale e teclado preparados.
- Niri 26.04 compilado sem integração systemd; libdisplay-info 0.3 isolada em /usr/local/ff-niri-compat, preservando a versão do sistema. Configuração Niri validada por niri validate.
- Waybar, Rofi, Kitty, Firefox, Nautilus, awww, Micro, starship, eza, duf, fd, fzf, fastfetch, cliphist e term-hub instalados. Tema Micro Catppuccin Frappe; elementos de ../../dummy e diretórios compartilhados preparados. A execução gráfica dos aplicativos ainda não foi validada.
- O Nautilus e suas dependências foram compilados de SlackBuilds; os ajustes para Tracker estão nos scripts e patches desta pasta. O gexiv2 foi compilado da fonte oficial GNOME.
- GRUB instalado em EFI/slackware com --no-nvram; initrd contém o driver VMware mptspi; grub-script-check passou e a entrada foi adicionada ao Aarambh. Boot não testado.
- Monitoramento: /tmp/ff-slackware.log, /tmp/ff-install.log e /tmp/ff-scripts.log. Scripts usados ou preparados estão nesta pasta; os arquivos visuais são derivados de ../../manjaro/config e ../../dummy.
- Falhas corrigidas durante a instalação: PATH do instalador, certificados, versão de libdisplay-info, endereços de fontes e compatibilidade de builds Tracker. Não foram removidos aplicativos a pedido do usuário.
- Pendências: confirmar boot, SSH, SDDM, sessão Niri, Waybar, tema, wallpaper e aplicativos quando o usuário estiver disponível; corrigir falhas observadas. A aparência ainda não foi conferida.
- Ordem definida pelo usuário: Manjaro > Slackware > Garuda.

O DHCP atribuiu 192.168.86.170 ? TWO; o perfil foi ajustado para 192.168.86.128 e o SSH reconectou. O teclado virtual foi desativado em /etc/sddm.conf; confirmar no pr?ximo login.

O Rofi apresentou falha ao criar buffer Wayland. /dev/shm estava sem montagem tmpfs e sem permiss?o de escrita para pio; permiss?es corrigidas na sess?o e montagem adicionada ao fstab. A cria??o de arquivo compartilhado foi verificada e o usu?rio confirmou que o Rofi abriu. Falta confirmar a montagem tmpfs ap?s reiniciar.

Pendencia (powermenu, sem confirmacao Sim/Nao):
- Aplicado na maquina Slackware em 10:42 (backup em powermenu.sh.bak-before-ff). Hibernar comentado no menu; as acoes executam direto.
- Rofi do dummy aplicado no Slackware: launcher em launchers/type-2 (style-2, 1 coluna, rose-pine) e powermenu em powermenu/type-1 (estilos rose-pine). binds.kdl aponta para esses caminhos (backup binds.kdl.bak-before-ff). Os antigos type-4 e type-6 ficaram nas pastas.
- Falta testar Super+D e Super+X na tela. Hotkeys (Super+F1) nao aplicados: este Slackware nao tem show-hotkeys.
- Nao aplicado: lista de ocultacao de atalhos e rename Files -> Nautilus usados na Garuda; este repo nao tem hide-shortcuts.

Ajustes na maquina Slackware (10:49):
- SDDM: tema catppuccin-frappe-blue em /etc/sddm.conf (antes estava breeze na base; o drop-in 20-theme.conf ja apontava para catppuccin). Backup em /etc/sddm.conf.bak-before-ff.
- Resolucao: niri output Virtual-1 em 1600x900@60 (backup config.kdl.bak-before-ff).
- .aliases-slackware instalado a partir de amonetlol/dot (o .bashrc-dot ja carregava esse arquivo no branch slackware).
- GTK: rose-pine-gtk ja identico ao dummy (gtk-3.0 e gtk-4.0). Nada a aplicar.
- Dry-run de remocao (nada removido): labwc-0.20.3 (76 caminhos, inclui /usr/share/wayland-sessions/labwc.desktop) e windowmaker-0.96.0 (516 caminhos, inclui /usr/share/xsessions/wmaker.desktop). Pendente: confirmar a remocao; wlroots ficaria sem uso; xwmconfig.desktop (xinit) nao foi listado.

Remocao e ajustes finais (10:50):
- labwc-0.20.3 e windowmaker-0.96.0 removidos (binarios e sessoes labwc.desktop e wmaker.desktop). Ficaram wlroots-0.20.2 (sem uso agora) e xwmconfig.desktop (xinit).
- micro: ~/.config/micro pertencia ao root; corrigido para pio e criado buffers/ (erro de historico ao usar o alias v).
- starship: o Slackware cai no simbolo Linux (starship 1.27 nao aceita nome personalizado); Linux agora usa o glifo do Slackware (nf-linux-slackware, U+F318). Backup em starship.toml.bak-before-ff.

Correcoes de rofi/GTK (10:55):
- Powermenu: rotulos com texto (dummy) restaurados no powermenu.sh do Slackware e instalados em powermenu/type-1 (backup powermenu.sh.bak-before-labels).
- Super+F1: binds.kdl usa show-hotkeys (menu do dummy, theme rofi/hotkeys/hotkeys.rasi). A lista de atalhos ainda e a do Sway (script vindo do repo garuda); falta uma lista propria do niri.
- Wallpaper (Super+F10): random-wallpaper.sh instalado em ~/.local/bin (o wallpaper.py chamava um script inexistente nessa maquina). Pasta ~/Imagens/wallpapers -> /home/share/wallpapers.
- GTK: gsettings estava em Adwaita/default, o que sobrepunha o settings.ini. Definido gtk-theme rose-pine-gtk, icon-theme RoséPine, color-scheme prefer-dark.

- Super+F1 (11:00): show-hotkeys do Slackware agora lista os binds do niri (binds.kdl), com comando para as acoes diretas. A copia do repo esta em niri/show-hotkeys.

Sessao de 12/11 (11:00 a 12:17), aplicado diretamente na maquina:
- Starship: o simbolo Linux do starship-nord.toml (prompt ativo, via STARSHIP_CONFIG) usa o glifo do Slackware (U+F318).
- Powermenu: rotulos com icone Nerd Font + texto PT-BR (Hibernar comentado). Repo: niri/powermenu.sh; live: powermenu/type-1/powermenu.sh.
- Nautilus (Super+E) nao abria: o tema de icones RoséPine tinha 3 image-missing.svg invalidos e cerca de 39 mil stubs de texto (links copiados como texto). Substituido pelo tema oficial rose-pine v2.2.0 (GTK3 rose-pine, rose-pine-moon, rose-pine-dawn; GTK4 gtk.css; icones rose-pine-icons). Backup em ~/.local/share/rp-backup-20261112-111808. settings.ini (gtk-3.0 e gtk-4.0) e gsettings usam rose-pine-gtk e rose-pine-icons.
- Zips dos originais salvos no dummy: temas/rose-pine-gtk.zip e temas/rose-pine-icons.zip (manifesto LINKS.txt recria os links no Linux).
- up2: ~/.bin/slackpkg-size passou a ser executavel (estava 600). /etc/slackpkg/mirrors com o mirror oficial https://mirrors.slackware.com/slackware/slackware64-15.0/ ativo.
- Duplicados do slackpkg: gexiv2-0.14.7-x86_64-1ff removido (arquivos exclusivos e registro; gexiv2 0.16.2 mantida). polkit-gnome-0.105-x86_64-1ff: so o registro removido (os arquivos sao os mesmos da -5). Backup dos registros em ~/.local/share/pkg-dup-backup-20261112-112240.
- Remocao de pacotes (lista default-remove_and_hide.txt, secao 2), apos dry-run: audacious, simplescreenrecorder, ddd, distcc, easytag, gnuchess (eboard, xboard), cdrdao (gcdmaster), gftp, gkrellm, gparted, gucharmap, vim-gvim, hexchat, qalculate-qt, qalculate-gtk, joe, lftp, geeqie, glade, pan, pidgin, rxvt-unicode, seamonkey, soma, thunderbird, xterm, xaos, xine-ui, xmms, xpaint, xpdf, xsane, xscreensaver, xsnow, xinput_calibrator, nmap, gimp-3.2.8, hplip, zint.
- Nao removidos por dependencia (apenas ocultos): vte (usado pelo qemu), gtk4 (NodeEditor, PrintEditor4), vulkan-sdk (vulkanCapsViewer, usado pelo mpv).
- Ocultos com overrides em ~/.local/share/applications (NoDisplay=true): regras da secao 1 do default e respostas OCULTAR do ask (dconf-editor, gpa, IBus Setup, GTK Demo, Widget Factory, wpa_gui, fcitx5-configtool, Qt Assistant/Designer/Linguist/QDbusViewer, VTE, gtk4 NodeEditor/PrintEditor4, vulkanCapsViewer).
- Renomeado no menu: org.gnome.Nautilus aparece como Nautilus (era Files).
- Mantidos sem alteracao (NAO_MEXER): blueman-adapters, blueman-manager, mplayer, mpv, pavucontrol, nm-connection-editor. Sem resposta: nada.
- Pendencias: lista de regras completa em Downloads/Mult_ONE-chatGPT/default-remove_and_hide.txt e ask-remove_or_hide_or_untouched.txt (respostas pendentes para novos itens visiveis). Os passos acima estao so na maquina, nao em script; reproduzir em um ajustes-usuario.sh do Slackware se for preciso.