# Debian Sid + Sway

Instaladores na raiz, no mesmo padrao de nixos e void. As configuracoes do rice
ficam somente em sway-full, compartilhadas entre as distribuicoes.

O destino e Debian Sid, x86_64 com UEFI. O instalador nao migra uma instalacao
stable para Sid automaticamente.

## Instalacao

Como usuario comum, com sudo, por TTY ou SSH:

    bash debian/install.sh

Ou, com git instalado:

    bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/debian/install.sh)

## Ordem

1. install-pacotes.sh: pacotes APT, ferramentas CLI, dependencias do Neovim,
   nomes de comandos dos aliases, locale pt-BR e awww.
2. install-grub.sh: preserva o GRUB EFI Debian existente e atualiza o menu.
3. install-sddm.sh: tema Catppuccin Frappe Blue e uma unica sessao chamada Sway.
4. install-debloat.sh: remove o desktop GNOME, GDM, Firefox ESR, foot,
   controle parental e im-config, preservando Nautilus, chaveiro, IBus e GTK.
5. install-modules.sh: baixa os modulos atuais de amonetlol/sh e os executa.
6. install-sway.sh: aplica sway-full, adapta o agente Polkit e oculta atalhos.
   Os temas GTK sao aplicados nesta etapa, sem repetir a instalacao.
7. install-services.sh: habilita SDDM e servicos systemd do usuario.

install-session.sh mantem o barramento do usuario disponivel durante o fluxo
por SSH e restaura o estado anterior de linger ao terminar.
install-themes.sh permite reaplicar apenas os temas GTK, icones e cursor.

## Fixes v3

fixes-v3.sh instala as dependências do term-hub, cria as pastas padrão em pt-BR
e atualiza o term-hub. O GRUB com o tema bsol fica em install-grub.sh, que usa a
cópia `sway/bsol` e não altera a EFI quando ela já existe:

    bash debian/fixes-v3.sh

## Modulos

Bash, bin, btop, fastfetch, fonts, starship, Neovim, VMware, random-wallpapers,
hide-shortcuts, recovery-shortcuts, Kitty, wallpapers e Sublime Text.
Todos sao baixados novamente em cada execucao. Sem argumentos, o seletor
comeca com todos marcados; --all confirma todos sem o menu.

install-sublime.sh adapta o modulo ao Flatpak com.sublimehq.SublimeText e aplica
as preferencias na pasta do sandbox: Catppuccin Frappe, Adaptive e CodeNewRoman.
LocalizedMenu configura os menus em pt-BR; a traducao e parcial e comunitaria.
Preferencias existentes sao preservadas em backup. Reabra o editor apos instalar.

## Resultado

- Firefox regular e idioma pt-BR em DEB, pelo APT do Sid.
- Pacotes sem recomendacoes automaticas que tragam outro desktop.
- Remocao do GNOME com o solver interno do APT, sem substituir por Cinnamon
  e sem executar autoremove geral.
- SDDM registrado como padrao antes de remover GDM.
- Em VMware, Xorg usa modesetting sem aceleracao e o greeter usa renderizacao
  por software, conforme a correcao aplicada na VM Sid.
- Se awww nao existir no APT, install-awww.sh compila a versao oficial 0.12.1
  e configura o daemon de /usr/local/bin.
- ImageMagick e preferencias do IBus ocultos no menu.
- Agente Polkit MATE independente do desktop GNOME.

Os instaladores usam diretorios temporarios fora da home. Backups de preferencias
ficam em ~/.local/state/sway-full/backups; configuracoes anteriores do SDDM
ficam em /var/backups/sway-debian-sddm-*.
A sessao grafica e a maquina nao sao reiniciadas automaticamente. Ao terminar,
entre em Sway no SDDM; atualizacoes de kernel ou driver podem exigir reinicializacao.
