# Arch + MangoWM (ONE, multiboot)

Status: Arch instalado e entrando pelo Aarambh. Login pelo SDDM com tema catppuccin-frappe-blue. Ajustes de sessão e tema em andamento.

## Decisões (confirmadas)

- Local: VM ONE, multiboot. Arch entra como mais um boot; nada de partição nova nem de encolher disco.
- Layout: subvolumes `@arch` (raiz) e `@arch-home` (/home) no btrfs `227aab74-2c7b-4b1f-b887-3e7c62a13355`, seguindo o padrão das outras distros. `@shared` é montado em `/home/share`.
- Instalação: pacstrap a partir do CachyOS (sem bootar ISO). ISO de referência: `F:\2.ISOs\archlinux-2026.11.01-x86_64.iso`.
- Bootloader: GRUB em `\EFI\arch`, com `--no-nvram`. Aarambh continua com `BootOrder` primeiro (Boot0006). Default do Aarambh segue `cachyos`.
- Ambiente: Arch puro, MangoWM via AUR (`mangowm-git`). O pacote `mangowm` do repo `cachyos-extra` não é usado.
- SSH: sempre pelo host `one` (`secrets/ssh/one.conf`). IP fixo 192.168.86.170.
- Padrões (0-start-v3): usuário `pio` (uid 1000) e root com senha `1234`, pt_BR.UTF-8, teclado br/abnt2, America/Sao_Paulo, sshd habilitado no boot, sudo NOPASSWD, btrfs + snapper (NUMBER_LIMIT=4, NUMBER_LIMIT_IMPORTANT=4, TIMELINE_CREATE=no, snapper-cleanup.timer ativo).
- Pacman otimizado com as opções de `pacman.conf.txt` (Color, ILoveCandy, VerbosePkgLists, DisableDownloadTimeout, ParallelDownloads=10, DownloadUser=alpm).

## Feito

### Instalação base
- Backup da EFI antes de alterar: `/root/arch-pre-20261112-205100/` (`efibootmgr.txt`, `efi-hashes.txt`, `aarambh.conf`).
- Subvolumes `@arch` e `@arch-home` criados.
- Pacstrap concluído: 306 pacotes (base, linux, linux-firmware, btrfs-progs, grub, efibootmgr, sudo, networkmanager, openssh, git, base-devel, snapper, nano, archlinux-keyring, kitty, pipewire, pipewire-pulse, wireplumber). Falha anterior: assinatura do mesa com cache corrompido de run morto; corrigido instalando archlinux-keyring antes.
- fstab (UUIDs do btrfs e da ESP `CCA6-D3A1`, ESP com `nofail`). `/home/share` com `@shared`.
- Locale pt_BR.UTF-8, timezone America/Sao_Paulo, keymap br-abnt2, hostname `arch`.
- Usuário pio (uid 1000, home `@arch-home`), senha 1234, root com senha 1234.
- sudoers NOPASSWD (`/etc/sudoers.d/pio`, `chmod 440`, `visudo -cf` ok).
- sshd habilitado no boot; NetworkManager com perfil estático `ens33` 192.168.86.170/24. Chaves de host copiadas do CachyOS.
- `~/.ssh` 700, `authorized_keys` 600 (dono 1000:1000). Permissão de `/home/pio` corrigida para 700 (sshd recusava).
- Snapper: NUMBER_LIMIT=4, NUMBER_LIMIT_IMPORTANT=4, TIMELINE_CREATE=no, `snapper-cleanup.timer` ativo.
- `/etc/pacman.conf` final com as opções de `pacman.conf.txt` e `DownloadUser = alpm`.

### Boot
- GRUB em `\EFI\arch` (`--bootloader-id=arch --no-nvram`) e `grub-mkconfig`.
- Aarambh: entrada `Arch Linux` em `aarambh.conf`. Boot Arch funcionando via seleção manual.
- Aarambh autodetect criava `arch.kernels` com `subvol=@` e fazia o Arch subir com o root do CachyOS. Arquivo renomeado para `arch.kernels.disabled-20261112`.
- `aarambh.efi` (hook) foi regravado (`19b3079…` -> `9d7939…`). Restaurado o original (`19b3079…`). Backups em `/root/aarambh-efi-backup-20261112-210807/` no CachyOS e em `F:\GitHub\sway\backup\aarambh\`.
- Mantido `ufw` desativado no CachyOS na sessão de teste.

### Desktop
- `mangowm-git` instalado. Dependências e apps do TODO instalados.
- sway-full: módulos instalados com `install-modules-arch.sh` (sem `random-wallpapers` e sem `wlogout`, que foram pulados de propósito).
- SDDM com tema `catppuccin-frappe-blue` e `DisplayServer=x11` (`/etc/sddm.conf.d/90-mango.conf`).
- Configs de mango de `hakuspace` com binds de `endeavouros-niri` (`~/.config/mango/`). Corrigido BOM e CRLF nos `.conf`.
- `env.conf`: `DISPLAY=:1`, `WAYLAND_DISPLAY=wayland-0`, `LIBGL_ALWAYS_SOFTWARE=1`. Sem `LIBGL` o kitty quebra no VMware (dmabuf).
- Rofi: `config.rasi` importa `~/.local/state/hakuspace/rofi-theme.rasi` (estado do tema). Tema padrão atual: `line` (`line.rasi`).
- Rofi: `rofi-wallpaper.rasi` criado em `~/.local/state/hakuspace/theme/` (resolveu `tablet`/`television`, que falhavam).
- Rofi `line.rasi`: linhas da lista com cores explícitas (transparente e azul; selecionado azul). Backup em `line.rasi.bak-20261112`.
- Scripts em `~/.local/bin/`: `theme-apply.sh`, `theme-menu.sh`, `power-menu.sh`, `clipboard-menu.sh`, `screenshot.sh`, `nightlight-toggle.sh`.
- Bind `Super+Shift+T` para o seletor de temas (`theme-menu.sh`).
- Mouse: `~/.icons` aponta para `/home/share/.icons` (symlink). Tema de cursor do CachyOS é `Vimix-cursors`.

## Problemas resolvidos (registro)

- Arch subindo no root do CachyOS: `arch.kernels` do Aarambh. Resolvido (renomeado).
- Emergência no boot por ESP: `nofail` no fstab.
- SSH recusava login: permissão de `/home/pio`. Resolvido (700).
- Mango "Invalid line format": BOM UTF-8 e CRLF dos `.conf` vindos do PowerShell. Resolvido.
- `Super+Return` sem efeito: children do mango sem `DISPLAY`/`WAYLAND_DISPLAY` e kitty sem `LIBGL_ALWAYS_SOFTWARE`. Resolvido em `env.conf`.
- Troca de tema no rofi "não mudava": `-theme` de teste pulava o `config.rasi`, e os ícones coloridos apareciam só no `Super+D`. Tema `line` definido como padrão com ícones ligados.

## Pendências

- Ponteiro do mouse: sumiu na sessão. Symlink `~/.icons` -> `/home/share/.icons` feito. Log do mango mostrava `Environment variable $XCURSOR_THEME not set, ignoring.`. `env.conf` agora tem `XCURSOR_THEME=Vimix-cursors` e `XCURSOR_SIZE=24`. Ainda falta confirmar na tela (pode exigir sair e entrar de novo).
- Wallpaper (22:25): sem wallpaper no login e na sessão. Causas: (1) `lightdm-gtk-greeter.conf` sem `background`; (2) `random-wallpaper` (sway-full) pulado antes e sem autostart no mango. Feito: `~/.local/bin/random-wallpaper.sh` copiado de `sway-full`; `~/.config/systemd/user/random-wallpaper.service` com `ExecStart=%h/.local/bin/random-wallpaper.sh` (estava `%h/.bin`); timer `random-wallpaper.timer` ativo (5 min); `exec_once=systemctl --user start random-wallpaper.service` em `autostart.conf`; greeter com `background=/usr/share/sddm/themes/catppuccin-frappe-blue/backgrounds/wall.png` (vale no próximo login). Teste: `awww` aplicou `~/Imagens/wallpapers/*.png`.
- Mouse sem ponteiro (22:22, VMware): cursor por hardware não aparece. Ajuste aplicado: `/etc/X11/xorg.conf.d/20-vmware-swcursor.conf` (modesetting, `SWcursor=true`) para o Xorg do LightDM e `WLR_NO_HARDWARE_CURSORS=1` em `/etc/environment` para o mango (wlroots). Dispositivos de mouse presentes: `VMware Virtual USB Mouse` e `VMMouse`. Ainda sem confirmação na tela.
- Logoff/tela preta (22:17): `Super+Shift+E` (quit do mango) mata o `sddm-helper` junto com a sessão (systemd `session-N.scope`). O SDDM vira `Process crashed`, sai do ar e não reabre o greeter. Reiniciar `sddm` devolve o login, mas o logoff sempre repete o problema.
- Decisão do usuário (22:21): trocar temporariamente para LightDM para configurar e depois arrumar. Instalado `lightdm` e `lightdm-gtk-greeter`. `sddm` desativado (`disable`); `lightdm` habilitado e ativo. Sessão `mango` aparece no greeter. O tema catppuccin-frappe-blue do SDDM fica pendente (ver TODO).
- SDDM/tela preta (histórico): após sair da sessão, o greeter não voltou. Reiniciar `sddm` resolveu o greeter. O mango fechava ao iniciar com `Could not connect to remote display`. Causa provável: `env=DISPLAY,:1` e `env=WAYLAND_DISPLAY,wayland-0` no `env.conf`. Essas duas linhas foram removidas (backup em `~/.config/mango/env.conf.bak-wl-20261112`). Mango iniciou depois disso.
- `wayland-session.log` tinha 31 MB de erros de blur (`fx_renderer`) do mango no VMware. Zerado. Se voltar a crescer, revisar o efeito de blur no `effect.conf`.
- Wallpaper para `tablet` e `television`: hoje usa imagem de documentação do kitty como placeholder.
- Validar `theme-menu.sh` e a troca de tema do waybar de ponta a ponta.
- `taskbar` (waybar) referencia `hakucfg` inexistente.
- Staging `F:\GitHub\sway\arch-mango\configs\home` ainda não tem as últimas mudanças de ONE: `line.rasi` com cores explícitas, `env.conf` (sem XCURSOR), `~/.local/state` rofi.
- Launcher (23:08): a barra de abas ainda aparecia porque `~/.config/rofi/themes/line.rasi` listava `mode-switcher` em `content-area`. Agora `children: [ listview ]` (backup `line.rasi.bak-20261112`). Confirmado por screenshot.
- tokyo-2 drawers (23:09): configs de `tokyo` e `tokyo-2` são idênticas (só cores de fundo diferem). Três reinícios seguidos de tokyo-2 abriram colapsados. Um print às 23:04 mostrou os grupos monitor/settings expandidos, sem reproduzir depois. Pendente: confirmar se acontece no login.
- Rofi (23:13): Super+Shift+D (`rofi -show run`) volta ao original, com abas (`line.rasi` e `config.rasi` restaurados dos backups). Super+D e Alt+D usam `rofi -show drun -no-sidebar-mode -theme ~/.config/rofi/themes/launcher-notabs.rasi` (sem abas, `content-area` com só `listview`). Confirmado por screenshot. Backup do bind em `bind.conf.bak-20261112-rofi`. `mango` recarregado (`reload_config` ok).
- tokyo-2 (23:13): grupos `group/monitor` e `group/settings` com `"start-expanded": true` (já existia `click-to-reveal`). Inicia expandido e clique colapsa. Confirmado por screenshot. Backup `tokyo-2/config.bak-20261112`. `tokyo` não mudou.
- Logout (23:50): "Sair" do power menu deixava a tela preta, mesmo bug de antes (`sddm-helper` morre junto com a sessão, SDDM dá "Process crashed" e não reabre o greeter). Workaround: `~/.local/bin/power-menu.sh` agora faz `sudo systemctl restart --no-block sddm` em "Sair" (backup `power-menu.sh.bak-20261112`). Greeter reiniciado manualmente e confirmado. `Super+Shift+E` (quit) testado pelo usuário: voltou ao SDDM (23:50). Sem alteração no bind.
- SDDM (23:41): login no SDDM entra no mango, mas o cursor não carregava. Causa: o compositor não recebia `XCURSOR_THEME`/`XCURSOR_SIZE` (só `env.conf`, que vale para os filhos). Fix: `/etc/environment` com `XCURSOR_THEME=Vimix-cursors` e `XCURSOR_SIZE=24` (pam_env, backup `/etc/environment.bak-20261112`). Vale no próximo login.
- Super+Shift+T (23:05): `~/.local/bin/theme-menu.sh` lista direto os temas do waybar (sem a escolha waybar/rofi) e aplica com `theme-apply.sh waybar <tema>`. Lista atual: coredge, island, left, legacy, minimal, neon, taskbar, tokyo, tokyo-2, top (`module` sem `config`, fora da lista). Backup `theme-menu.sh.bak-20261112`.
- Rofi (23:02): launcher (Super+D) sem a barra de abas (`sidebar-mode: false` em `~/.config/rofi/config.rasi`). Hotkeys (Super+F) agora usam `rofi -no-config` e o `hotkeys.rasi` com as cores do rofi-wallpaper (catppuccin-mocha). Backups `.bak-20261112`. Teste visual pendente.
- Fonte padrão (22:57): `CodeNewRoman Nerd Font 11` no GTK 3/4 (`gtk-font-name`), gsettings `font-name` e `document-font-name`, e `~/.local/state/hakuspace/theme/fonts.css` (usado pelos waybar). Backups `.bak-font-20261112`. Waybar reiniciado. Kitty já usava essa fonte.
- GTK (22:55): tema trocado para `Tokyonight-Dark-Storm` em `~/.config/gtk-3.0/settings.ini` e `gtk-4.0/settings.ini` (backup `.bak-20261112`) e em gsettings (`gtk-theme`). Ícones seguem `MacTahoe-dark`. Vale para apps GTK; Nautilus pode precisar de reabertura.
- term-hub: feito em 22:50 a partir de `amonetlol/sh` (`modules/hub-ssh_term.sh`, repo dot em `~/.cache/base-dot-repo`). Instalados `~/.local/bin/term-hub`, `term-hub.d/` e `ssh-hub` (com backup anterior, se existia). Sessões `ff` (install, scripts, downloads) e `ffd` (Arch) criadas via `tmux-attach-ff_ffd.sh Arch`. Logs em `/tmp/ff-*.log`. `ssh.conf` do term-hub vazio: preencher quando for usar. Atalhos: `Ctrl+b l` seleciona logs, `Ctrl+b N` novo grupo, `Ctrl+b Q` encerra o servidor dedicado.
- Commit no repo só quando o usuário pedir.
- Optional: Aarambh cosmético do CachyOS (Plymouth no initrd) não investigado.

## Observações

- O `TODO.md` em `C:\Users\Craig\Downloads\Mult_ONE-chatGPT\` pertence ao TWO e não foi alterado. O desta distro está em `arch-mango/TODO.md`.
- Em `/mnt/btrfs-top` ficam os subvolumes de todas as distros; não mexer em nada além de `@arch` e `@arch-home`.