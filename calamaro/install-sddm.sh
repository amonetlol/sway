#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
# O tema calamaroos consulta o estado do Caps Lock via um modulo privado do Plasma.
# O modulo de verdade vem do plasma-workspace; este substituto evita reinstalar o KDE.
sudo install -d /usr/lib64/qt6/qml/org/kde/plasma/private/keyboardindicator
printf '%s\n' 'module org.kde.plasma.private.keyboardindicator' 'KeyState 1.0 KeyState.qml' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/private/keyboardindicator/qmldir >/dev/null
printf '%s\n' 'import QtQuick' 'QtObject {' '    property int key: 0' '    readonly property bool locked: false' '}' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/private/keyboardindicator/KeyState.qml >/dev/null
# Relogio e bateria do tema: tipos pequenos, sem o plasma-workspace.
sudo install -d /usr/lib64/qt6/qml/org/kde/plasma/clock \
  /usr/lib64/qt6/qml/org/kde/plasma/private/battery \
  /usr/lib64/qt6/qml/org/kde/plasma/workspace/components \
  /usr/lib64/qt6/qml/org/kde/plasma/workspace/keyboardlayout
printf '%s\n' 'module org.kde.plasma.clock' 'Clock 1.0 Clock.qml' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/clock/qmldir >/dev/null
sudo tee /usr/lib64/qt6/qml/org/kde/plasma/clock/Clock.qml >/dev/null <<'EOF'
import QtQuick
QtObject {
    id: root
    property bool trackSeconds: false
    property var timeZone: null
    property bool isSystemTimeZone: true
    property string timeZoneCode: ""
    property string timeZoneName: ""
    property string timeZoneOffset: ""
    property bool valid: true
    property date dateTime: new Date()
    Timer {
        interval: root.trackSeconds ? 1000 : 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.dateTime = new Date()
    }
}
EOF
printf '%s\n' 'module org.kde.plasma.private.battery' 'BatteryControlModel 1.0 BatteryControlModel.qml' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/private/battery/qmldir >/dev/null
sudo tee /usr/lib64/qt6/qml/org/kde/plasma/private/battery/BatteryControlModel.qml >/dev/null <<'EOF'
import QtQuick
QtObject {
    property bool hasInternalBatteries: false
    property bool hasCumulative: false
    property bool pluggedIn: false
    property int percent: 0
}
EOF
printf '%s\n' 'module org.kde.plasma.workspace.components' 'BatteryIcon 1.0 BatteryIcon.qml' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/workspace/components/qmldir >/dev/null
sudo tee /usr/lib64/qt6/qml/org/kde/plasma/workspace/components/BatteryIcon.qml >/dev/null <<'EOF'
import QtQuick
Item {
    property bool pluggedIn: false
    property bool hasBattery: false
    property int percent: 0
}
EOF
printf '%s\n' 'module org.kde.plasma.workspace.keyboardlayout' 'singleton KWinVirtualKeyboard 1.0 KWinVirtualKeyboard.qml' | sudo tee /usr/lib64/qt6/qml/org/kde/plasma/workspace/keyboardlayout/qmldir >/dev/null
sudo tee /usr/lib64/qt6/qml/org/kde/plasma/workspace/keyboardlayout/KWinVirtualKeyboard.qml >/dev/null <<'EOF'
pragma Singleton
import QtQuick
QtObject {
    property bool visible: false
    property bool enabled: false
    property bool active: false
}
EOF
# org.kde.breeze.components e QML puro do plasma-workspace (o pacote breeze nao o instala).
if [[ ! -f /usr/lib64/qt6/qml/org/kde/breeze/components/Clock.qml ]]; then
  breeze_work=$(mktemp -d)
  git clone --depth 1 --filter=blob:none --sparse --branch Plasma/6.7 https://github.com/KDE/plasma-workspace.git "$breeze_work/pws"
  git -C "$breeze_work/pws" sparse-checkout set lookandfeel/components
  sudo install -d /usr/lib64/qt6/qml/org/kde/breeze/components/animation
  sudo cp -a "$breeze_work/pws/lookandfeel/components/." /usr/lib64/qt6/qml/org/kde/breeze/components/
  if command -v qsb >/dev/null; then
    for frag in UserDelegate WallpaperFader; do
      qsb --glsl 100es,120,150 --hlsl 50 --msl 12 -o "$breeze_work/$frag.frag.qsb" "/usr/lib64/qt6/qml/org/kde/breeze/components/$frag.frag" \
        && sudo install -m644 "$breeze_work/$frag.frag.qsb" "/usr/lib64/qt6/qml/org/kde/breeze/components/$frag.frag.qsb" \
        || log "Shader opcional nao compilado: $frag"
    done
  fi
  sudo tee /usr/lib64/qt6/qml/org/kde/breeze/components/qmldir >/dev/null <<'EOF'
module org.kde.breeze.components
ActionButton 1.0 ActionButton.qml
Battery 1.0 Battery.qml
Clock 1.0 Clock.qml
SessionManagementScreen 1.0 SessionManagementScreen.qml
UserDelegate 1.0 UserDelegate.qml
UserList 1.0 UserList.qml
VirtualKeyboard 1.0 VirtualKeyboard.qml
VirtualKeyboardLoader 1.0 VirtualKeyboardLoader.qml
WallpaperFader 1.0 WallpaperFader.qml
RejectPasswordAnimation 1.0 animation/RejectPasswordAnimation.qml
RejectPasswordPathAnimation 1.0 animation/RejectPasswordPathAnimation.qml
EOF
  rm -rf "$breeze_work"
fi
# O teclado virtual do tema pede QtQuick.VirtualKeyboard, que nao esta instalado.
sudo tee /usr/lib64/qt6/qml/org/kde/breeze/components/EmptyKeyboard.qml >/dev/null <<'EOF'
import QtQuick
Item {
    property bool active: false
    property bool activated: false
}
EOF
sudo sed -i 's#Qt.resolvedUrl("./VirtualKeyboard.qml")#Qt.resolvedUrl("./EmptyKeyboard.qml")#; s#Qt.resolvedUrl("./VirtualKeyboard_wayland.qml")#Qt.resolvedUrl("./EmptyKeyboard.qml")#' /usr/lib64/qt6/qml/org/kde/breeze/components/VirtualKeyboardLoader.qml
# O tema atual do SDDM (calamaroos) e preservado; apenas a sessao muda.
grep -q '^Current=calamaroos$' /etc/sddm.conf.d/10-session.conf 2>/dev/null || grep -q '^Current=calamaroos$' /etc/sddm.conf 2>/dev/null || log 'AVISO: tema calamaroos nao encontrado na configuracao do SDDM.'
sudo install -d /usr/local/bin /var/backups/sddm-sessions
printf '#!/bin/sh\nexec "$HOME/.local/bin/start-sway-full" "$@"\n' | sudo tee /usr/local/bin/sway-full-session >/dev/null
sudo chmod 755 /usr/local/bin/sway-full-session
cat <<'EOF' | sudo tee /usr/share/wayland-sessions/sway.desktop >/dev/null
[Desktop Entry]
Name=Sway
Comment=Sway com Catppuccin Frappe Blue
Exec=/usr/local/bin/sway-full-session
Type=Application
DesktopNames=sway;wlroots;
EOF
# SDDM e o gerenciador de login; manter somente a entrada Sway.
sudo find /usr/share/wayland-sessions /usr/share/xsessions -mindepth 1 -maxdepth 1 -name '*.desktop' ! -name 'sway.desktop' -exec mv {} /var/backups/sddm-sessions/ \; 2>/dev/null || true
# Sessao padrao do SDDM passa a ser o Sway (inclusive no autologin).
if [[ -f /etc/sddm.conf.d/10-session.conf ]]; then
  sudo sed -i 's/^Session=.*/Session=sway/' /etc/sddm.conf.d/10-session.conf
fi
sudo sed -i 's/^Session=.*/Session=sway/' /etc/sddm.conf
# Garantias: sddm habilitado e boot grafico.
for dm in gdm lightdm lxdm; do sudo systemctl disable "$dm" 2>/dev/null || true; done
sudo systemctl enable sddm
sudo systemctl set-default graphical.target
log 'SDDM habilitado com a unica entrada Sway para o proximo boot; a sessao atual nao foi interrompida.'
