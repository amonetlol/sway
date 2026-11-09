#!/usr/bin/env bash
# Ferramentas pessoais do modulo Fedora atual, com nomes RPM atualizados.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuario comum, com sudo." >&2; exit 1; }
work="$(mktemp -d -t sway-fedora-cli.XXXXXXXX)"
trap 'rm -rf -- "$work"' EXIT
sudo -v
# Preferir os pacotes Fedora quando disponiveis; evita fallbacks antigos de releases.
sudo dnf install -y eza duf zoxide fastfetch fd-find ripgrep fzf bat btop compat-lua python3-virtualenv python3-neovim
curl -fL --retry 3 -o "$work/pacotes_fedora.sh" https://raw.githubusercontent.com/amonetlol/sh/main/modules/pacotes_fedora.sh
# Um pacote retirado do Fedora nao deve impedir os demais do mesmo grupo.
sed -i \
  -e 's/\r$//' \
  -e 's/sudo dnf install -y /sudo dnf install -y --skip-unavailable /' \
  -e 's/^  p7zip \\$/  7zip \\/' \
  -e '/^  p7zip-plugins \\$/d' \
  -e 's/^  lua5\.1 \\$/  compat-lua \\/' \
  -e 's/^  virtualenv$/  python3-virtualenv/' \
  -e 's/^  python3-pynvim /  python3-neovim /' \
  -e 's/_Linux_/_linux_/g' \
  "$work/pacotes_fedora.sh"
bash "$work/pacotes_fedora.sh"
# Pipenv nao possui RPM nesta versao; manter Python do sistema intacto.
if ! command -v pipenv >/dev/null && [[ ! -x "$HOME/.local/bin/pipenv" ]]; then
  python3 -m venv "$HOME/.local/share/sway-fedora/pipenv"
  "$HOME/.local/share/sway-fedora/pipenv/bin/pip" install pipenv
  mkdir -p "$HOME/.local/bin"
  ln -s "$HOME/.local/share/sway-fedora/pipenv/bin/pipenv" "$HOME/.local/bin/pipenv"
fi
export PATH="$HOME/.local/bin:$PATH"
for tool in eza duf zoxide fastfetch fd rg fzf bat btop starship procs lazygit tldr tree-sitter prettier pipenv; do
  command -v "$tool" >/dev/null || { echo "Ferramenta ausente: $tool" >&2; exit 1; }
done
echo '[OK] Ferramentas CLI Fedora instaladas.'
