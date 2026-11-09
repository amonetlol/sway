# MocaccinoOS + Sway

A configuracao usa `sway-full`, LightDM com tema Colloid Catppuccin e apenas a sessao Sway. O Thunar e suas bibliotecas usam pacotes Debian isolados no perfil, pois o Mocaccino o fornece apenas na camada XFCE. `install-extra.sh` instala utilitarios binarios que nao estao disponiveis separadamente no repositorio Luet.

Execute `bash mocaccino/install.sh` como usuario comum com sudo. O script original de temas do `sway-full` exige Papirus em `/usr/share/icons/Papirus` e pode terminar com erro se os icones estiverem instalados apenas no perfil do usuario; ajuste a instalacao de icones antes de executar a etapa de temas. A remocao do GNOME nao e automatica.
