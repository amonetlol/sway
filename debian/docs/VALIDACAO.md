# Validação realizada

Configuração aplicada em Debian 13 amd64 em 05/11/2026.

- Autenticação SSH por chave confirmada; usuário adicionado ao grupo sudo.
- Sway 1.10.1: configurações dos temas 2SSk e theme-gruvbox aceitas por `sway --validate`.
- Ghostty 1.3.1: `ghostty +validate-config` passou.
- Quickshell 0.3.2: compilação e instalação concluídas contra o Qt do Debian; versão confirmada pela CLI.
- Firefox DEB da Mozilla 159.0.1 instalado; Firefox ESR removido.
- GRUB Leaf instalado; `grub-script-check` passou.
- SDDM habilitado e ativo; sessão Sway selecionada para o usuário.
- Timer de wallpaper habilitado com intervalo de 90 segundos.
- Sintaxe Bash/Python, JSON, nomes dos pacotes e checksums dos assets conferidos.

Não houve inspeção visual nem teste interativo do desktop. O instalador foi validado estaticamente; ainda não foi executado do início ao fim em uma segunda máquina limpa. Fontes, wallpapers, plugins do Neovim e alguns pacotes são obtidos pela rede.

A separa??o dos tr?s instaladores e a busca din?mica dos reposit?rios pessoais receberam valida??o est?tica. Os tr?s novos instaladores n?o foram executados contra a sess?o em uso. O painel 2SSk recebeu uma adapta??o da sombra para Qt 6.8; ap?s reiniciar somente seu servi?o, o log registrou `Configuration Loaded`.

Ap?s o encerramento do Sway ao abrir Kitty pelo XWayland, o log e o core dump confirmaram nova falha no caminho DMA-BUF. O lan?ador da sess?o foi ajustado para Pixman/XWayland sem glamor em VMware; sintaxe e Exec do SDDM conferidos. O novo login com esse ajuste ainda depende da confer?ncia do usu?rio.

## Debian Sid ? 05/11/2026

A VM foi migrada para Sid por solicita??o do usu?rio. `apt full-upgrade` terminou com c?digo zero; `dpkg --audit`, `apt-get check` e `grub-script-check` passaram. Vers?es: Qt 6.11.2, Quickshell 0.3.2 do Debian, Sway 1.12 e kernel instalado 7.2.15 (rein?cio pendente).

A sombra original `RectangularShadow` foi restaurada. O tema 2SSk passou em `sway --validate`; o servi?o do painel foi reiniciado e registrou `Configuration Loaded`. O log ainda informa falha de conex?o com PipeWire na sess?o em uso; n?o houve valida??o interativa de ?udio.

Plasma e LXQt foram removidos. SDDM permanece habilitado/ativo e `/usr/share/wayland-sessions/sway.desktop` ? a ?nica sess?o gr?fica instalada. O agente de autoriza??o alternativo foi trocado para mate-polkit, sem instalar a sess?o MATE. O lan?ador de software para VMware foi preservado.

Os instaladores aceitam Trixie ou Sid, usam o Quickshell oficial no Sid e aplicam a sombra alternativa somente no Qt anterior ao 6.9. Altera??es de scripts receberam checagem de sintaxe; o instalador completo n?o foi reaplicado sobre a sess?o em uso.

Ap?s o reboot no kernel 7.2.15, o driver Xorg vmware caiu antes do greeter. Foi aplicado `compat/20-vmware-modesetting.conf`, e apenas o SDDM foi reiniciado. O Xorg permaneceu ativo e o log registrou `Greeter session started successfully`, com o processo `sddm-greeter-qt6` executando o tema berserk. Sem inspe??o visual.

Os temas base Tela-circle-blue e Tela-circle-blue-dark foram copiados do berserk para a VM e adicionados ao repo, com checksum. A consulta GTK ao tema 2SSk-nord-dark resolveu folder, text-x-python, application-x-shellscript e application-x-compressed-tar; os tr?s ?ltimos vieram do Tela. Os caches foram atualizados e o tema ativo foi preservado. XScreenSaver, xscreensaver-data e xscreensaver-gl foram removidos ap?s simula??o que afetava apenas esses tr?s pacotes; a pasta de atalhos screensavers deixou de existir. Sem inspe??o visual.

Debloat aplicado e verificado por dpkg para os dez pacotes-alvo. O APT removeu tamb?m depend?ncias relacionadas ao KWallet/KIO, sem atingir SDDM, Sway ou os aplicativos apenas ocultos. Os oito overrides locais foram conferidos com NoDisplay=true, e os respectivos programas continuam instalados. GNOME Control Center foi preservado. Sintaxe dos scripts e JSON conferida; sem inspe??o visual.

Por solicita??o posterior, GNOME Control Center foi removido e adicionado ? lista de debloat. O APT tamb?m removeu GNOME Shell, GDM3 e gnome-browser-connector como depend?ncias. O atalho org.gnome.Settings.desktop deixou de existir; SDDM permaneceu ativo e como display-manager padr?o.

Idioma: a tradu??o pt-BR do Nautilus j? estava instalada. A sobrescrita LANG=C.UTF-8 foi removida do lan?ador 2SSk e LANG/LANGUAGE passaram a ser importados na inicializa??o da sess?o. O painel foi reiniciado, e os novos processos de Nautilus e Quickshell foram conferidos com LANG=pt_BR.UTF-8 e LANGUAGE=pt_BR:pt:en. As duas altera??es de shell passaram por bash -n; sem inspe??o visual.

Waybar ap?s relogin: o portal GTK havia falhado ao tentar usar o display da sess?o anterior, e a barra terminava por timeout na consulta de apar?ncia. Foram adicionados drop-ins para vincular os portais GTK/principal ? sess?o Sway; o GTK foi fixado em Wayland e a inicializa??o dos portais passou a preceder os pain?is. Sintaxe verificada. A consulta D-Bus de color-scheme respondeu dentro do limite de 5 s; os portais e Waybar ficaram ativos, e o log confirmou Bar configured no output Virtual-1. A sess?o do usu?rio foi mantida; o pr?ximo relogin ainda n?o foi testado.


DarkShadow portado do berserk e ativado no Debian Sid: veja [DARKSHADOW.md](DARKSHADOW.md) para adaptacoes, atalhos e validacao.
