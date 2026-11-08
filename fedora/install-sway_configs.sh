#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install-common.sh"
require_root
install -m755 "$base/scripts/sway-fedora-session" /usr/local/bin/sway-fedora-session
cp -a /usr/share/wayland-sessions/sway.desktop "$backup/sway.desktop"
sed -i 's|^Exec=.*|Exec=/usr/local/bin/sway-fedora-session|' /usr/share/wayland-sessions/sway.desktop
(cd "$base/assets" && sha256sum -c SHA256SUMS)
python3 "$base/scripts/deploy-config.py" --system --scope sway
for theme in Tela-circle-blue Tela-circle-blue-dark; do
 gtk-update-icon-cache -f "/usr/share/icons/$theme"
done
stage_installer
runuser -u "$target" -- env HOME="$target_home" bash "$stage/scripts/setup-sway-user.sh"
mkdir -p /etc/sddm.conf.d /var/lib/sddm
for path in /etc/default/grub /etc/sddm.conf.d/90-fedora-sway.conf /var/lib/sddm/state.conf; do
 if [[ -f $path ]]; then cp --parents "$path" "$backup/"; fi
done
bash "$base/scripts/setup-sddm.sh"
printf '[Last]\nSession=/usr/share/wayland-sessions/sway.desktop\nUser=%s\n' "$target" >/var/lib/sddm/state.conf
chown sddm:sddm /var/lib/sddm/state.conf
if [[ -d /boot/grub2/themes/leaf ]]; then mv /boot/grub2/themes/leaf "$backup/leaf"; fi
mkdir -p /boot/grub2/themes
cp -a "$base/assets/grub/leaf" /boot/grub2/themes/leaf
python3 "$base/scripts/setup-grub.py"
grub2-mkconfig -o /boot/grub2/grub.cfg
restorecon -RF /usr/local/bin /usr/share/sddm/themes /etc/sddm.conf.d /var/lib/sddm "$target_home/.config" "$target_home/.local"
systemctl enable sddm bluetooth
systemctl set-default graphical.target
echo "Instalacao concluida para $target. Faca novo login Sway. Backups: $backup"
