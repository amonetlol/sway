# Registro da instala??o base: Redcore

Conte?do recuperado da VM TWO ap?s os ajustes posteriores. Os arquivos em `home/` da pasta da distribui??o s?o os ajustes atuais e n?o foram alterados.

- Inicializa??o observada: OpenRC.
- Subvolumes usados: `@redcore`, `@redcore-home`, `@shared` e `@snapshots-redcore`.
- Perfil inicial de Niri/Waybar: `pie`, em `../../niri-two/`.
- `pacotes-world-observados.txt`: estado atual do Portage, incluindo mudan?as feitas depois da instala??o; n?o ? uma lista exata dos pacotes originais.
- `ff-snapshot-redcore.sh` e o agendamento correspondente foram copiados da m?quina. O script cont?m o UUID do disco da TWO: revise-o antes de usar em outra m?quina.

O sistema base foi preparado a partir da imagem instalada em subvolumes Btrfs; usu?rios, SSH, sudo, rede, locale e boot foram configurados por comandos executados na sess?o, n?o por um instalador ?nico salvo. Os logs tempor?rios originais j? estavam vazios na verifica??o. Estes arquivos n?o constituem um instalador completo nem garantem reinstala??o autom?tica.

