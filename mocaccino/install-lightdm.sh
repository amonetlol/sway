#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo 'Execute como usuario comum com sudo.' >&2; exit 1; }
theme="$HOME/.themes/Colloid-Dark-Catppuccin"
[[ -f "$theme/gtk-3.0/gtk.css" ]] || { echo 'Tema Colloid Catppuccin nao encontrado em ~/.themes.' >&2; exit 1; }
command -v lightdm >/dev/null
command -v lightdm-gtk-greeter >/dev/null
[[ -f /usr/share/wayland-sessions/sway.desktop ]]
sudo install -d /usr/share/themes/Colloid-Dark-Catppuccin /etc/lightdm/lightdm.conf.d /usr/local/share/wayland-sessions /usr/local/bin
cat <<'WRAPPER' | sudo tee /usr/local/bin/sway-mocaccino >/dev/null
#!/bin/sh
exec "$HOME/.local/bin/start-sway-full" "$@"
WRAPPER
sudo chmod 755 /usr/local/bin/sway-mocaccino
cat <<'SESSION' | sudo tee /usr/local/share/wayland-sessions/sway.desktop >/dev/null
[Desktop Entry]
Name=Sway
Comment=Sway no MocaccinoOS
Exec=/usr/local/bin/sway-mocaccino
Type=Application
DesktopNames=sway;wlroots;
X-LightDM-Session-Type=wayland
SESSION
sudo cp -a "$theme/." /usr/share/themes/Colloid-Dark-Catppuccin/
cat <<'CFG' | sudo tee /etc/lightdm/lightdm.conf.d/90-sway.conf >/dev/null
[LightDM]
sessions-directory=/usr/local/share/wayland-sessions

[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=sway
allow-guest=false
CFG
if sudo test -f /etc/lightdm/lightdm-gtk-greeter.conf; then
  sudo cp -an /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.before-sway
fi
cat <<'CFG' | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf >/dev/null
[greeter]
background=#303446
theme-name=Colloid-Dark-Catppuccin
font-name=Sans 11
clock-format=%H:%M
position=50%,center 50%,center
CFG
if systemctl cat gdm.service >/dev/null 2>&1; then sudo systemctl disable gdm.service; fi
sudo systemctl enable --force lightdm.service
sudo systemctl set-default graphical.target
printf '%s\n' 'LightDM configurado para o proximo boot; a sessao atual permanece ativa.'
