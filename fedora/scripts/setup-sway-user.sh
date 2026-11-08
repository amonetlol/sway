#!/usr/bin/env bash
set -euo pipefail
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
python3 "$base/scripts/deploy-config.py" --scope sway
qt_version=$(pkg-config --modversion Qt6Core)
if [[ $(printf '%s\n' 6.9 "$qt_version" | sort -V | head -1) == 6.9 ]]; then
 ln -sfn themes/DarkShadow "$HOME/.config/sway/current"
else
 cp "$base/compat/Shadow-qt68.qml" "$HOME/.config/sway/themes/2SSk/quickshell/widgets/Shadow.qml"
fi
mkdir -p "$HOME/.local/state/sway-themes" "$HOME/.config/systemd/user/timers.target.wants"
ln -sfn ../random-wallpaper.timer "$HOME/.config/systemd/user/timers.target.wants/random-wallpaper.timer"
export XDG_RUNTIME_DIR="/run/user/$(id -u)" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
if [[ -S "$XDG_RUNTIME_DIR/bus" ]]; then
 systemctl --user daemon-reload
 systemctl --user enable --now random-wallpaper.timer
fi
