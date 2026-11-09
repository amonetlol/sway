#!/usr/bin/env bash
# GRUB já vem do configuration.nix. Este passo coloca o menu visual Aarambh
# (tema picker-wheel) na partição EFI e aponta a entrada NixOS.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }
command -v git >/dev/null
[[ -d /sys/firmware/efi ]] || fail "Aarambh precisa de UEFI."
for cmd in gcc ld objcopy make; do command -v "$cmd" >/dev/null || fail "Falta $cmd. Rode install-system.sh antes."; done
inc="$(find /run/current-system/sw -path '*/include/efi/efi.h' -printf '%h\n' -quit 2>/dev/null || true)"
libdir="$(find /run/current-system/sw -name 'crt0-efi-x86_64.o' -printf '%h\n' -quit 2>/dev/null || true)"
[[ -n $inc && -n $libdir ]] || fail "gnu-efi não está no sistema. Rode install-system.sh."
lds="$(find "$libdir" -name 'elf_x86_64_efi.lds' -print -quit)"
[[ -n $lds ]] || fail "Não achei elf_x86_64_efi.lds."

work="$(mktemp -d)"
trap 'rm -rf -- "$work"' EXIT
git clone --depth 1 https://github.com/NarkAgni/aarambh.git "$work/aarambh"
make -C "$work/aarambh" EFI_INC="$inc" CRT0="$libdir/crt0-efi-x86_64.o" LDS="$lds" LIBDIR="$libdir"
[[ -f $work/aarambh/build/aarambh.efi ]] || fail "A compilação não gerou aarambh.efi."

loader='\EFI\nixos\grubx64.efi'
if [[ ! -f /boot/EFI/nixos/grubx64.efi && -f /boot/EFI/NixOS-boot/grubx64.efi ]]; then
  loader='\EFI\NixOS-boot\grubx64.efi'
fi
sudo mkdir -p /boot/EFI/aarambh
sudo cp "$work/aarambh/build/aarambh.efi" /boot/EFI/aarambh/aarambh.efi
sudo cp "$work/aarambh/assets/distros.conf" /boot/EFI/aarambh/distros.conf
sudo rm -rf /boot/EFI/aarambh/fonts /boot/EFI/aarambh/logos /boot/EFI/aarambh/backgrounds
sudo cp -r "$work/aarambh/assets/fonts" /boot/EFI/aarambh/fonts
sudo cp -r "$work/aarambh/assets/logos" /boot/EFI/aarambh/logos
sudo cp -r "$work/aarambh/assets/backgrounds" /boot/EFI/aarambh/backgrounds
sudo tee /boot/EFI/aarambh/aarambh.conf >/dev/null <<EOF
theme picker-wheel
timeout 10
default nixos
autodetect yes
edit yes

font_light fonts/light.ttf
font_regular fonts/regular.ttf
font_bold fonts/bold.ttf
font_mono fonts/mono.ttf

entry NixOS | $loader | logos/nixos.png | backgrounds/nixos.jpg | nixos | #7ebae4
entry Firmware  | @firmware | logos/settings.png | backgrounds/settings.jpg |  | #8a90a8
entry Restart   | @reboot   | logos/restart.png  | backgrounds/restart.jpg  |  | #2a9d8f
entry Power Off | @shutdown | logos/power.png    | backgrounds/power.jpg    |  | #c0392b
EOF
if ! sudo efibootmgr | grep -q 'Aarambh'; then
  disk="$(lsblk -no PKNAME "$(findmnt -no SOURCE /boot)")"
  part="$(cat /sys/class/block/"$(basename "$(findmnt -no SOURCE /boot)")"/partition)"
  sudo efibootmgr -q -c -d "/dev/$disk" -p "$part" -L Aarambh -l '\EFI\aarambh\aarambh.efi'
fi
log "Aarambh instalado com o tema picker-wheel e o logo NixOS."
