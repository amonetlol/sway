# Kitty Tab

Configuração do Kitty baseada em [dream-wa1ker/hyprdots-0](https://github.com/dream-wa1ker/hyprdots-0/tree/main/dots/dot_config/kitty), adaptada com Bash, tema Vviva, fundo `#303446` e fonte **0xProto Nerd Font 11**.

A barra aparece com duas ou mais abas, nomeadas `tab 1`, `tab 2` etc. A decoração da janela fica oculta. Inclui divisão de painéis, busca e guia de atalhos em Rofi.

## Instalação

Requer Kitty, Bash, Python 3, Rofi e a fonte 0xProto Nerd Font instalados.

```bash
bash install.sh
~/.local/bin/kitty-tab
```

O instalador copia os arquivos para `~/.config/kitty-tab` e cria o lançador `~/.local/bin/kitty-tab`, preservando versões anteriores com backup. Configure o atalho de terminal da sua interface para executar esse lançador. O Starship continua sendo o configurado pelo seu shell.

## Atalhos

| Atalho | Ação |
| --- | --- |
| Ctrl+Shift+F1 | Abrir o guia completo |
| Alt+← / Alt+→ | Aba anterior / próxima |
| Alt+↑ ou Ctrl+Shift+T | Nova aba |
| Alt+↓ ou Alt+Q | Fechar aba atual |
| Alt+1 até Alt+9 | Ir diretamente para a aba N |
| Alt+H / Alt+V | Dividir em painéis horizontal / vertical |
| Alt+K | Escolher um painel pelas letras exibidas |
| Alt+C | Fechar painel |
| Alt+F | Ampliar painel / voltar ao layout |
| Ctrl+F | Buscar texto; Esc fecha a busca |

Os atalhos precisam estar disponíveis no compositor. Fechar abas e painéis encerra os programas que estiverem neles. A lista completa fica em `SHORTCUTS.txt`.
