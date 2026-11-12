#!/usr/bin/env bash
set -euo pipefail
base=$(cd "$(dirname "$0")" && pwd)
repo=$(dirname "$base")
profile=${1:-kana}
case "$profile" in kana|besita|pie|grey) ;; *) echo "Perfil inv?lido: $profile" >&2; exit 2;; esac
[ -d "$repo/sway-full/.config/kitty" ] || { echo 'sway-full n?o encontrado' >&2; exit 1; }
backup="$HOME/.local/state/niri-two-backup-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
for name in niri waybar kitty rofi rofi-wallpaper; do
 if [ -e "$HOME/.config/$name" ] || [ -L "$HOME/.config/$name" ]; then mkdir -p "$backup"; mv "$HOME/.config/$name" "$backup/$name"; fi
done
cp -a "$base/common/niri" "$HOME/.config/niri"
cp -a "$base/profiles/$profile/waybar" "$HOME/.config/waybar"
for name in kitty rofi rofi-wallpaper; do cp -a "$repo/sway-full/.config/$name" "$HOME/.config/$name"; done
[ ! -f "$base/profiles/$profile/kitty-theme.conf" ] || cp "$base/profiles/$profile/kitty-theme.conf" "$HOME/.config/kitty/current-theme.conf"
[ ! -f "$base/profiles/$profile/rofi-colors.rasi" ] || cp "$base/profiles/$profile/rofi-colors.rasi" "$HOME/.config/rofi/colors.rasi"
for name in niri-rofi-power niri-wallpaper-daemon niri-auth-agent; do install -m 0755 "$base/common/bin/$name" "$HOME/.local/bin/$name"; done
for name in rofi-wallpaper mon; do install -m 0755 "$repo/sway-full/.local/bin/$name" "$HOME/.local/bin/$name"; done
# Arquivos copiados de um checkout Windows precisam de finais de linha Unix.
for name in niri-rofi-power niri-wallpaper-daemon niri-auth-agent rofi-wallpaper mon; do sed -i "s/\r$//" "$HOME/.local/bin/$name"; done
chmod +x "$HOME/.config/waybar/scripts/recording-status.sh" 2>/dev/null || true
chmod +x "$HOME/.config/rofi-wallpaper/launch.sh" "$HOME/.config/waybar/clock-ptbr.py" 2>/dev/null || true
# Aplica o perfil GTK e preserva a configura??o anterior.
mkdir -p "$HOME/.config/gtk-3.0"
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then mkdir -p "$backup/gtk-3.0"; cp -a "$HOME/.config/gtk-3.0/settings.ini" "$backup/gtk-3.0/"; fi
cp "$base/profiles/$profile/gtk-settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
niri validate -c "$HOME/.config/niri/config.kdl"
echo "Niri configurado com perfil $profile. Backup: $backup"
