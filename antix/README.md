# antiX + Sway

Instaladores na raiz, no mesmo padrão do Kali. As configurações do rice ficam somente em sway-full.

O destino é antiX 26, x86_64 com UEFI e init 66. O GRUB EFI existente é preservado: o instalador só atualiza o menu e não executa `grub-install`.

## Instalação

Como usuário comum, com sudo, por TTY ou SSH:

    bash antix/install.sh

Se o sudo pedir senha em uma sessão sem terminal, exporte `INSTALL_SUDO_PASSWORD` só para essa execução. O instalador grava `/etc/sudoers.d/antix-pio` com NOPASSWD para o usuário atual.

## Ordem

1. install-pacotes.sh: pacotes APT, Neovim, Kitty, elogind, locale pt-BR e awww. A rede continua no connman.
2. install-grub.sh: confere a entrada EFI e roda `update-grub`.
3. install-sddm.sh: tema Catppuccin Frappe Blue e uma única sessão chamada Sway.
4. install-debloat.sh: remove IceWM, Fluxbox, JWM, herbstluftwm e slimski somente se o plano não atingir o rice.
5. install-modules.sh: baixa os módulos atuais de amonetlol/sh e os executa.
6. install-sway.sh: aplica sway-full, o agente Polkit MATE e os comandos do wlogout.
7. install-services.sh: habilita o SDDM no 66.
8. install-verify.sh: confere comandos, módulos, wlogout e a sessão do SDDM.

## Pacotes

antiX 26 acompanha o Debian 13. Kitty e Neovim vêm do APT. Sem systemd: PipeWire, waybar e o papel de parede sobem pelo `sway-session-init`. Se `awww` não existir no APT, install-awww.sh compila a versão oficial 0.12.1.

## Módulos

Bash, bin, btop, fastfetch, fonts, starship, Neovim, VMware, random-wallpapers, hide-shortcuts, recovery-shortcuts, Kitty, wallpapers e Sublime Text.

## Resultado

- Uma entrada Sway no SDDM, isolada em `/usr/local/share/sddm/sway-sessions`.
- Em VMware, Xorg usa modesetting sem aceleração e o greeter usa renderização por software, sem `QT_QUICK_BACKEND=software`.
- Aliases em `~/.aliases-antix`, com os mesmos nomes de `~/.aliases-arch` e comandos `apt` confirmados (`-y`), porque antiX é base Debian.
- Desligar e reiniciar no wlogout usam `loginctl` quando o elogind o oferece; caso contrário, `66 poweroff` e `66 reboot`.

A sessão gráfica e a máquina não são reiniciadas automaticamente. Ao terminar, entre em Sway no SDDM.
