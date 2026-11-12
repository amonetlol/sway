#!/usr/bin/env bash
# GRUB do Fedora com o tema bsol (harishnkr/bsol).
# Usa a copia do repo em sway/bsol (ja com o ajuste do menu). Se ela nao
# existir (ex.: execucao via curl), baixa do GitHub e aplica o mesmo ajuste.
# Cuidado: NAO executa grub2-install nem altera a EFI. O Aarambh chama
# \EFI\fedora\grubx64.efi, que carrega /boot/grub2/grub.cfg; por isso
# so o tema, /etc/default/grub e o grub.cfg sao alterados aqui.
# GRUB_ENABLE_BLSCFG permanece true para não mudar a forma como os kernels aparecem.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -v

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
local_theme="$here/../bsol"

[[ -d /sys/firmware/efi ]] || { echo "Sistema não está em UEFI." >&2; exit 1; }

ts="$(date +%Y%m%d-%H%M%S)"
sudo cp -a /etc/default/grub "/etc/default/grub.bak-$ts"
sudo cp -a /boot/grub2/grub.cfg "/boot/grub2/grub.cfg.bak-$ts"
log "Backup: /etc/default/grub.bak-$ts e /boot/grub2/grub.cfg.bak-$ts"

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
  # Mesmo ajuste do menu: titulo longo do Fedora precisa de fonte menor e caixa maior.
  sudo sed -i -e '/+ boot_menu {/,/^}/ s/^  left = 17%/  left = 14%/' \
    -e '/+ boot_menu {/,/^}/ s/^  width = 47%/  width = 72%/' \
    -e '/+ boot_menu {/,/^}/ s/item_font =  "Victor Mono Bold Italic 24"/item_font = "Victor Mono Italic 20"/' \
    "$theme_src/theme.txt"
fi

log "Instalando tema em /boot/grub2/themes/bsol"
sudo mkdir -p /boot/grub2/themes
sudo rm -rf /boot/grub2/themes/bsol
sudo cp -r "$theme_src" /boot/grub2/themes/bsol

log "Ajustando GRUB_THEME em /etc/default/grub"
sudo sed -i '/^GRUB_THEME=/d' /etc/default/grub
echo 'GRUB_THEME="/boot/grub2/themes/bsol/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null

log "Gerando /boot/grub2/grub.cfg"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grep -q 'themes/bsol/theme.txt' /boot/grub2/grub.cfg || { echo "Tema não aparece no grub.cfg." >&2; exit 1; }

log "GRUB com tema bsol aplicado. A entrada Aarambh/EFI não foi alterada."
