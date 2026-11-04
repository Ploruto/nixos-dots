import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: window
    visible: ShellState.osdText !== "" || (ShellState.popup !== null && !ShellState.doNotDisturb)
    anchors { top: true; right: true }
    margins.top: (Config.settings.bar.position === "top" ? Config.settings.geometry.barHeight : 0) + Config.settings.geometry.padding
    margins.right: Config.settings.geometry.padding
    implicitWidth: Math.min(Config.settings.geometry.notificationWidth, screen ? screen.width : Config.settings.geometry.notificationWidth)
    implicitHeight: content.implicitHeight + Config.settings.geometry.padding * 2
    exclusionMode: ExclusionMode.Ignore
    color: Config.settings.colors.surface
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "desktop-notification"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Config.settings.geometry.padding
        spacing: Config.settings.geometry.spacing
        ShellLabel {
            Layout.fillWidth: true
            text: ShellState.osdText || (ShellState.popup ? ShellState.popup.summary : "")
            font.pointSize: Config.settings.fonts.sizes.notification
            color: Config.settings.colors.accent
            wrapMode: Text.Wrap
        }
        ShellLabel {
            Layout.fillWidth: true
            visible: ShellState.osdText === "" && ShellState.popup !== null
            text: ShellState.popup ? ShellState.popup.body : ""
            font.pointSize: Config.settings.fonts.sizes.notification
            wrapMode: Text.Wrap
            maximumLineCount: 5
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: { ShellState.popup = null; ShellState.toggle("notifications"); }
    }
}
