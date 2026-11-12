# Slackware64-current

Rice de `sway-full`, com instaladores proprios para Slackware e servicos SysV/elogind.
Executar como usuario comum com sudo:

```sh
bash slackware/install.sh
```

Cada etapa tambem pode ser executada isoladamente. Para retomar de uma falha:

```sh
bash slackware/install.sh modules
```

Etapas: `pacotes`, `modules`, `sway`, `sddm`, `services`, `themes`, `debloat`, `verify`.
Fontes e pacotes gerados ficam em `~/.cache/sway-slackware`; logs, inventario de
modulos e verificacao em `~/.local/state/sway-slackware`. Configuracoes anteriores
sao copiadas para `backups` antes de serem alteradas.

- Foot e micro substituem Kitty e Neovim. Atalhos/comandos do rice sao adaptados.
- Swaybg aplica os wallpapers a cada 90 segundos e pelo seletor Rofi, sem compilar awww.
- Waybar preserva o rice; rede `eth0`, audio via PipeWire e modulos Sway/custom.
- Volume usa pactl. Swayosd e atalhos de brilho/CapsLock sao omitidos nesta VM.
- Thunar substitui Nautilus, evitando instalar o desktop GNOME.
- Componentes ausentes sao compilados com 2 jobs e registrados como pacotes pkgtools.
- Micro, fastfetch, cliphist, starship e Sublime usam binarios oficiais prontos.
- fd e fzf/fzf-tmux tambem usam binarios oficiais, para os atalhos de busca do shell.
- duf usa binario oficial pronto. `slackpkg-size` mostra o volume de atualizacoes
  dos pacotes instalados pelo indice local, sem instala-las nem oferecer novos apps.
- Modulos upstream: bash, bin, btop, fastfetch, fonts, starship, foot, wallpapers,
  sublime-text, hide-shortcuts e recovery-shortcuts. VMware usa SlackBuild proprio;
  random-wallpapers usa a sessao Sway, sem systemd.
- Nao instala suporte futuro de Neovim/LSP, Snapper, snap-pac ou grub-btrfs.
- Mantem GRUB/UEFI existente; SDDM inicia no runlevel 4 e SSH permanece no boot.
- Mantem DHCP existente. NetworkManager nao disputa `eth0` com o cliente DHCP ativo.
- Debloat remove aplicativos opcionais selecionados e a pilha adicional de impressao;
  preserva as bibliotecas CUPS, VTE, Vulkan, Zint e GTK. Atalhos de desenvolvimento,
  metodos de entrada e preferencias secundarias ficam ocultos. Os pacotes removidos
  sao incluidos na blacklist do slackpkg para nao retornarem pelo install-new.
- Wlogout: swaylock, swaymsg exit, loginctl poweroff/reboot. A verificacao confere
  executaveis e a interface do elogind sem executar desligamento, reinicio ou logout.

Depois da instalacao, selecione **Sway** no SDDM. As entradas labwc e Xsession
default sao movidas para `/var/lib/sway-slackware/disabled-sessions`.
A validacao e por sintaxe,
dependencias e comandos; a aparencia final deve ser conferida pelo usuario.
