#!/bin/sh
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(dirname "$here")
[ -f "$root/sway-full/.config/sway/config" ] || { echo "sway-full ausente" >&2; exit 1; }
sudo pkg install sway swaybg swaylock swayidle waybar wlogout rofi foot sddm xorg-server xf86-video-vmware xf86-input-libinput micro bash sudo seatd dbus polkit pipewire wireplumber xdg-desktop-portal-wlr xdg-desktop-portal-gtk xwayland firefox nautilus btop fastfetch starship git curl grim slurp mako wl-clipboard playerctl open-vm-tools awww cliphist jq python3 pavucontrol adwaita-icon-theme papirus-icon-theme font-awesome fontconfig ImageMagick7 tmux sassc gsed coreutils qt6-5compat unzip eza bat fd-find ripgrep zoxide duf procs tealdeer yt-dlp neofetch
backup="$HOME/.local/state/sway-freebsd/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/bin"
for name in sway waybar wlogout rofi rofi-wallpaper btop gtk-3.0 gtk-4.0; do
  [ -d "$root/sway-full/.config/$name" ] || continue
  if [ -e "$HOME/.config/$name" ]; then mv "$HOME/.config/$name" "$backup/$name"; fi
  cp -R "$root/sway-full/.config/$name" "$HOME/.config/$name"
done
cp -Rn "$root/sway-full/.local/bin/." "$HOME/.local/bin/"
find "$HOME/.local/bin" -type f -exec chmod u+x {} +
chmod u+x "$HOME/.config/wlogout/launch.sh"
python3 "$here/setup.py"
sudo sh "$here/system.sh"
sh "$here/install-modules.sh"
sh "$here/install-themes.sh"
echo 'Configuracao FreeBSD concluida.'
