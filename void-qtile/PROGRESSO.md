# Instalação Void + Qtile (ONE)

Status: fixes v3 aplicados na máquina.

- Sistema: Void (runit), sessão SDDM com Qtile (`/usr/share/xsessions/qtile.desktop`).
- term-hub: já estava atualizado (`hub.py` com SHA-256 `9db8773f…`, igual ao upstream). Reinstalado pelo `fixes-v3.sh`; `ssh.conf` preservado (600). Sessões `ff` e `ffd` criadas; log do distro em `/tmp/ff-Void.log`.
- GRUB: tema bsol aplicado com `install-grub.sh` (`GRUB_THEME=/boot/grub/themes/bsol/theme.txt`, `grub-mkconfig`). `EFI/Void/grubx64.efi` com o mesmo SHA-256 de antes.
- UEFI: o primeiro run do script usou `grub-install` sem `--no-nvram` e colocou a entrada `void` na frente da BootOrder. Restaurado: `BootOrder` com Aarambh (`0006`) primeiro. Corrigido no script (`sudo test -f` e `--no-nvram`).
- Launcher: ocultados os itens instalados da seção 1 (btop, micro, nvim, rofi, rofi-theme-selector). Files renomeado para Nautilus.
- Teclado: `/etc/X11/xorg.conf.d/00-keyboard.conf` com `br` / `abnt2` / `pc105`; SDDM reiniciado e layout confirmado no log do X.
- Pendências: no boot, o kernel às vezes não habilita o teclado PS/2 (`atkbd: Failed to enable keyboard`). Foi religado manualmente (unbind/bind do `serio0`); não é permanente. Entrada `nautilus-autorun-software` visível no launcher, fora das regras (ASK).
## Atalhos e polimento (Qtile, referência endeavouros-niri)

- Binds do niri adaptados ao Qtile: \Super+F1\ guia de atalhos (\show-hotkeys\), \Super+M\ alterna resolução (\mon --qtile\, via xrandr), \Super+V\ clipboard (clipmenu com rofi, \clipmenud\ no autostart), \Super+F\ tela cheia, \Super+T\ flutuante, \Super+Shift+P\ desliga monitores, \Super+Alt+T\ btop, volume com pactl.
- \Super+X\: menu de energia com ícones e texto (\ofi-power\).
- \Super+F10\: seletor de wallpapers com bordas retas (\order-radius: 0px\ em \~/.config/rofi-wallpaper\).
- Polybar: clique direito no volume abre pavucontrol; clique em CPU e memória abre \kitty -e btop\.
- Instalados: duf, clipmenu, xset, nodejs, luarocks, tree-sitter-cli, ripgrep, fd; nvim com \monetlol/nvim\ em \~/.config/nvim\.
- Não portado: \Super+Shift+L\ (lock), que conflita com \shuffle_right\ do Qtile, e captura de tela (sem ferramenta instalada).
