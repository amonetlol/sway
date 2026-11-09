#!/bin/sh
set -eu
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(dirname "$here")
[ -f "$root/sway-full/.config/sway/config" ] || { echo 'sway-full ausente' >&2; exit 1; }
doas apk add sway swaybg swayidle swaylock waybar rofi foot sddm sddm-openrc wlogout pipewire pipewire-pulse wireplumber xdg-desktop-portal-wlr xdg-desktop-portal-gtk xwayland micro bash dbus dbus-openrc elogind elogind-openrc polkit-elogind polkit-gnome open-vm-tools open-vm-tools-openrc mesa-dri-gallium firefox nautilus pavucontrol grim slurp playerctl wl-clipboard mako jq python3 font-dejavu font-noto-emoji adwaita-icon-theme xorg-server xinit
doas apk add awww btop fastfetch starship git curl pipewire-tools brightnessctl gnome-keyring font-nerd-fonts-symbols sassc papirus-icon-theme imagemagick tmux
doas apk add wget zip 7zip rsync nano bash-completion less zoxide eza fd ripgrep fzf htop tree bat bc coreutils findutils xdg-utils libnotify xauth xclip networkmanager-cli clipman lazygit procs loupe papers pipewire-alsa alsa-utils xdg-user-dirs
backup="$HOME/.local/state/sway-alpine/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" "$HOME/.config" "$HOME/.local/bin"
for name in sway waybar wlogout rofi rofi-wallpaper btop gtk-3.0 gtk-4.0; do
  [ -d "$root/sway-full/.config/$name" ] || continue
  if [ -e "$HOME/.config/$name" ]; then mv "$HOME/.config/$name" "$backup/$name"; fi
  cp -a "$root/sway-full/.config/$name" "$HOME/.config/$name"
done
python3 "$here/restore.py" "$root/sway-full/.local/bin"
find "$HOME/.local/bin" -type f -exec chmod u+x {} +
chmod u+x "$HOME/.config/wlogout/launch.sh"
chmod u+x "$HOME/.config/rofi-wallpaper/launch.sh"
python3 "$here/setup.py"
doas sh "$here/system.sh"
doas sh "$here/sddm.sh"
sh "$here/install-modules.sh"
bash "$here/install-themes.sh"
echo 'Instalação Alpine concluída.'
