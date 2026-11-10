# CentOS Stream 10

Rice baseado em `../sway-full`, com Foot e Micro. Execute `bash cento_os/install.sh` como usuario comum com sudo. O instalador preserva NetworkManager e sshd, configura o SDDM com a unica entrada `Sway` para o proximo boot e nao reinicia a sessao.

Pacotes vem do dnf com CRB, EPEL 10, RPM Fusion (free e nonfree) e os COPRs `yselkowitz/wlroots-epel`, `@sway-sig/epel` e `atim/starship`. `swayosd` 0.3.2 e `gtk4-layer-shell` 1.1.1 sao compilados localmente (Rust/meson) porque nao existe pacote para EL10; o terminal e o `foot`, precompilado no COPR, e o editor e o binario oficial do Micro, sem a cadeia de dependencias do Neovim. Chrome vem do RPM oficial do Google. Acompanhe com `tail -f /tmp/co-install.log`.

Os comandos de energia usam `loginctl`; o agente de autenticacao e o `polkit-kde`, e o backend de libinput do SwayOSD fica como servico de usuario do systemd. Backups do rice ficam em `~/.local/state/sway-full/backups`. Execute `bash cento_os/verify.sh` para conferir comandos, acoes de wlogout, modulos, entrada unica do SDDM e configuracao Sway; essa verificacao nao implica teste visual.

Aliases de pacotes ficam em `~/.aliases-cento_os` (repo `dot`); o `up2` roda `sudo dnf upgrade` sem `-y`, listando os pacotes e perguntando antes de aplicar.
