#!/usr/bin/env bash
set -euo pipefail
root="$HOME/.config/sway"
exec >> "$HOME/.local/state/sway-themes/session.log" 2>&1
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export PATH="$HOME/.local/bin:$HOME/.bin:/usr/local/sbin:/usr/local/bin:/usr/bin"
export QT_QPA_PLATFORM='wayland;xcb' QT_QPA_PLATFORMTHEME=qt6ct MOZ_ENABLE_WAYLAND=1
export TERMINAL=kitty EDITOR=nvim
dbus-update-activation-environment --systemd LANG LANGUAGE WAYLAND_DISPLAY DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE PATH QT_QPA_PLATFORM QT_QPA_PLATFORMTHEME TERMINAL EDITOR
if systemctl --user is-active --quiet sway-themed-session.target; then exit 0; fi
# Fedora portals require this target before their activation.
systemctl --user start sway-session.target
# Start portals with the new compositor environment before the GTK panels.
systemctl --user stop xdg-desktop-portal.service xdg-desktop-portal-gtk.service
systemctl --user reset-failed xdg-desktop-portal.service xdg-desktop-portal-gtk.service 2>/dev/null || true
systemctl --user start xdg-desktop-portal-gtk.service
systemctl --user start xdg-desktop-portal.service
"$root/scripts/set_theme.sh" --save-session
name=$(basename "$(readlink -f "$root/current")")
systemctl --user stop hypr-themed-quickshell.service hypr-themed-waybar.service hypr-themed-notifications.service 2>/dev/null || true
"$root/scripts/set_theme.sh" "$name"
# Replace a previous session's notification owner only after entering Sway.
systemctl --user stop dunst.service xdg-desktop-portal-hyprland.service 2>/dev/null || true
pkill -u "$(id -u)" -x dunst 2>/dev/null || true
systemctl --user start sway-themed-session.target
systemctl --user start xdg-desktop-portal.service
if ! grep -qx 'BACKEND=quickshell' "$root/current/theme.conf"; then
 "$HOME/.local/bin/sway-polkit-agent" &
fi
# Reuse the existing 90-second wallpaper timer; do not create a theme wallpaper.
systemctl --user start random-wallpaper.service
if command -v vmware-user-suid-wrapper >/dev/null; then vmware-user-suid-wrapper >/dev/null 2>&1 & fi
