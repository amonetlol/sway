#!/usr/bin/env bash
# GRUB do Ubuntu com o tema bsol (harishnkr/bsol).
# Usa a copia do repo em sway/bsol (ja com o ajuste do menu). Se ela nao
# existir (ex.: execucao via curl), baixa do GitHub e aplica o mesmo ajuste.
# So roda grub-install se a EFI do Ubuntu ainda nao existir; em todos os
# outros casos a EFI (e o Aarambh) nao e alterada.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v
[[ -d /sys/firmware/efi ]] || { echo "GRUB EFI requer UEFI." >&2; exit 1; }

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_theme="$here/../bsol"

efi=/boot/efi
[[ -d $efi ]] || efi=/boot
# /boot/efi/EFI é só de root: o teste precisa de sudo.
# --no-nvram evita mudar a BootOrder (o Aarambh deve continuar primeiro).
if ! sudo test -f "$efi/EFI/ubuntu/grubx64.efi"; then
  sudo grub-install --target=x86_64-efi --efi-directory="$efi" --bootloader-id=ubuntu --no-nvram
fi

ts="$(date +%Y%m%d-%H%M%S)"
sudo cp -a /etc/default/grub "/etc/default/grub.bak-$ts"
sudo cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.bak-$ts"
log "Backup: /etc/default/grub.bak-$ts e /boot/grub/grub.cfg.bak-$ts"

work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT

if [[ -f "$local_theme/theme.txt" ]]; then
  log "Usando tema local: $local_theme"
  theme_src="$local_theme"
else
  command -v git >/dev/null || { echo "git é necessário para baixar o tema." >&2; exit 1; }
  log "Tema local ausente; baixando harishnkr/bsol"
  git clone --depth 1 https://github.com/harishnkr/bsol.git "$work/bsol"
  theme_src="$work/bsol/bsol"
  # Mesmo ajuste do menu: titulo longo precisa de fonte menor e caixa maior.
  sudo sed -i -e '/+ boot_menu {/,/^}/ s/^  left = 17%/  left = 14%/' \
    -e '/+ boot_menu {/,/^}/ s/^  width = 47%/  width = 72%/' \
    -e '/+ boot_menu {/,/^}/ s/item_font =  "Victor Mono Bold Italic 24"/item_font = "Victor Mono Italic 20"/' \
    "$theme_src/theme.txt"
fi

log "Instalando tema em /boot/grub/themes/bsol"
sudo mkdir -p /boot/grub/themes
sudo rm -rf /boot/grub/themes/bsol
sudo cp -r "$theme_src" /boot/grub/themes/bsol

log "Ajustando GRUB_THEME em /etc/default/grub"
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
echo 'GRUB_THEME="/boot/grub/themes/bsol/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null

sudo update-grub
sudo grep -q 'themes/bsol/theme.txt' /boot/grub/grub.cfg || { echo "Tema não aparece no grub.cfg." >&2; exit 1; }
log "GRUB atualizado com o tema bsol."
