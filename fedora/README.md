# Fedora + Sway

Port das configuracoes Debian para Fedora x86_64, aplicado no Fedora 45: DarkShadow, 2SSk, Gruvbox, SDDM e GRUB Leaf.

Na raiz do repositorio:

```bash
sudo bash fedora/install-pacotes.sh --user "$USER"
sudo bash fedora/install-sway_configs.sh --user "$USER"
sudo bash fedora/install-personal_configs.sh --user "$USER"
```

Ou `sudo bash fedora/install.sh --user "$USER"`.

| Caminho | Conteudo |
| --- | --- |
| `install-pacotes.sh` | DNF, pacotes Fedora e ferramentas |
| `install-sway_configs.sh` | Sway, temas, servicos, SDDM Wayland e GRUB2 |
| `install-personal_configs.sh` | Configuracoes atuais dos repositorios amonetlol |
| `config/` | Dotfiles com `@@HOME@@` substituido na instalacao |
| `scripts/` | Implementacao e auxiliares |
| `manifests/` | Pacotes, permissoes, links e atalhos |
| `assets/` | Temas, fontes, icones e checksums preservados do Debian |
| `compat/` | Compatibilidade Qt e referencia Xorg Debian |
| `upstream/modules/` | Referencias; a instalacao pessoal busca as versoes atuais |
| `docs/` | Instalacao, adaptacoes e validacao Fedora |

Backups em `/var/backups/sway-fedora/` e `~/.local/state/sway-fedora/backups/`. Nao reinicia nem encerra a sessao atual. Faca novo login para carregar o desktop.

[Instalacao](docs/INSTALACAO.md) ? [Validacao](docs/VALIDACAO.md)

`install-pacotes.sh` tambem executa `install-cli.sh` como usuario de destino. Essa etapa instala as ferramentas CLI e baixa o modulo atual `pacotes_fedora.sh`, adaptando os nomes RPM antigos do Fedora 45. Pipenv fica em um venv do usuario. Para executar apenas essa etapa: `bash fedora/install-cli.sh` (usuario comum com sudo).
