#!/usr/bin/env bash
set -euo pipefail
RICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$RICE_ROOT/scripts/common.sh" ]]; then source "$RICE_ROOT/scripts/common.sh"; else
  helper="$(mktemp)"; curl -fLsS https://raw.githubusercontent.com/amonetlol/sway/main/sway-full/scripts/common.sh -o "$helper"; source "$helper"; rm -f "$helper"
fi
require_user
names=(bash bin btop fastfetch fonts starship nvim vmware random-wallpapers hide-shortcuts recovery-shortcuts kitty wallpapers snapper)
paths=(bash.sh bin.sh btop.sh fastfetch.sh fonts.sh starship.sh setup-nvim.sh VMware/vmware.sh random-wallpapers.sh hide-shortcuts.sh recovery-shortcuts.sh kitty.sh wallpapers.sh '')
selected=(); for _ in "${names[@]}"; do selected+=(1); done
if [[ ${1:-} != --all ]]; then
  [[ -r /dev/tty ]] || fail 'A selecao requer um terminal. Use --all para confirmar todos sem o menu.'
  while true; do
    printf '\nModulos — todos selecionados inicialmente:\n'
    for i in "${!names[@]}"; do
      mark=' '; [[ ${selected[i]} == 0 ]] || mark=X
      printf ' [%s] %2d. %s\n' "$mark" "$((i+1))" "${names[i]}"
    done
    printf '\nNumeros para marcar/desmarcar (ex.: 2,8); t=todos; n=nenhum; Enter=instalar; q=cancelar: '
    read -r answer </dev/tty
    case "$answer" in
      '') break ;;
      q|Q) exit 0 ;;
      t|T) for i in "${!names[@]}"; do selected[i]=1; done ;;
      n|N) for i in "${!names[@]}"; do selected[i]=0; done ;;
      *) for number in ${answer//,/ }; do
          if [[ "$number" =~ ^[0-9]+$ ]] && ((number>=1 && number<=${#names[@]})); then selected[number-1]=$((1-selected[number-1])); else log "Opcao ignorada: $number"; fi
         done ;;
    esac
  done
fi
any_selected=0
for state in "${selected[@]}"; do [[ "$state" == 0 ]] || any_selected=1; done
if [[ "$any_selected" == 0 ]]; then log 'Nenhum modulo selecionado.'; exit 0; fi
resolve_rice
sudo -v
for i in "${!names[@]}"; do
  [[ ${selected[i]} == 1 ]] || continue
  name="${names[i]}"
  log "Instalando modulo atualizado: $name"
  if [[ "$name" == snapper ]]; then
    [[ $(findmnt -no FSTYPE /) == btrfs ]] || { log 'Raiz nao e Btrfs; Snapper ignorado.'; continue; }
    command -v snapper >/dev/null || fail 'Instale primeiro os pacotes do Snapper com install-pacotes.sh.'
    if ! sudo snapper -c root get-config >/dev/null 2>&1; then sudo snapper -c root create-config /; fi
    download https://raw.githubusercontent.com/amonetlol/vm_rice/main/scripts/lib/snapper.sh "$RICE_WORK/snapper.sh"
    run_as_root() { sudo "$@"; }; warn() { log "$@"; }; ok() { log "$@"; }
    source "$RICE_WORK/snapper.sh"
    configure_snapper_limits 6
    sudo sed -i 's/^TIMELINE_CREATE=.*/TIMELINE_CREATE="no"/' /etc/snapper/configs/root
    sudo systemctl enable --now snapper-cleanup.timer
    if [[ -f /etc/default/grub-btrfs/config ]]; then
      sudo cp -a /etc/default/grub-btrfs/config "/etc/default/grub-btrfs/config.bak-$(date +%s)"
      if grep -q '^GRUB_BTRFS_LIMIT=' /etc/default/grub-btrfs/config; then sudo sed -i 's/^GRUB_BTRFS_LIMIT=.*/GRUB_BTRFS_LIMIT="6"/' /etc/default/grub-btrfs/config; else printf '\nGRUB_BTRFS_LIMIT="6"\n' | sudo tee -a /etc/default/grub-btrfs/config >/dev/null; fi
      sudo systemctl enable --now grub-btrfsd.service
      [[ ! -f /boot/grub/grub.cfg ]] || sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    continue
  fi
  script="$RICE_WORK/$name.sh"
  download "https://raw.githubusercontent.com/amonetlol/sh/main/modules/${paths[i]}" "$script"
  if [[ "$name" == hide-shortcuts ]]; then
    # Manter as atualizacoes upstream, omitindo exclusivamente o bloco que renomeia Thunar.
    python3 - "$script" <<'PY'
from pathlib import Path
import sys
p=Path(sys.argv[1]);s=p.read_text();start=s.find('log "Renomeando Thunar"');end=s.find('log "Atualizando cache de atalhos"',start)
if start < 0 or end < start: raise SystemExit('hide-shortcuts mudou: revise o bloco de renomeacao do Thunar antes de executar.')
p.write_text(s[:start]+s[end:])
PY
  fi
  bash "$script"
  if [[ "$name" == random-wallpapers ]]; then
    # Parar o timer generico de 5 min e aplicar as units Sway da VM (90s).
    install_wallpaper_units
  fi
done
log 'Modulos selecionados concluidos. Fontes dos modulos foram baixadas do GitHub nesta execucao.'
