# Calamaro OS: fixes do rice (Niri + Waybar + rofi + GTK)

Arquivos copiados da VM Calamaro (Gentoo/Calamares, ID `gentoo`, /home próprio `@calamaro-home`).
Cada distro tem o próprio `/home`; só `/home/share` é compartilhado entre elas.

## Estrutura

- `home/` vai para o `$HOME` do usuário (`~`).
- `share/` vai para `/home/share` (compartilhado).

## Aplicar

```bash
cp -a home/. ~/
cp -a share/. /home/share/
```

## Passos manuais (não estão nos arquivos)

GTK / ícones (dconf, xsettingsd e kdeglobals):

```bash
gsettings set org.gnome.desktop.interface icon-theme 'Rice-Colloid-Gruvbox'
gsettings set org.gnome.desktop.interface gtk-theme 'Kanagawa-Yellow-Dark-Dragon'
# xsettingsd: Net/IconThemeName "Rice-Colloid-Gruvbox" (em ~/.config/xsettingsd/xsettingsd.conf)
# kdeglobals: [Icons] Theme=Rice-Colloid-Gruvbox
pkill -HUP -x xsettingsd
```

GTK4 (libadwaita) usa o tema do Kanagawa linkado a partir de `/home/share/.themes/Kanagawa-Yellow-Dark-Dragon/gtk-4.0`:

```bash
T=/home/share/.themes/Kanagawa-Yellow-Dark-Dragon/gtk-4.0
mkdir -p ~/.config/gtk-4.0
for f in gtk.css gtk-dark.css assets; do ln -sfn "$T/$f" ~/.config/gtk-4.0/$f; done
```

Ícones de terceiros (McMuse e Numix, instalados em `/home/share/.icons`):

```bash
git clone --depth 1 https://github.com/yeyushengfan258/McMuse-circle /tmp/McMuse-circle
bash /tmp/McMuse-circle/install.sh -d /home/share/.icons -c
git clone --depth 1 https://github.com/numixproject/numix-icon-theme-circle /tmp/Numix-Circle
cp -a /tmp/Numix-Circle/Numix-Circle /tmp/Numix-Circle/Numix-Circle-Light /home/share/.icons/
```

Dependências de ícone do `Rice-Colloid-Gruvbox` (precisam estar instaladas): `Colloid-Yellow-Nord-Dark`, `Papirus-Dark`, `Gruvbox-Plus-Dark`, `hicolor`.

Atalhos ocultos no rofi: os `.desktop` em `home/.local/share/applications/` já estão com `NoDisplay=true`. Os que não existem na distro são ignorados.

Pacotes usados pelos scripts: `awww` (wallpaper), `rofi` 2.0, `waybar`, `niri`, `kitty`, `python3`. O sorteio de wallpaper usa `awk` (não depende de `shuf`).

## Fixes

### Niri (`home/.config/niri`)
- Resolução padrão `Virtual-1` em `1600x900@60.000`.
- `focus-ring` no tema Kanagawa (`#c8c093` ativo, `#625e5a` inativo). Antes, o foco era azul por padrão.
- `hotkey-overlay { skip-at-startup }`: o popup de atalhos não abre no login.
- `Mod+F1` abre `~/.local/bin/niri-keys-help` (lista de atalhos no rofi, com o tema) em vez do overlay do Niri, que não tem cor configurável.
- `Mod+T` alterna flutuante (`toggle-window-floating`).

### Kitty
- `current-theme.conf` com a palette Kanagawa Dragon (mesma do Waybar e do rofi).

### rofi (`home/.config/rofi`)
- Azul (Catppuccin/Frappe/M3) trocado pela palette Kanagawa em todos os `.rasi`.
- `icon-theme` do `config.rasi` e do `rofi-wallpaper/config.rasi` = `Rice-Colloid-Gruvbox`. Antes o `McMuse-circle-dark` ficava sobrescrevendo o `colors.rasi`.

### rofi wallpaper (`home/.config/rofi-wallpaper`, Super+F10)
- `kanagawa-dragon.rasi` substitui o `catppuccin-mocha.rasi` (sem azul; `mauve` e `red` ajustados).
- `wallpaper.py` aplica a imagem escolhida direto com `awww img` (sobe o `awww-daemon` se precisar). Antes chamava um script que não existia em `~/.local/bin`.
- A escolha manual cria `~/.local/state/wallpaper-manual`. O daemon de rotação respeita esse arquivo. Para voltar à rotação automática: `rm ~/.local/state/wallpaper-manual`.

### Wallpaper automático (`home/.local/bin/niri-wallpaper-daemon`, `home/.bin/random-wallpaper.sh`)
- `shuf` trocado por `awk` (não existe em algumas distros, como o Chimera). Sem ele a imagem ficava vazia.
- Daemon: rotação a cada 90 s, respeita `wallpaper-manual`.

### Waybar (`home/.config/waybar`)
- Ícone da distro em `custom/distro`, lendo o `ID` do `/etc/os-release` via `scripts/distro-icon.py`. Gentoo/Calamaro usa o glifo do Gentoo.
- O ícone da distro abre o rofi (`rofi -show drun`) ao clicar. O ícone do CachyOS (`custom/launcher`) foi removido.
- Estilo `#custom-distro` usa a cor de destaque `@accent`.

### GTK e ícones
- `gtk-3.0/settings.ini` e `gtk-4.0/settings.ini`: `gtk-icon-theme-name=Rice-Colloid-Gruvbox` e `gtk-theme-name=Kanagawa-Yellow-Dark-Dragon` (no GTK4 o tema vem dos symlinks acima).
- `share/.icons/Rice-Colloid-Gruvbox/index.theme`: ícones herdando `Colloid-Yellow-Nord-Dark`, `Papirus-Dark`, `Gruvbox-Plus-Dark` e `hicolor`, nessa ordem.

### Atalhos ocultos (hide-shortcuts)
- Ocultados: btop, micro, rofi, rofi-theme-selector, vim, nvim, htop, qv4l2, qvidcap, qt5ct, qt6ct, designer, linguist, qdbusviewer, assistant, bssh, bvnc, avahi-discover, cups, Alacritty, lstopo, xgps, xgpsspeed, CMake, Btrfs Assistant, CachyOS Hello, kdesystemsettings e org.kde.kwalletmanager.
- Os `.desktop` ocultos são cópias em `~/.local/share/applications/` com `NoDisplay=true` logo após `[Desktop Entry]`.
- Em distros com BSD sed, `sed 'a ...'` não funciona. Use Python para inserir a linha.
