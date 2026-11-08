import Quickshell
import Quickshell.Io
import QtQuick
Scope {
    id: bridge
    readonly property string base: Quickshell.env("HOME") + "/.config/sway/themes/DarkShadow"
    // A shell redirect may emit truncate and write events for one request.
    // Trigger ignores empty/duplicate contents, so each request toggles once.
    Trigger { name: "settings-open"; onFired: function(line) { settings.running = !settings.running } }
    Trigger { name: "wallpaper-open"; onFired: function(line) { wallpapers.running = !wallpapers.running } }
    Process { id: settings; command: ["qs", "-n", "-p", bridge.base + "/quickshell/rice-settings"] }
    Process { id: wallpapers; command: ["qs", "-n", "-p", bridge.base + "/quickshell/hyprquickpaper"] }
}
