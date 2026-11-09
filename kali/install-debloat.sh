#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
sudo -v
targets=(
  foot malcontent malcontent-gui im-config
  gdm3 gnome-session gnome-session-bin gnome-session-common
  gnome-shell gnome-shell-common gnome-control-center gnome-control-center-data
  gnome-settings-daemon gnome-settings-daemon-common xdg-desktop-portal-gnome
  gnome-remote-desktop gnome-user-docs gnome-browser-connector gnome-user-share
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
     grep -Eq '^(Remv|Purg) (sway|sddm|nautilus|gnome-keyring|network-manager|pipewire|kali-defaults)(:[^ ]+)? ' "$plan"; then
    cat "$plan"
    echo "Plano de remoção altera componentes preservados do rice." >&2
    exit 1
  fi
  sudo apt-get -y --solver=internal --no-install-recommends purge "${installed[@]}"
  echo "[OK] Removidos: ${installed[*]}"
else
  echo "[OK] Nada do desktop anterior para remover."
fi
echo "[*] Nautilus, chaveiro, rede e o GRUB do Kali preservados. Sem autoremove geral."
