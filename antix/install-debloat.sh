#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
sudo -n true
targets=(
  foot icewm fluxbox jwm herbstluftwm slimski
)
installed=()
for package in "${targets[@]}"; do
  status=$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)
  case "$status" in installed|config-files) installed+=("$package");; esac
done
if ((${#installed[@]})); then
  plan=$(mktemp)
  trap 'rm -f -- "$plan"' EXIT
  sudo apt-get -s --solver=internal --no-install-recommends purge "${installed[@]}" > "$plan"
  if grep -q '^Inst ' "$plan" ||
     grep -Eq '^(Remv|Purg) (sway|sddm|nautilus|gnome-keyring|pipewire|elogind|connman|firefox)(:[^ ]+)? ' "$plan"; then
    cat "$plan"
    echo "Plano de remoção altera componentes preservados do rice." >&2
    exit 1
  fi
  sudo apt-get -y --solver=internal --no-install-recommends purge "${installed[@]}"
  echo "[OK] Removidos: ${installed[*]}"
else
  echo "[OK] Nada do desktop anterior para remover."
fi
echo "[*] Nautilus, chaveiro, connman e o GRUB do antiX preservados. Sem autoremove geral."
