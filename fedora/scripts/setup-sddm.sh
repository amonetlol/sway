#!/usr/bin/env bash
set -euo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
backup="/var/backups/sway-fedora/sddm/$(date +%Y%m%d-%H%M%S-%N)"
mkdir -p "$backup" /etc/sddm.conf.d
for path in /etc/sddm.conf.d/90-fedora-sway.conf /usr/local/bin/sddm-fedora-compositor; do
 if [[ -e $path ]]; then cp --parents "$path" "$backup/"; fi
done
install -m755 "$base/scripts/sddm-fedora-compositor" /usr/local/bin/sddm-fedora-compositor
greeter_environment=QT_WAYLAND_SHELL_INTEGRATION=xdg-shell
if [[ $(systemd-detect-virt --vm 2>/dev/null || true) == vmware ]]; then
 greeter_environment+=,QT_QUICK_BACKEND=software,LIBGL_ALWAYS_SOFTWARE=1,GALLIUM_DRIVER=llvmpipe
fi
cat >/etc/sddm.conf.d/90-fedora-sway.conf <<EOF
[General]
DisplayServer=wayland
GreeterEnvironment=$greeter_environment
[Theme]
Current=berserk-sddm-theme
[Users]
RememberLastSession=true
[Wayland]
CompositorCommand=/usr/local/bin/sddm-fedora-compositor
EOF
restorecon /usr/local/bin/sddm-fedora-compositor /etc/sddm.conf.d/90-fedora-sway.conf
