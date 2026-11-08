# Sway no NixOS — rolling

Replica o rice da VM NixOS: Sway, SDDM com Catppuccin Frappe Blue, GRUB,
tema GTK Colloid, Papirus Frappe Blue, cursor Vimix e os módulos do GitHub.

O NixOS precisa já estar instalado, com `/etc/nixos/hardware-configuration.nix`.
O usuário do template é `pio`. O `stateVersion` já existente é preservado.
Se o canal não for o rolling, o instalador troca para `nixos-unstable`.

## Ordem

Como usuário comum, com `sudo`:

```bash
bash install.sh
```

Direto do GitHub, sem cópia local:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/nixos/install.sh)
```

Isso executa, nesta ordem:

1. `install-system.sh` — `configuration.nix`, canal rolling e `nixos-rebuild switch`
2. `install-modules.sh` — baixa os módulos atuais de `amonetlol/sh` e roda
3. `install-sway.sh` — copia o `sway-full` e adapta os caminhos do NixOS
4. `install-themes.sh` — Colloid, Papirus, Vimix e o `gsettings`
5. `install-aarambh.sh` — menu EFI Picker Wheel com o logo NixOS

Não há cópia congelada dos módulos. Cada execução baixa de novo:

`https://raw.githubusercontent.com/amonetlol/sh/main/modules/`

Atualizar um módulo nesse repositório atualiza o rice na próxima instalação.
`install-modules.sh --all` instala todos sem o menu. Sem `--all`, a lista começa
inteira marcada.

## Módulos

bash, bin, btop, fastfetch, fonts, starship, nvim, vmware, random-wallpapers,
hide-shortcuts, recovery-shortcuts, kitty, wallpapers e sublime-text.

O Snapper (6 snapshots, sem timeline) fica no `configuration.nix`, não no
script de Snapper do Arch. O `hide-shortcuts` aponta os `.desktop` do NixOS
em `/run/current-system/sw/share/applications`.

`sublime-text.sh` instala o Sublime Text 4 no Arch pelo repositório oficial.
No NixOS o pacote é `sublime4`; o mesmo módulo aplica Catppuccin Frappe e a
fonte CodeNewRoman.

## O que o sistema fica

- Idioma `pt_BR.UTF-8`, teclado ABNT2, fuso `America/Sao_Paulo`
- SDDM em X11, tema `catppuccin-frappe-blue`, uma sessão chamada `sway`
- Sem Foot e sem Xterm
- Cursor de software (`WLR_NO_HARDWARE_CURSORS` e `SWcursor`); o driver `vmware` do X não é usado
- Clipboard com `cliphist`
- Sair do wlogout encerra o Sway e devolve o SDDM
- No VMware o `awww` não reinicia em loop; o fundo usa uma imagem de `~/Imagens/wallpapers` com `swaybg`

Entre em **sway** no SDDM depois da instalação. O instalador não reinicia a máquina.
