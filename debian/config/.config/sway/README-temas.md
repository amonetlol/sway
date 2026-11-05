# Temas Sway

Tema inicial: `theme-gruvbox`, adaptado do Heart Rice, com duas barras Waybar, Rofi, SwayNC, Swaylock manual, GTK e icones Gruvbox Material. Corações substituidos por dots. Bateria, brilho, sensores especificos de notebook e ferramentas pessoais do autor foram removidos.

## Organizacao

```
~/.config/sway/
  config
  settings_default.conf
  binds_default.conf
  local.conf
  theme-generated.conf
  current -> themes/theme-gruvbox
  scripts/
  themes/
    theme-gruvbox/
      sway.conf
      binds.conf
      theme.conf
      waybar/
      rofi/
      swaync/
      swaylock/
      gtk/
```

O config carrega comportamento comum, atalhos comuns, aparencia do tema, extras do tema, cursor gerado e preferencias pessoais. `local.conf` e carregado por ultimo. Os scripts de sessao iniciam somente no login; mudar o tema nao cria instancias duplicadas.

Nenhum link global de Waybar ou Rofi do Hyprland foi alterado. Os programas do Sway recebem caminhos explicitos em `~/.config/sway/current/`.

## Selecionar e adicionar temas

Super+Shift+T abre o seletor de temas Sway. Pelo terminal:

```
~/.config/sway/scripts/set_theme.sh --list
~/.config/sway/scripts/set_theme.sh --check theme-gruvbox
~/.config/sway/scripts/set_theme.sh theme-gruvbox
```

Para adicionar outro tema:

```
cp -a ~/.config/sway/themes/theme-gruvbox ~/.config/sway/themes/meu-tema
```

Edite a copia, mantendo os arquivos obrigatorios. Atualize theme.conf com os nomes reais dos recursos GTK/icones/cursor instalados. Use nomes de diretorios com letras, numeros, hifen ou sublinhado. A lista exibe apenas temas completos. Escape cancela o seletor.

A troca valida a configuracao Sway e JSON, troca o link current, aplica GTK/cursor e recarrega os servicos exclusivos desta sessao. Se falhar, restaura o tema e as preferencias anteriores. Fora da sessao Sway, uma selecao pelo terminal apenas salva o tema para o proximo login.

O campo COMPOSITOR identifica sway/swayfx para organizacao futura. Este perfil utiliza apenas recursos do Sway convencional. SwayFX e seus efeitos ainda nao foram instalados nem habilitados; essa compatibilidade deve ser tratada ao adicionar esses temas.

## Aplicativos e atalhos

- Super+Return: Kitty, preservando o wrapper e as preferencias existentes.
- Super+W: Firefox.
- Super+E: Nautilus, preservando o wrapper da VM.
- Super+D ou Super+Space: Rofi.
- Super+X: menu de energia independente do Sway.
- Super+M: alterna 1920x1080 / 1600x900 na saida em foco.
- Super+H: editar config e binds_default.conf.
- Super+.: editar pasta Sway.
- Super+F1 ou Super+/: guia de atalhos.
- Super+V: historico do clipboard.
- Super+Ctrl+P: capturas.
- Super+Shift+T: trocar tema Sway.
- Super+Ctrl+Shift+L: bloqueio manual. Super+Shift+L continua movendo a janela para a direita.

Os atalhos de foco, mover janelas, workspaces e audio mantem as mesmas teclas quando ha equivalente nativo. Particularidades: Super+F e Super+Shift+F usam fullscreen; Super+; alterna split horizontal, split vertical, tabs e stacking. Super+J alterna a divisao; Super+Backspace redimensiona para 50%. Nao ha pseudotile ou layout Scrolling do Hyprland no Sway convencional. Super+S usa o scratchpad.

## Sessao, portais e wallpaper

`sway-themed-session.target` inicia a Waybar, SwayNC, historico de clipboard, observador de encerramento e portal WLR. A configuracao sway-portals.conf seleciona GTK como portal geral e WLR para Screenshot/ScreenCast.

O drop-in `~/.config/systemd/user/xdg-desktop-portal-wlr.service.d/sway-only.conf` verifica a identificacao da sessao e a existencia de um compositor Sway antes de permitir a ativacao. O backend WLR acompanha o encerramento da sessao Sway. Os outros desktops continuam usando seus portais existentes.

Ao entrar no Sway, as preferencias GTK atuais sao guardadas; ao sair, o observador restaura essas preferencias e encerra os servicos exclusivos. A selecao de tema Sway fica salva. O estado anterior a cada troca fica em `~/.local/state/sway-themes/`.

Nao ha swayidle, timer de lock, suspensao automatica nem apagamento automatico da tela. Caffeine inicia ativo na Waybar. Bloqueio e suspensao permanecem disponiveis como acoes manuais.

O wallpaper continua com o random-wallpaper.timer existente, de 90 segundos. Nao ha wallpaper por tema. O daemon awww e reutilizado pelo script existente.

## Diagnostico

- `~/.local/state/sway-themes/session.log`: inicializacao do perfil.
- `~/.local/state/sway-themes/config-errors.txt`: detalhes de eventuais erros de configuracao.
- `journalctl --user -u sway-themed-waybar.service`.
- `journalctl --user -u sway-themed-notifications.service`.

Para conferir visualmente, use a sessao Sway ja aberta ou escolha Sway na tela de login. Nenhuma sessao nova foi aberta automaticamente durante a implementacao.

## Cursor da VM

A entrada Sway da tela de login usa `/usr/local/bin/sway-vm`, que define `WLR_NO_HARDWARE_CURSORS=1` antes de iniciar o compositor. Isso evita o plano de cursor de hardware do VMware. A opcao precisa de novo login no Sway; recarregar a configuracao nao altera o renderer do processo atual. O arquivo original da entrada foi preservado em `~/.local/state/sway-themes/sway.desktop.before-vm-cursor`. Uma atualizacao do pacote Sway pode substituir a entrada desktop, exigindo reaplicar o caminho do wrapper.
