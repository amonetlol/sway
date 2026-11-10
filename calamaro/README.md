# CalamaroOS (base Gentoo, Plasma de fabrica)

Rice baseado em `../sway-full`, com Foot e Micro. Execute `bash calamaro/install.sh` como usuario comum com sudo. O instalador sincroniza o repositorio `gentoo` (ausente na imagem), ajusta o perfil para `desktop/systemd`, remove o KDE mantendo o SDDM, aplica o tema Catppuccin Frappe Blue, configura o SDDM com a unica entrada `Sway` para o proximo boot e nao reinicia a sessao.

Pacotes vem do portage (::gentoo) mais o overlay GURU ja habilitado na imagem (`awww`, `swayosd`, `wlogout`). O terminal e o `foot` (compilacao leve) e o editor e o binario oficial do Micro, sem a cadeia de dependencias do Neovim. O navegador continua o `firefox-bin` de fabrica, evitando compilar um browser. O agente de autenticacao e o `lxqt-policykit`, reaproveitando o Qt6 ja presente. Acompanhe com `tail -f /tmp/calamaro-install.log`.

Se o emerge acusar conflito de USE, o instalador aplica os arquivos `._cfg` gerados e retenta pacote por pacote. Os comandos de energia usam o systemd nativo; o backend de libinput do SwayOSD fica como servico de usuario. Backups do rice ficam em `~/.local/state/sway-full/backups`. Execute `bash calamaro/verify.sh` para conferir comandos, acoes de wlogout, modulos, entrada unica do SDDM (tema Catppuccin Frappe Blue) e configuracao Sway; essa verificacao nao implica teste visual.

Aliases de pacotes ficam em `~/.aliases-calamaro` (repo `dot`); o `up2` roda `sudo emerge --ask --update --deep --newuse @world`, listando os pacotes e perguntando antes de aplicar.
