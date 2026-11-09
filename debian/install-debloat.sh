#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuario comum, com sudo." >&2; exit 1; }
sudo -v
targets=(
  firefox-esr foot malcontent malcontent-gui im-config
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
  # O solver padrao do Sid tentou instalar Cinnamon ao remover o GNOME.
  sudo apt-get -s --solver=internal --no-install-recommends purge "${installed[@]}" > "$plan"
  if grep -q '^Inst ' "$plan" ||
     grep -Eq '^(Remv|Purg) (sway|sddm|nautilus|gnome-keyring|network-manager|pipewire)(:[^ ]+)? ' "$plan"; then
    cat "$plan"
    echo "Plano de remocao altera componentes preservados do rice." >&2
    exit 1
  fi
  sudo apt-get -y --solver=internal --no-install-recommends purge "${installed[@]}"
fi
echo "[OK] GNOME desktop, Firefox ESR, foot, controle parental e im-config removidos."
echo "[*] Nautilus, chaveiro, IBus e dependencias GTK preservados. Sem autoremove geral."
