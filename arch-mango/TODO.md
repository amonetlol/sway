# TODO — Arch + MangoWM (ONE)

Fonte: `C:\Users\Craig\Downloads\Mult_ONE-chatGPT\0-start-v3.txt`.

## Instalação base

- [x] Subvolumes `@arch` e `@arch-home` no btrfs da ONE
- [x] Backup da EFI e do `aarambh.conf` (`/root/arch-pre-20261112-205100`)
- [x] `arch-install-scripts` no CachyOS
- [x] Conf de instalação com opções de `amonetlol/ps/pacman.conf.txt`
- [x] Concluir pacstrap (306 pacotes)
- [x] `/etc/pacman.conf` final com opções de `pacman.conf.txt` (DownloadUser = alpm)

## Sistema

- [x] fstab (UUIDs do btrfs e da ESP `CCA6-D3A1`, `/home/share` com `@shared`)
- [x] Locale pt_BR.UTF-8, timezone America/Sao_Paulo, keymap br-abnt2, hostname `arch`
- [x] Usuário pio (uid 1000, home `@arch-home`), senha 1234 e root com senha 1234
- [x] sudoers NOPASSWD (`/etc/sudoers.d/pio`, `chmod 440`, `visudo -cf` ok)
- [x] sshd habilitado no boot; NetworkManager habilitado (IP fixo 192.168.86.170)
- [x] Snapper: NUMBER_LIMIT=4, NUMBER_LIMIT_IMPORTANT=4, TIMELINE_CREATE=no, `snapper-cleanup.timer` ativo

## Boot

- [x] GRUB em `\EFI\arch` (`--bootloader-id=arch --no-nvram`) e `grub-mkconfig`
- [x] Aarambh: entrada `Arch Linux` em `aarambh.conf`
- [x] `BootOrder` continua com Aarambh (0006) primeiro
- [x] Hook do Aarambh regravou `aarambh.efi`; original restaurado (`19b3079…`)
- [x] Teste de boot do Arch pelo Aarambh (seleção manual). Default segue `cachyos`
- [ ] Decidir se o Arch vira default do Aarambh (pergunta ao usuário)

## Desktop

- [x] `yay` (AUR) e `mangowm-git`
- [x] Dependências e apps (ver PROGRESSO.md)
- [x] Configs mango de `hakuspace` com binds de `endeavouros-niri`
- [x] SDDM tema catppuccin-frappe-blue
- [x] Lista de módulos do sway-full para o usuário escolher (instalados, exceto `random-wallpapers` e `wlogout`)
- [x] Rofi com temas (padrão `line`, ícones ligados)
- [ ] Rofi: wallpaper real para `tablet`/`television` (hoje placeholder)
- [x] Waybar: tema `tokyo` no topo (`position: top`, `margin-top: 6`), aplicado no ONE e no staging
- [x] Waybar: relógio do `tokyo` sempre visível (`#clock` com cor de acento e fundo escuro; antes sumia fora do hover). Aplicado no ONE e no staging
- [x] Waybar: relógio do `tokyo` voltou ao original (sem override de `#clock`)
- [x] Waybar: `tokyo-2` criado (cópia de `tokyo` com fundos dos módulos em `rgba(0,0,0,0.7)`, igual ao rofi). Aplicado no ONE e no staging
- [x] Ícones: rofi com `icon-theme: "McMuse-circle"` e GTK (`gtk-3.0`/`gtk-4.0` settings.ini) com `McMuse-circle`. Aplicado no ONE e no staging. O waybar só usa o tema de ícones na bandeja (tray); os ícones dos módulos são glifos de fonte
- [x] Super+F: mostra os atalhos do mango (`show-hotkeys`, lê `bind.conf`). `togglemaximizescreen` foi para `Super+Alt+F`
- [x] Super+M: chama `mon` (troca 1920x1080 / 1600x900 via `wlr-randr`). Não testado (mexe na resolução). `btop` foi para `Super+Alt+M`
- [x] Super+F10: seletor de wallpapers (`rofi-wallpaper` do sway-full)
- [x] Bordas: `focus_color`/`border_color`/`urgent_color` em `theme/mangowm-style.conf` (acento e `#626880`)
- [x] Fonte padrão: `CodeNewRoman Nerd Font 11` (GTK, gsettings, `fonts.css` do waybar). Rofi e mango ainda usam fonte própria (verificar)
- [x] GTK: tema `Tokyonight-Dark-Storm` (gtk-3.0 e gtk-4.0 `settings.ini` e gsettings), ícones `MacTahoe-dark`, `color-scheme prefer-dark`. Antes era `Colloid-Dark-Catppuccin`. Nautilus/GTK: tema `Colloid-Dark-Catppuccin`, ícones `McMuse-circle`, `color-scheme prefer-dark`. Nautilus (GTK4/libadwaita) pode ignorar o tema GTK; testar
- [x] Módulos: `btop` e `duf` instalados. `wlogout` continua ausente (pulado antes)
- [x] Teclado: `xkb_rules_layout=br` + `xkb_rules_variant=abnt2` no mango (confirmado: "Portuguese (Brazil)"). `localectl` X11 = br/pc105/abnt2 (LightDM)
- [x] Binds: `bind.conf` adaptado do `endeavouros-niri/niri/binds.kdl` (85 binds). Novos: F1, Alt+F10, Super+C, Super+J/K, Super+U/I, Super+Ctrl+setas/U/I (tags), Super+Alt+T, Super+Shift+D, Alt+M. Não migrados: colunas/larguras (Mod+Minus/Equal, Mod+Shift+R), Mod+Shift+P, Mod+Escape, Mod+Shift+L (swaylock não instalado), Alt+Print (screenshot sem modo janela)
- [x] Super+;: `mango-layout-menu.sh` (rofi com os layouts do `mmsg get layouts` e `setlayout`). Testado
- [x] Ícones do sistema (GTK e gsettings): `MacTahoe-dark`. Rofi segue `McMuse-circle`
- [x] Tokyonight GTK (Fausto-Korpsvart) instalado em `/home/share/.themes` (via `~/.themes`): `Tokyonight-{Dark,Light}` + `-Moon` + `-Storm` (legacy buttons, borderless) e `Tokyonight-Macos-{Dark,Light}` + `-Moon` + `-Storm` (macOS buttons). Não aplicado no GTK ainda (escolha pendente). `gtk-engine-murrine` é AUR e não foi instalado
- [ ] Waybar: validar troca de tema pelo `Super+Shift+T`
- [ ] Waybar: `taskbar` referencia `hakucfg` inexistente
- [x] Mouse: ponteiro OK com o tema `Vimix-cursors` (confirmado pelo usuário). `env.conf` com `XCURSOR_THEME`/`XCURSOR_SIZE` no ONE e no staging
- [x] Sessão: mango não abria (`Could not connect to remote display`), removido `DISPLAY`/`WAYLAND_DISPLAY` do `env.conf`
- [ ] Logoff: tela preta porque o SDDM não reabre o greeter depois do quit do mango. Decisão: LightDM temporário para configurar (sddm desativado)
- [ ] LightDM: confirmar login na sessão mango (greeter, sessão `mango`)
- [ ] Tema do greeter: voltar ao catppuccin-frappe-blue (SDDM) ou configurar LightDM com o mesmo tema
- [x] Wallpaper da sessão: `random-wallpaper` instalado e ativo (timer 5 min, autostart no mango)
- [x] Wallpaper do login: fundo do tema catppuccin no greeter do LightDM (vale no próximo login)
- [ ] Confirmar wallpaper no login e na sessão
- [ ] Decidir DM final (SDDM com correção de logoff, LightDM ou greetd)
- [ ] Staging `F:\GitHub\sway\arch-mango\configs\home` sincronizado com as mudanças de ONE (`line.rasi`, `env.conf`)

## Depois do primeiro boot

- [x] term-hub instalado (`term-hub instalado`), `ff` e `ffd`, logs `/tmp/ff-Arch.log`. Instalado de `amonetlol/sh` (`modules/hub-ssh_term.sh`) em `~/.local/bin/term-hub` e `ssh-hub`; `ff` (install, scripts, downloads) e `ffd` (Arch). `ssh.conf` do term-hub está vazio: preencher alias/host/usuário quando for usar. `PATH` com `~/.local/bin` já existe no `~/.bashrc`
- [ ] Limpar `/mnt/arch` e `/mnt/btrfs-top` (umount)
- [ ] Commit no repo (só se o usuário pedir)
