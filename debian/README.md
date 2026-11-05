# Debian + Sway

Configurações e instaladores para Debian 13 / Sid (amd64), com os temas DarkShadow, 2SSk e Gruvbox.

Execute na raiz do repositório, nesta ordem:

```bash
sudo bash debian/install-pacotes.sh --user "$USER"
sudo bash debian/install-sway_configs.sh --user "$USER"
sudo bash debian/install-personal_configs.sh --user "$USER"
```

Ou execute as três etapas com `sudo bash debian/install.sh --user "$USER"`.

| Caminho | Conteúdo |
| --- | --- |
| `install-pacotes.sh` | Pacotes e ferramentas do sistema |
| `install-sway_configs.sh` | Sway, temas, serviços, SDDM e GRUB |
| `install-personal_configs.sh` | Configurações pessoais atualizadas dos repositórios amonetlol |
| `config/` | Configurações replicáveis; `@@HOME@@` é substituído durante a instalação |
| `scripts/` | Implementação e auxiliares dos instaladores |
| `manifests/` | Pacotes, debloat, atalhos ocultos, permissões e links simbólicos |
| `assets/` | Arquivos compactados, checksums e tema GRUB Leaf |
| `compat/` | Ajustes para VMware e versões anteriores do Qt |
| `upstream/modules/` | Cópias de referência dos módulos; o instalador pessoal busca as versões atuais online |
| `docs/` | Instruções detalhadas, adaptação DarkShadow e registros de validação |

[Instalação e detalhes](docs/INSTALACAO.md) · [DarkShadow](docs/DARKSHADOW.md) · [Validação](docs/VALIDACAO.md)

As três entradas de instalação mantêm seus nomes e caminhos. Nenhum instalador altera o Debian para Sid automaticamente.
