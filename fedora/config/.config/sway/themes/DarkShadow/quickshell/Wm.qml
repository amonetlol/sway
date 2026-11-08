pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
Singleton {
 id: wm
 readonly property bool niri: false
 readonly property bool hypr: false
 readonly property string name: "Sway"
 property var state: ({workspaces: [], focusedId: 1, focusedOutput: "", focusedWindow: null})
 property int tick: 0
 readonly property bool overview: false
 readonly property string focusedOutput: state.focusedOutput || ""
 readonly property int focusedId: state.focusedId || 1
 readonly property var focusedWindow: state.focusedWindow || null
 readonly property string activeTitle: focusedWindow ? focusedWindow.title : ""
 readonly property string activeApp: focusedWindow ? focusedWindow.appId : ""
 function occupied(n) { return state.workspaces.some(w => w.num === n && w.count > 0) }
 function maxWs(min) { return state.workspaces.reduce((m,w) => w.num > 0 && w.num <= 20 ? Math.max(m,w.num) : m, min || 1) }
 function goWs(n) { Quickshell.execDetached([Quickshell.env("HOME") + "/.config/sway/themes/DarkShadow/runtime/bin/rice-wm", "workspace", String(n)]) }
 Process {
  id: stream
  running: true
  command: [Quickshell.env("HOME") + "/.config/sway/themes/DarkShadow/runtime/bin/rice-wm", "watch"]
  stdout: SplitParser { onRead: function(line) { try { wm.state = JSON.parse(line); wm.tick++ } catch(e) {} } }
  onExited: retry.restart()
 }
 Timer { id: retry; interval: 1500; onTriggered: stream.running = true }
}
