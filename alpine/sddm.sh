#!/bin/sh
set -eu
apk add xf86-input-libinput qt6-qt5compat qt6-qtsvg unzip curl
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fLsS --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
theme=catppuccin-frappe-blue
test -f "$work/theme/$theme/Main.qml"
mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /etc/X11/xorg.conf.d
if [ -e "/usr/share/sddm/themes/$theme" ]; then
  mv "/usr/share/sddm/themes/$theme" "/usr/share/sddm/themes/$theme.backup-$(date +%Y%m%d-%H%M%S)"
fi
cp -a "$work/theme/$theme" /usr/share/sddm/themes/
cat > /etc/sddm.conf.d/90-sway.conf <<'EOF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
Current=catppuccin-frappe-blue
CursorTheme=Vimix-cursors
CursorSize=24
[Users]
RememberLastSession=true
EOF
cat > /etc/X11/xorg.conf.d/00-keyboard.conf <<'EOF'
Section "InputClass"
    Identifier "keyboard-br"
    MatchIsKeyboard "on"
    Option "XkbLayout" "br"
    Option "XkbVariant" "abnt2"
    Option "XkbModel" "pc105"
EndSection
EOF
