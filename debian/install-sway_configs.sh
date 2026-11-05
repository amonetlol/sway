#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install-common.sh"
require_root
if [[ $(systemd-detect-virt --vm 2>/dev/null || true) == vmware ]]; then
 mkdir -p /etc/X11/xorg.conf.d
 if [[ -f /etc/X11/xorg.conf.d/20-vmware-modesetting.conf ]]; then cp -a /etc/X11/xorg.conf.d/20-vmware-modesetting.conf "$backup/"; fi
 install -m644 "$base/compat/20-vmware-modesetting.conf" /etc/X11/xorg.conf.d/20-vmware-modesetting.conf
fi
install -m755 "$base/scripts/sway-debian-session" /usr/local/bin/sway-debian-session
cp -a /usr/share/wayland-sessions/sway.desktop "$backup/sway.desktop"
sed -i 's|^Exec=.*|Exec=/usr/local/bin/sway-debian-session|' /usr/share/wayland-sessions/sway.desktop
(cd "$base/assets" && sha256sum -c SHA256SUMS)
python3 "$base/scripts/deploy-config.py" --system --scope sway
for theme in Tela-circle-blue Tela-circle-blue-dark; do
 gtk-update-icon-cache -f "/usr/share/icons/$theme"
done
stage_installer
runuser -u "$target" -- env HOME="$target_home" bash "$stage/scripts/setup-sway-user.sh"
cp -a /etc/default/grub "$backup/grub"
mkdir -p /etc/sddm.conf.d /var/lib/sddm /etc/default/grub.d
for path in /etc/sddm.conf.d/20-debian-sway.conf /var/lib/sddm/state.conf /etc/default/grub.d/90-sway-leaf.cfg; do
 if [[ -f $path ]]; then cp --parents "$path" "$backup/"; fi
done
cat >/etc/sddm.conf.d/20-debian-sway.conf <<'EOF'
[General]
DisplayServer=x11
[Theme]
Current=berserk-sddm-theme
[Users]
RememberLastSession=true
EOF
printf '[Last]\nSession=/usr/share/wayland-sessions/sway.desktop\nUser=%s\n' "$target" >/var/lib/sddm/state.conf
chown sddm:sddm /var/lib/sddm/state.conf
if [[ -d /boot/grub/themes/leaf ]]; then mv /boot/grub/themes/leaf "$backup/leaf"; fi
mkdir -p /boot/grub/themes
cp -a "$base/assets/grub/leaf" /boot/grub/themes/leaf
cat >/etc/default/grub.d/90-sway-leaf.cfg <<'EOF'
GRUB_THEME="/boot/grub/themes/leaf/theme.txt"
GRUB_GFXMODE="1920x1080,auto"
GRUB_TIMEOUT_STYLE=menu
GRUB_TIMEOUT=5
GRUB_TERMINAL_OUTPUT=gfxterm
EOF
update-grub
systemctl enable sddm bluetooth
systemctl set-default graphical.target
echo "Instalação concluída para $target. Faça login na sessão Sway. Backups: $backup"
