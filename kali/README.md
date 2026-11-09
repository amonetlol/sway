# Kali Rolling + Sway

Instaladores na raiz, no mesmo padrão do Debian. As configurações do rice ficam somente em sway-full.

O destino é Kali Rolling, x86_64 com UEFI. O GRUB EFI do Kali é preservado: o instalador só atualiza o menu e não executa `grub-install`.

## Instalação

Como usuário comum, com sudo, por TTY ou SSH:

    bash kali/install.sh

Se o sudo pedir senha em uma sessão sem terminal, exporte `INSTALL_SUDO_PASSWORD` só para essa execução. O instalador grava `/etc/sudoers.d/kali-pio` com NOPASSWD para o usuário atual, para a sessão SSH não ficar parada no prompt.

## Ordem

1. install-pacotes.sh: pacotes APT, Neovim, Kitty, locale pt-BR e awww.
2. install-grub.sh: confere a entrada EFI `kali` e roda `update-grub`.
3. install-sddm.sh: tema Catppuccin Frappe Blue e uma única sessão chamada Sway.
4. install-debloat.sh: remove GNOME, GDM, Firefox ESR e foot somente se estiverem instalados e se o plano não atingir o rice.
5. install-modules.sh: baixa os módulos atuais de amonetlol/sh e os executa.
6. install-sway.sh: aplica sway-full e o agente Polkit MATE.
7. install-services.sh: habilita SDDM e os serviços systemd do usuário.
8. install-verify.sh: confere comandos, módulos, wlogout e a sessão do SDDM.

## Pacotes

Kali Rolling acompanha o Debian testing. Kitty e Neovim vêm do APT. O navegador do repositório é o Firefox ESR; o comando `firefox` aponta para ele. `swayosd` não está no repositório; o Sway sobe sem o OSD de volume. Se `awww` não existir no APT, install-awww.sh compila a versão oficial 0.12.1.

Numa instalação mínima, a rede permanece no ifupdown. NetworkManager é instalado com `eth0` não gerenciado, para não derrubar o SSH.

O shell do usuário passa a ser o bash, porque os aliases e o Starship vêm do módulo bash.

## Módulos

Bash, bin, btop, fastfetch, fonts, starship, Neovim, VMware, random-wallpapers, hide-shortcuts, recovery-shortcuts, Kitty, wallpapers e Sublime Text.

## Resultado

- Uma entrada Sway no SDDM, isolada em `/usr/local/share/sddm/sway-sessions`.
- Em VMware, Xorg usa modesetting sem aceleração e o greeter usa renderização por software.
- Aliases em `~/.aliases-kali`, com os mesmos nomes de `~/.aliases-arch` e comandos `apt` confirmados (`-y`), porque Kali é base Debian.

A sessão gráfica e a máquina não são reiniciadas automaticamente. Ao terminar, entre em Sway no SDDM.
