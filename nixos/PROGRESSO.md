# Instalação NixOS (ONE)

Status: fixes v3 aplicados e testados na máquina; fonte, launcher e GRUB verificados após o switch.

- Sistema: NixOS 26.05 (`one-nixos`), mesma revisão nixpkgs `ac588ef1c914` que gerou o sistema anterior. O canal `nixos` aponta para essa revisão; `nix-channel --update` não foi executado.
- Build e switch da configuração: `nixos-rebuild switch` concluiu com código 0. Entrou `nerd-fonts.code-new-roman`; sai resíduo de perl; kernel inalterado.
- Fonte: `nerd-fonts.code-new-roman` instalada; a Waybar e os demais apps já referenciam `CodeNewRoman Nerd Font`.
- GRUB: tema bsol testado e revertido a pedido do usuário (o menu ficou sem a entrada de snapshots visível). Usa o tema padrão do NixOS. O submenu `NixOS Snapshots` continua no `grub.cfg` via `grub-btrfs.cfg`.
- EFI: `NixOS-boot-efi/grubx64.efi` e `aarambh/aarambh.efi` com o mesmo SHA-256 antes e depois do switch. `canTouchEfiVariables = false` mantido.
- Waybar: módulo `custom/date` (`waybar-date`) já presente e funcionando; configuração idêntica à do `sway-full`.
- term-hub: atualizado com o instalador atual (`hub.py` com SHA-256 `9db8773f…`, igual ao upstream). `ssh.conf` preservado (600). Sessões `ff` e `ffd` criadas; log do distro em `/tmp/ff-NixOS.log`.
- Launcher: ocultados os itens instalados da seção 1 (rofi, rofi-theme-selector, btop, vim, nvim, htop); Files renomeado para Nautilus (seção 4).
- Snapper: 4 snapshots (NUMBER_LIMIT 4), sem timeline.
- Repo: `nixos/configuration.nix` sincronizado com a máquina (sem `one-multiboot.nix`, que é específico desta máquina), `nixos/fixes-v3.sh` e este arquivo.
- Pendências: itens visíveis no launcher fora das regras vão para o `0-ask-remove_or_hide_or_untouched.txt`, ainda não gerado para esta máquina. Remoções da seção 2 não foram feitas.
- Inkscape removido (pedido do usuário; dry-run mostrou só ele e dependências exclusivas). Pastas padrão em pt-BR criadas e ~/.config/user-dirs.dirs gravado.
