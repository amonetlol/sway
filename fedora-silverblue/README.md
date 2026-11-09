# Fedora Silverblue + Sway

Usa as configuracoes compartilhadas de `sway-full` e pacotes em camadas via rpm-ostree. As alteracoes no sistema entram em vigor no proximo boot. O instalador convencional Fedora usa DNF e modifica /usr, portanto nao deve ser usado no Silverblue.

`install-config.sh` aplica o rice com backups e adapta wlogout, volume, brilho e wallpaper para as ferramentas disponiveis nos repositorios Fedora.
