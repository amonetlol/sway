# Fedora + Sway

Instaladores na raiz, no mesmo padrao de nixos, void e debian. As configuracoes
do rice ficam somente em sway-full, compartilhadas entre as distribuicoes.

## Instalacao

Execute como usuario comum, com sudo, a partir da raiz do repositorio:

    bash fedora/install.sh

Ou, com git instalado:

    bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/fedora/install.sh)

## Ordem

1. install-pacotes.sh: pacotes DNF, locale pt-BR, teclado ABNT2 e fuso de Sao Paulo.
   Tambem chama install-cli.sh para instalar as ferramentas pessoais.
2. install-grub.sh: atualiza /boot/grub2/grub.cfg e preserva a entrada EFI existente.
3. install-sddm.sh: configura SDDM com Catppuccin Frappe Blue e a sessao Sway.
4. install-modules.sh: baixa os modulos atuais de amonetlol/sh e os executa.
5. install-sway.sh: aplica as configuracoes compartilhadas de sway-full, incluindo
   os temas GTK, icones e cursor.
6. install-services.sh: habilita SDDM e os servicos systemd do usuario.

install-themes.sh permite reaplicar somente Colloid, Papirus e Vimix, sem
reinstalar o restante do rice.

## Modulos

Bash, bin, btop, fastfetch, fonts, starship, Neovim, VMware, random-wallpapers,
hide-shortcuts, recovery-shortcuts, Kitty, wallpapers e sublime-text.
Nao ha copia congelada: cada execucao baixa novamente os modulos do GitHub.
O seletor inicia com todos marcados; --all confirma todos sem abrir o menu.

## Ferramentas CLI

install-cli.sh instala as ferramentas e executa o modulo atual pacotes_fedora.sh,
adaptando os nomes RPM antigos para os usados no Fedora. Pipenv fica em um
ambiente virtual do usuario, sem alterar o Python do sistema.

Para executar somente essa etapa:

    bash fedora/install-cli.sh

## Configuracoes compartilhadas

Mudancas em sway-full sao usadas na proxima instalacao. Esta pasta nao mantem
copias proprias de dotfiles, temas, fontes ou modulos upstream.
Os temas sao aplicados uma unica vez pelo fluxo principal.

O instalador nao reinicia a maquina nem encerra a sessao atual.
Ao terminar, entre na sessao Sway no SDDM.
