# Sway Full — Catppuccin Frappe Blue

Cópia das configurações da VM EndeavourOS, preparada para Arch Linux e derivadas.
Mantém os gaps, borda azul, Waybar, Rofi, Kitty, Btop, Wlogout e serviços de wallpaper.

## Instalação

Execute como usuário comum, com `sudo` disponível, nesta ordem:

```bash
bash install-pacotes.sh
bash install-modules.sh
bash install-sway.sh
bash install-sddm_with-theme.sh
```

Depois selecione **Sway Full** no SDDM. O instalador não encerra a sessão nem reinicia a máquina.

Para obter cada instalador diretamente do GitHub, sem depender de uma cópia antiga:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/install-pacotes.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/install-modules.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/install-sway.sh)
bash <(curl -fsSL https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/install-sddm_with-theme.sh)
```

Os módulos são baixados de `amonetlol/sh/main/modules` a cada execução. A lista de pacotes
vem de `amonetlol/ps/main/arch-pacotes.txt`. O script de limites Snapper vem de
`amonetlol/vm_rice/main/scripts/lib/snapper.sh`. Não há cópias congeladas desses instaladores.
Quando executados fora desta pasta, os scripts obtêm o pacote `sway-full` atualizado do GitHub.
Uma execução dentro de um checkout usa as configs desse checkout; faça `git pull` para atualizá-las.

### Seleção dos módulos

`install-modules.sh` começa com todos marcados `[X]`. Digite números separados por espaço ou
vírgula para marcar/desmarcar, `t` para todos, `n` para nenhum e Enter para confirmar.
`q` cancela. A instalação só começa após a confirmação. `--all` confirma todos sem o menu.

Inclui bash, bin, btop, fastfetch, fonts, starship, Neovim para usuário e root,
VMware, random-wallpapers, hide-shortcuts, recovery-shortcuts, Kitty, wallpapers
e sublime-text.
Snapper é aplicado somente quando a raiz é Btrfs.

- `hide-shortcuts`: omite o bloco de renomeação do Thunar.
- `random-wallpapers`: usa as units Sway desta VM, troca a cada **90s**, fade de **2s** e `awww`.
- Btrfs: retenção `6` conforme a função upstream e menu GRUB limitado a seis entradas.
  Snapshots importantes são uma categoria separada do Snapper; `current` não é um snapshot salvo.
- `yay` existente é reutilizado. Se faltar, `yay-bin` é compilado/instalado pelo AUR.
- Blackbox Terminal e Ulauncher são excluídos. `p7zip` é mapeado para `7zip`.
  Geist/Geist Mono vêm do release upstream, pois os nomes antigos de pacote não estão disponíveis.

## Conteúdo e dependências incluídas

- `.config/`: sway, waybar, wlogout, kitty, btop, rofi, rofi-wallpaper, GTK 3/4 e systemd/user.
- `.local/bin/`: todos os scripts locais da VM, mais o script de wallpaper antes em `~/.bin`.
- Cores estáticas do Sway foram incluídas na própria pasta; não dependem de `~/.cache/wal`.
- Os caminhos fixos do usu?rio da VM foram removidos. As configs usam o HOME do usuário instalado.
- Serviços: `awww`, timer de 90s, Caffeine e Waybar, associados à sessão Sway.
- Áudio PipeWire/WirePlumber, portais GTK/wlr, agente Polkit, keyring e XWayland.
- GTK Colloid Dark Catppuccin, Papirus-Dark com pastas Frappe Blue no Nautilus,
  McMuse-circle **somente no Rofi**, cursor Vimix e CodeNewRoman Nerd Font.
  Os temas/fontes são obtidos das fontes GitHub em `scripts/install-themes.sh`.
  `themes.json` registra separadamente GTK, ícones do sistema, ícones do Rofi e cursor.
- SSH Hub/Term Hub sem credenciais; em reinstalações, campos locais preenchidos são preservados.

Backups ficam em `~/.local/state/sway-full/backups/`; SDDM também usa `/var/backups/sway-full-sddm-*`.

## Ajustes da máquina

O monitor da VM é `Virtual-1`, 1920×1080. Ajuste a linha de saída em `.config/sway/config`
se usar outro monitor. Locale `pt_BR.UTF-8`, teclado ABNT2 e fuso São Paulo são configurados
pelo instalador de pacotes. Em VMware, o launcher da sessão ativa cursor por software.
Os wrappers de Kitty/GTK conservam os contornos de renderização usados nesta VM.

## Atalhos principais

| Atalho | Ação |
|---|---|
| Super+F1 | Guia do Sway |
| Super+/ no Kitty | Guia do Kitty |
| Super+F10 | Rofi Wallpaper |
| Super+Enter / W / E | Kitty / Firefox / Nautilus |
| Super+D / X / V | Rofi / Wlogout / Clipboard |
| Super+T | Flutuante |
| Super+; | Abas, Empilhado, Horizontal ou Vertical |
| Alt+Tab / Super+Tab | Janela seguinte / workspace seguinte |
| Super+setas | Trocar janelas de posição |
| Super+Shift+R | Recarregar Sway |

CPU/memória na Waybar abrem Btop flutuante; som abre Pavucontrol flutuante;
Ethernet abre o menu de rede; a data mostra calendário em pt-BR.

## Valida??o desta c?pia

Sintaxe Bash/Python e JSON conferida. O snapshot passou no parser do Sway
com backend headless e HOME separado, no carregador de configura??o do Kitty
sem erros e nos parsers dos temas Rofi. As URLs dos m?dulos, lista de pacotes
e fun??o Snapper retornaram HTTP 200. N?o foi executada uma instala??o completa
em sistema limpo nem valida??o gr?fica interativa dos instaladores.
