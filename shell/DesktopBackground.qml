import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Config.settings.colors.background
    Image {
        anchors.fill: parent
        source: Config.settings.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        autoTransform: true
    }
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "desktop-background"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}
