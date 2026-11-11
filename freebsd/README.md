# FreeBSD + Sway

Execute `sh freebsd/install.sh` na raiz do repositorio como usuario com sudo. Utiliza os arquivos de `sway-full`, Foot e Micro. O backend X11 do Sway e usado no VMware devido a falta de DRM/KMS vmwgfx no FreeBSD; depende do servidor Xorg e do driver virtual. Os servicos usam rc.d. Configuracoes anteriores ficam em `~/.local/state/sway-freebsd/backups/`.

Os modulos bash, bin, btop, fastfetch, fonts, starship, foot, wallpapers e recovery-shortcuts sao instalados pelo repositorio sh. Componentes especificos de Linux, incluindo Snapper e Sublime Text, nao sao instalados.
