#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
theme=catppuccin-frappe-blue
download https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip "$cache/sddm.zip"
rm -rf "$cache/sddm"
mkdir -p "$cache/sddm"
unzip -oq "$cache/sddm.zip" -d "$cache/sddm"
[[ -f $cache/sddm/$theme/Main.qml ]] || fail 'Tema SDDM sem Main.qml.'
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/bin /usr/share/wayland-sessions /etc/X11/xorg.conf.d
printf 'allowed_users=anybody\nneeds_root_rights=yes\n' | sudo tee /etc/X11/Xwrapper.config >/dev/null
if [[ -x /usr/libexec/Xorg ]]; then
  printf '#!/bin/sh\nexec /usr/libexec/Xorg "$@"\n' | sudo tee /usr/bin/Xorg >/dev/null
  sudo chmod 755 /usr/bin/Xorg
fi
sudo cp -a "$cache/sddm/$theme" /usr/share/sddm/themes/
if [[ -f /etc/sddm.conf ]]; then
  sudo sed -i -e "s/^Current=.*/Current=$theme/" -e 's/^InputMethod=.*/InputMethod=/' /etc/sddm.conf
fi
sudo tee /etc/sddm.conf.d/90-sway.conf >/dev/null <<EOF
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=$theme
CursorTheme=Vimix-cursors
CursorSize=24
[Users]
RememberLastSession=true
EOF
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "keyboard-br"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
    Option "XkbModel" "pc105"
EndSection
EOF
sudo tee /usr/local/bin/sway-full-session >/dev/null <<'EOF'
#!/bin/sh
exec "$HOME/.local/bin/start-sway-full" "$@"
EOF
sudo chmod 755 /usr/local/bin/sway-full-session
sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway no Salix
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
sudo mkdir -p /var/lib/sway-salix/disabled-sessions
shopt -s nullglob
for entry in /usr/share/wayland-sessions/*.desktop /usr/share/xsessions/*.desktop; do
  base=$(basename "$entry")
  [[ $base == sway.desktop ]] && continue
  sudo mv "$entry" "/var/lib/sway-salix/disabled-sessions/$base.$(date +%s)"
done
log 'SDDM com uma unica sessao: Sway.'
