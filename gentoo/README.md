# Gentoo (systemd)

Rice baseado em `../sway-full`, com adaptacoes locais aplicadas somente no HOME.

```bash
bash gentoo/install.sh
```

Execute como usuario comum com sudo, mantendo `gentoo` e `sway-full` lado a lado.
Etapas independentes: `install-pacotes.sh`, `install-cli.sh`, `install-modules.sh`, `install-sway.sh`, `install-sddm.sh`, `install-services.sh`, `verify.sh`.

- Foot com cores Catppuccin Frappe e Micro substituem Kitty e Neovim. Binds e aliases de nvim sao adaptados para Micro.
- `packages.txt` contem apenas o rice e ferramentas usadas: sem Node/npm, LSP, Lua/Luarocks, Pipenv, Prettier ou tree-sitter para Neovim.
- Portage prioriza binarios compativeis; GURU fornece SwayOSD, wlogout e nwg-look; Loupe e as dependencias necessarias tambem recebem `~amd64`.
- Wallpapers usam swaybg, incluindo selecao no Rofi e timer de troca. O awww foi omitido porque o download oficial do Codeberg estava indisponivel; nao ha transicoes animadas.
- Ferramentas CLI incluem eza, duf, bat, ripgrep, procs, zoxide, tldr e lazygit. Duf, zoxide, tldr e lazygit usam binarios oficiais com SHA-256 verificado.
- Micro e cliphist usam binarios oficiais; o Micro tem SHA-256 conferido. Starship usa o instalador oficial do modulo.
- Modulos: bash/bin, btop, fastfetch, fontes, Starship, VMware, wallpapers, random-wallpapers, hide/recovery-shortcuts e Snapper. Terminal/editor usam Foot/Micro; Sublime e a cadeia de plugins de Neovim nao fazem parte deste conjunto enxuto.
- GTK Colloid, icones Papirus Frappe/McMuse, cursor Vimix, Rofi, Waybar, PipeWire e SDDM seguem sway-full.
- Na VMware, o compositor usa Pixman para evitar recompilar Mesa apenas para o driver SVGA. O teclado usa layout `br` e modelo `abnt2`.
- A rede existente do systemd-networkd e o GRUB instalado sao preservados. O menu de rede mostra o estado sem trocar para NetworkManager.
- wlogout: swaylock, swaymsg exit, systemctl poweroff e systemctl reboot. A verificacao valida os comandos sem acionar desligamento ou reboot.
- SDDM e habilitado para o proximo boot. Escolha **Sway**. Nenhuma sessao grafica e reiniciada pelo instalador.
- Configuracoes anteriores ficam em `~/.local/state/sway-full/backups`; registro de modulos em `~/.local/state/sway-gentoo/modules.tsv`.

```bash
bash gentoo/verify.sh
```

A verificacao e textual: comandos, arquivos, fontes, acoes do wlogout e habilitacao de servicos. Nao implica validacao visual da sessao.
