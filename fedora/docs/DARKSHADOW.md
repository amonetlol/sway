# Referencia do port original Debian

Este documento foi preservado como referencia de implementacao. Registros de testes abaixo pertencem ao Debian; consulte VALIDACAO.md para o Fedora.

# DarkShadow no Sway

Portado da pasta `~/.config/hypr/themes/DarkShadow` do berserk em 05/11/2026.
Original: https://github.com/shadowww-dev/DarkShadowShell (MIT), commit `48ea78c134e26e93d5b20e217642d3da37e3cd76`.
Licenca original preservada na pasta do tema.

Instalacao: os tres instaladores existentes incluem o tema. `install-pacotes.sh` instala cava/gammastep e compila Matugen 4.2.0 do codigo-fonte oficial (GPL-2.0). `install-sway_configs.sh` instala os QML, helpers, GTK Colloid e icones. As configs pessoais continuam no instalador separado.

Requer Qt >= 6.9; validado no Debian Sid desta VM, Qt 6.11.2 / Quickshell 0.3.2 / Sway 1.12. A instalacao usa DarkShadow por padrao em Qt >= 6.9 e conserva 2SSk no Qt antigo.

Nome no seletor: **DarkShadow**. `Super+Shift+T` seleciona o tema; `Super+H` abre configuracoes; `Super+D` ou `Super+Espaco` abre o launcher; `Super+F10` abre wallpapers; `Super+X` abre energia. `Super+Return` conserva Kitty.

Adaptacoes: IPC de workspaces/janelas/monitores/teclado via swaymsg; configuracoes persistidas em `config/rice/sway.json` e geradas em `config/sway/settings.conf`; bloqueio nativo Quickshell/PAM com fallback Swaylock; inatividade via Swayidle; night light via Gammastep; polkit externo. Fonte Google Sans Flex, cursor Bibata-Modern-Ice, GTK/icones DarkShadowColloid preservados. Wallpapers usam o backend do Sway, com troca automatica a cada 90 segundos. Esse backend nao reproduz as transicoes animadas do awww.

Sway padrao nao tem blur, arredondamento, sombras nem animacoes de janelas: os controles correspondentes foram retirados. As sombras/animacoes dos componentes do proprio shell permanecem. A opacidade aplica-se as janelas abertas ao alterar o controle. O atualizador original Hyprland foi desativado para conservar esta adaptacao: atualize pelo repositorio Sway.

Validacao: Python AST, shell syntax, theme_manager --check DarkShadow, leitura IPC de workspaces/monitores/teclado e registro Quickshell â€œConfiguration Loadedâ€; servicos Quickshell/polkit ativos. Nao houve validacao visual nem teste de bloquear/desbloquear, alterar resolucao ou reiniciar a sessao.
Backup inicial na VM: `/var/backups/codex-debian/darkshadow-20261105-151136`.
