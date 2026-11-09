#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Execute com sudo.' >&2; exit 1; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fL --retry 3 -o "$work/theme.zip" https://github.com/catppuccin/sddm/releases/download/v1.1.2/catppuccin-frappe-blue-sddm.zip
unzip -oq "$work/theme.zip" -d "$work/theme"
[[ -f "$work/theme/catppuccin-frappe-blue/Main.qml" ]]
install -d /usr/local/share/sddm/themes /usr/local/share/sway-sessions /usr/local/share/sway-xsessions /usr/local/bin /etc/sddm.conf.d
if [[ -e /usr/local/share/sddm/themes/catppuccin-frappe-blue ]]; then
  mv /usr/local/share/sddm/themes/catppuccin-frappe-blue "/usr/local/share/sddm/themes/catppuccin-frappe-blue.bak-$(date +%s)"
fi
cp -a "$work/theme/catppuccin-frappe-blue" /usr/local/share/sddm/themes/
tee /usr/local/bin/sway-full-session >/dev/null <<'EOF'
#!/bin/sh
if [ -x "$HOME/.local/bin/start-sway-full" ]; then exec "$HOME/.local/bin/start-sway-full" "$@"; fi
exec /usr/bin/sway "$@"
EOF
chmod 755 /usr/local/bin/sway-full-session
tee /usr/local/share/sway-sessions/sway.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway
Comment=Sway Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
tee /etc/sddm.conf.d/90-sway-silverblue.conf >/dev/null <<'EOF'
[General]
DisplayServer=x11
InputMethod=
[Theme]
ThemeDir=/usr/local/share/sddm/themes
Current=catppuccin-frappe-blue
[Wayland]
SessionDir=/usr/local/share/sway-sessions
[X11]
SessionDir=/usr/local/share/sway-xsessions
[Users]
RememberLastSession=true
EOF
printf '[OK] SDDM configurado; habilite apenas depois de confirmar o pacote no deployment.\n'
