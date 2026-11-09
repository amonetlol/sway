# Alpine + Sway

Na raiz do repositório, execute `sh alpine/install.sh` como usuário comum com acesso a `doas`. Usa o rice local em `sway-full`, OpenRC, elogind, foot e micro. Configurações anteriores são movidas para `~/.local/state/sway-alpine/backups/`.

O instalador configura eudev e SDDM, aplica os temas do rice e registra os módulos concluídos em `~/.local/state/sway-alpine/modules-completed`. Neovim e Kitty são substituídos por Micro e Foot. O histórico de texto usa clipman e o volume usa `wpctl`; Sublime Text e swayosd não estão disponíveis nos repositórios Alpine usados. Se o NetworkManager não estiver ativo, o menu de rede mostra o estado e a rota atual sem alterar a configuração de rede.
