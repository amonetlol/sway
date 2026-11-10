# Calculate Linux (OpenRC)

Rice baseado em `../sway-full`, com Foot e Micro. Execute `bash calculate-linux/install.sh` como usuario comum com sudo. O instalador preserva NetworkManager e sshd, configura o SDDM para o proximo login e nao reinicia a sessao. Remove os aplicativos herdados do desktop e os pacotes KDE/Plasma que nao forem exigidos por outros pacotes, preservando o Chrome e as ferramentas do rice.

Quando a arvore Gentoo estiver incompleta, o instalador obtem a arvore do Calculate em `/var/calculate/repos/gentoo-sway`, ajusta sua localizacao no Portage e guarda copia da configuracao anterior em `/etc/portage/zz-calculate.conf.backup-sway`. O overlay GURU fornece wlogout e SwayOSD. Alguns pacotes sao compilados quando nao ha binarios compativeis. Acompanhe com `tail -f /var/log/emerge.log`.

Os comandos de energia usam `loginctl` do elogind; o backend SwayOSD usa um servico OpenRC. Backups do rice ficam em `~/.local/state/sway-full/backups`. FontForge, xcalib e as configuracoes de impressao continuam instalados, mas ficam fora do menu rofi por override local em `~/.local/share/applications` (`hide-menu-apps.sh`). Execute `bash calculate-linux/verify.sh` para conferir comandos, acoes de wlogout, arquivos, servico e configuracao Sway; essa verificacao nao implica teste visual.
