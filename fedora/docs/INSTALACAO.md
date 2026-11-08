# Instalacao Fedora

Use as tres etapas descritas no README, ou `sudo bash fedora/install.sh --user "$USER"`.

O port usa RPM/DNF e o grupo wheel. Matugen 4.2.0 e Quickshell 0.3.2 sao compilados em /opt/sway-fedora/tools e instalados em /usr/local para suportar as APIs dos temas; o matugen dos repos Fedora e 3.1.0 (sem --source-color-index) e o quickshell Fedora 0.2 nao atende o tema 2SSk. Apos atualizar o Qt, execute novamente scripts/install-quickshell.sh para recompilar contra a versao instalada. Ghostty usa o COPR scottames/ghostty indicado em https://ghostty.org/docs/install/binary. Lazygit, Starship, procs e tealdeer usam releases dos respectivos projetos no GitHub. Tree-sitter CLI e Prettier usam npm; Pipenv fica em um venv isolado em /opt/sway-fedora/tools.

O DNF recebe max_parallel_downloads=10 e fastestmirror=False, mantendo a selecao do metalink Fedora. Referencia: https://dnf5.readthedocs.io/en/latest/dnf5.conf.5.html. As demais opcoes existentes sao preservadas; a configuracao anterior recebe backup.

SDDM usa o compositor Wayland fornecido pelo Fedora e o tema berserk. O GRUB usa /boot/grub2/grub.cfg e preserva BLS e parametros de boot existentes. Nao grava no stub EFI. Nao remove pacotes automaticamente.

Em VMware, o lancador Sway aplica renderizacao por software e XWayland sem glamor, como no desktop de origem. A configuracao Xorg Debian fica apenas como referencia; nao e aplicada ao Fedora.

As configuracoes pessoais buscam as branches padrao atuais de amonetlol/sh, dot, goodies, nvim e wall2. Os aliases usam Fedora/DNF, fd e bat usam os executaveis RPM e o PolicyKit localiza mate-polkit por RPM. Wallpapers mudam a cada 90 segundos. Os temas e atalhos do desktop Debian foram preservados.

A instalacao cria backups, restaura contextos SELinux dos caminhos implantados e habilita SDDM e Bluetooth para os proximos boots. Nao reinicia nem interrompe a sessao atual. Faca novo login em Sway.

O SDDM usa /usr/local/bin/sddm-fedora-compositor. Em VMware, o compositor usa WLR_RENDERER=pixman e o greeter usa QT_QUICK_BACKEND=software para evitar a falha de importacao DMA-BUF. Fora do VMware, preserva a renderizacao padrao. Referencia Qt: https://doc.qt.io/qt-6/qtquick-visualcanvas-adaptations.html.
