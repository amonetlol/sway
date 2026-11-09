#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuario comum, com sudo." >&2; exit 1; }
export LC_ALL=C.UTF-8
# Preserve bibliotecas GTK, Nautilus, keyring e o gerenciador de partida nativo.
command -v sway >/dev/null
command -v sddm >/dev/null
[[ -f /usr/share/wayland-sessions/sway-full.desktop ]]
sudo -v
mapfile -t remove < <(python3 - <<'PY'
from pathlib import Path
import re
apps = {'gdm','gnome-session','gnome-session-shell','gnome-shell',
'gnome-shell-extensions','gnome-control-center','gnome-settings-daemon',
'gnome-tweaks','gnome-software','gnome-calendar','gnome-clocks','gnome-weather',
'gnome-calculator','gnome-system-monitor','gnome-text-editor','gnome-user-docs',
'gnome-remote-desktop','gnome-browser-connector','gnome-color-manager',
'gnome-disk-utility','gnome-app-list','gnome-desktop-branding',
'xdg-desktop-portal-gnome','gparted'}
for path in sorted(Path('/var/lib/eopkg/package').iterdir()):
    name = re.sub(r'-[0-9].*$', '', path.name)
    if name in apps or name.startswith(('libreoffice-', 'thunderbird-', 'gnome-shell-extension-')) or name in {'libreoffice', 'thunderbird'}:
        print(name)
PY
)
((${#remove[@]})) || { echo 'Debloat ja aplicado.'; exit 0; }
plan=$(mktemp)
trap 'rm -f -- "$plan"' EXIT
sudo eopkg remove --dry-run "${remove[@]}" | tee "$plan"
# Recuse uma cascata que alcance componentes usados pelo Sway ou pelo boot.
if grep -Eq '(^|[[:space:],])(clr-boot-manager|grub2|linux-current|linux-lts|sway|sddm|network-manager|pipewire|wireplumber|nautilus|gvfs|gnome-keyring)([[:space:],]|$)' "$plan"; then
  echo 'Remocao cancelada: dependencias protegidas no plano.' >&2
  exit 1
fi
sudo eopkg remove -y "${remove[@]}"
echo 'Debloat Solus concluido; clr-boot-manager preservado.'
