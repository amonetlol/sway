# Debian 13 / Sid + Sway

Instala o desktop copiado do berserk e adaptado para Debian 13 e Debian Sid (amd64): Sway com os temas 2SSk e Gruvbox, GTK, ícones, cursor Bibata, Kitty com Kitty Tab, Ghostty, Bash, btop, fastfetch, fontes, Neovim, SDDM com o tema do berserk e GRUB Leaf.

Os instaladores est?o separados e devem ser executados nesta ordem:

```bash
sudo bash debian/install-pacotes.sh --user "$USER"
sudo bash debian/install-sway_configs.sh --user "$USER"
sudo bash debian/install-personal_configs.sh --user "$USER"
```

- `install-pacotes.sh`: apt, sudo, depend?ncias, Firefox DEB, Ghostty e Quickshell (pacote oficial no Sid; compila??o no Trixie).
- `install-sway_configs.sh`: configs Sway, temas GTK, ?cones, cursor, servi?os da sess?o, SDDM e GRUB Leaf.
- `install-personal_configs.sh`: busca as vers?es atuais de [sh](https://github.com/amonetlol/sh), [dot](https://github.com/amonetlol/dot), [goodies](https://github.com/amonetlol/goodies), [nvim](https://github.com/amonetlol/nvim) e [wall2](https://github.com/amonetlol/wall2), aplica Bash/aliases, btop, fastfetch, fontes, Kitty/Kitty Tab, Neovim, atalhos e wallpapers, preservando as adapta??es para Debian/Sway. A configura??o Ghostty continua sendo a c?pia do berserk.

O instalador pessoal usa a branch padr?o atual de cada reposit?rio, sem commit fixo. Cada execu??o busca as altera??es novas automaticamente; n?o ? necess?rio copi?-las para este repo. Ele n?o executa sincroniza??o cont?nua em segundo plano. Para atualizar somente as configura??es do seu usu?rio, ap?s instalar as depend?ncias:

```bash
bash debian/install-personal_configs.sh
```

`install.sh` continua dispon?vel como atalho que executa as tr?s etapas na ordem acima. Em uma instala??o sem sudo, execute como root com `bash debian/install.sh --user SEU_USUARIO`.

O instalador habilita sudo para esse usuário, instala os pacotes por apt, usa o Quickshell do Debian no Sid ou compila a vers?o 0.3.2 no Trixie e instala o Ghostty 1.3.1 e o Firefox DEB oficial da Mozilla em português do Brasil. O Firefox ESR é removido, se estiver instalado. Não reinicia a máquina. O SDDM fica habilitado para o próximo boot; selecione a sessão Sway. As fontes e os wallpapers são baixados durante a instalação; reserve espaço para esses arquivos e para as dependências de compilação.

`config/` contém os arquivos de configuração, com `@@HOME@@` no lugar do diretório pessoal. `manifests/config-links.json` registra os links simbólicos e `manifests/config-modes.json` preserva as permissões dos scripts. `assets/desktop-assets.tar.gz` contém imagens, temas GTK, ícones, cursores, fontes adicionais e o tema do SDDM. `assets/grub/leaf/` contém o tema do GRUB. O script substitui os caminhos pelo HOME do usuário informado.

O wallpaper muda a cada **90 segundos**. `~/.local/bin/mon --sway` alterna 1920×1080 e 1600×900 quando o monitor aceita esses modos. O atalho Super+M usa esse script. Abrir `kitty` carrega a configuração Kitty Tab.

Os aliases mantêm os nomes originais; os comandos de pacotes usam apt. Não são instalados Btrfs Assistant, snapper, blackbox ou ulauncher. Os comandos `hide-shortcuts` e `recover-shortcuts` ajustam os atalhos locais do lançador.

Arquivos substituídos recebem backup em `~/.local/state/sway-debian/backups/`; arquivos de sistema ficam em `/var/backups/sway-debian/`. Chaves SSH, senhas, histórico, notificações e clipboard da máquina original não fazem parte deste repositório.

Fontes: [módulos](https://github.com/amonetlol/sh), [dotfiles](https://github.com/amonetlol/dot), [Kitty Tab](https://github.com/amonetlol/goodies), [wallpapers](https://github.com/amonetlol/wall2), [GRUB Leaf](https://github.com/elifouts/grubTUI), [Ghostty Debian](https://github.com/mkasberg/ghostty-ubuntu), [Quickshell](https://github.com/quickshell-mirror/quickshell). As licenças e os arquivos SOURCE dos temas foram preservados.

Em VMware, o lan?ador `sway-debian-session` usa renderiza??o por software e desativa o glamor do XWayland para evitar a falha de importa??o DMA-BUF observada nesta VM. O ajuste exige um novo login e tamb?m ? aplicado pelo instalador Sway. Em outras m?quinas, o lan?ador mant?m a renderiza??o padr?o.

O tema usa `RectangularShadow` com Qt 6.9 ou superior (incluindo o Qt do Sid). No Trixie com Qt 6.8, o instalador aplica automaticamente `compat/Shadow-qt68.qml`. A instala??o do desktop n?o muda a distribui??o para Sid por conta pr?pria.

Os pacotes do instalador n?o incluem os desktops Plasma e LXQt. O fallback de autentica??o do Sway usa apenas o agente `mate-polkit`, sem instalar a sess?o MATE. As instala??es APT evitam recomenda??es opcionais que poderiam trazer outros ambientes.

No VMware, o instalador tamb?m configura o Xorg do SDDM com `modesetting` e `AccelMethod none`, evitando a queda de `vmware_drv.so` observada ap?s a atualiza??o para Sid/kernel 7.2.

Os assets incluem `tela-circle-icons.tar.gz` com Tela-circle-blue e Tela-circle-blue-dark, depend?ncias dos oito temas 2SSk. O instalador copia os dois temas e gera seus caches. Os pacotes do instalador n?o incluem XScreenSaver nem seus m?dulos de anima??o.

### Debloat e atalhos

`install-pacotes.sh` aplica `manifests/debloat-packages.txt`: remove Thunar/volman, ajuda do GNOME, Help Center, Input Method (im-config), KDE Partition Manager, KWallet, controle parental e o painel de impress?o, quando instalados. A remo??o simula primeiro as depend?ncias e interrompe se atingir componentes protegidos.

`install-personal_configs.sh` aplica `manifests/hidden-shortcuts.json` depois dos m?dulos upstream. IBus Preferences, ImageMagick, Qt5/Qt6 Settings, Rofi, Rofi Theme Selector, Neovim e qps recebem overrides locais com `NoDisplay=true`, preservando os programas. O nome ?Settings? corresponde ao GNOME Control Center, tamb?m inclu?do na lista de remo??o.

O painel 2SSk herda o idioma da sess?o. O script de inicializa??o importa LANG/LANGUAGE para D-Bus e systemd, evitando que aplicativos abertos pelo painel recebam C.UTF-8 no lugar do idioma configurado.

Os portais GTK e principal acompanham `sway-themed-session.target`. O portal GTK usa Wayland e ? inicializado com o ambiente do novo login antes dos pain?is, evitando o timeout da Waybar ao consultar as prefer?ncias de apar?ncia ap?s relogar.


DarkShadow portado do berserk e ativado no Debian Sid: veja [DARKSHADOW.md](DARKSHADOW.md) para adaptacoes, atalhos e validacao.
