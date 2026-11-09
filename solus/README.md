# Solus + Sway Full

As configs ficam em `sway-full`. Execute como usuario comum com sudo:

```bash
bash solus/install.sh
```

Instala eopkg, SDDM, temas e modulos atuais de amonetlol/sh. Preserva o
clr-boot-manager; nao instala nem reconfigura outro gerenciador de partida.

Remove GNOME desktop e aplicativos GNOME, todos os pacotes LibreOffice,
Thunderbird e GParted depois de preparar a sessao Sway Full. Antes da remocao,
confere o plano do eopkg para preservar boot, rede, audio, Nautilus e keyring.
Nao reinicia a maquina automaticamente.

Adaptacoes Solus: mako-notify e o pacote do daemon de notificacoes; cliphist
0.7.0 vem do release oficial upstream para x86_64. Wallpaper usa o backend
nativo do Sway, sem transicoes do awww. Volume e microfone usam wpctl;
brilho usa light. Nao instala swayosd nem nwg-look, indisponiveis no eopkg.
As preferencias GTK sao aplicadas diretamente pelo instalador de temas.

A lista de pacotes tambem inclui os equivalentes Solus de
`amonetlol/ps/arch-pacotes.txt`: ferramentas de terminal, compilacao, Python,
Node.js/npm e aplicativos. `tldr` usa `tealdeer`, `python-pynvim` usa
`python-neovim`, e pip/pipenv/virtualenv usam os nomes nativos do eopkg.
Prettier e instalado via npm em `~/.local`, sem alterar o prefixo global.
`herdr-bin` nao tem equivalente no repositorio Solus. `snap-pac` depende do
pacman e nao se aplica ao Solus; o gerenciador de partida continua preservado.
