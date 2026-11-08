# Validacao Fedora

Aplicacao concluida em 2026-11-05 no Fedora 45 x86_64, VMware, usuario pio.

Verificacoes realizadas:

- Conexao SSH como pio com chave Ed25519 e BatchMode, sem senha.
- Sintaxe Bash dos instaladores, auxiliares e lancador da sessao.
- Parsing dos scripts Python e manifests JSON; existencia dos 779 arquivos do manifest de configuracao.
- Checksums dos cinco arquivos de assets conferidos pelo instalador.
- Instalacao DNF concluida, ferramentas auxiliares instaladas e tres fases aplicadas.
- Sudoers validado por visudo -c.
- Arquivos Sway e Kitty presentes; Neovim implantado para pio e root.
- Tema atual aponta para DarkShadow; wallpapers apontam para o repositorio wall2.
- Aliases Fedora carregados; fd, bat e comando GRUB2 usam caminhos Fedora.
- SDDM e Bluetooth habilitados; entrada Sway aponta para sway-fedora-session.
- GRUB2 regenerado com o tema Leaf, preservando BLS e parametros existentes.
- DNF configurado com 10 downloads paralelos e fastestmirror=False.

Backups em /var/backups/sway-fedora/ e ~/.local/state/sway-fedora/backups/. O instalador remoto esta em /home/pio/sway-setup/fedora e /opt/sway-fedora/installer.

Nao houve reinicio, inspecao visual nem teste de aplicativos na sessao grafica. O ganho de velocidade nao foi medido por benchmark. E necessario fazer novo login Sway para conferir a interface.

Os registros do port original em DARKSHADOW.md pertencem ao Debian.

## Correcao do SDDM em VMware

O primeiro boot revelou falha de importacao DMA-BUF no greeter, que encerrava a conexao Wayland. Aplicado setup-sddm.sh com wrapper pixman e Qt Quick software somente em VMware. Sintaxe dos arquivos alterados validada. Reiniciado apenas SDDM; confirmados compositor, greeter e sessao greeter em tty1 ativos apos 22 segundos, sem repeticao do erro fatal no log dessa inicializacao. Sem validacao visual.

## Correcao do matugen no Fedora

O wrapper do tema DarkShadow chamava /usr/local/bin/matugen, que nenhuma etapa do port Fedora instalava: o gerador de paleta falhava com erro 127 e a sessao mantinha a paleta salva. O tema exige a CLI 4.x (--source-color-index, --prefer, --json) e o repositorio Fedora so oferece o 3.1.0. Agora install-pacotes.sh compila o matugen 4.2.0 oficial em /usr/local/bin, o wrapper aceita fallback para o PATH com aviso quando a versao compilada nao existe, e o palette.py usa o subcomando color hex para esquemas de seed fixa, como o commands.sh ja fazia (a flag --source-color nao existe no matugen 4.x). Sintaxe Bash/Python revalidada. Sem teste em sessao grafica.

## Inicializacao da barra no Fedora

O portal Fedora exige graphical-session.target ativo. O script de sessao encerrava antes da barra porque esse alvo estava inativo. session-start.sh agora inicia sway-session.target, fornecido pelo Fedora, que ativa o alvo grafico por dependencia; session-watch.py encerra esse alvo ao sair do Sway. A tentativa de iniciar graphical-session.target diretamente foi recusada por RefuseManualStart e substituida pela ativacao via sway-session.target.

Sintaxe Bash/Python validada. Reexecutada somente a inicializacao da sessao atual: retorno zero, sway-themed-quickshell.service ativo e Configuration Loaded no log. Nenhum logout ou reinicio do compositor. Sem validacao visual. O gerador de paleta registrou erro 127 no wrapper Matugen e manteve a paleta salva; isso nao impediu a carga da barra e nao foi alterado nesta correcao.
