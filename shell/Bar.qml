import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower

PanelWindow {
    id: bar
    anchors {
        top: Config.settings.bar.position === "top"
        bottom: Config.settings.bar.position === "bottom"
        left: true
        right: true
    }
    readonly property var workspaceIds: {
        const occupied = Hyprland.workspaces.values.filter(w => w.id > 0).map(w => w.id);
        return [...new Set([...Config.settings.bar.persistentWorkspaces, ...occupied])].sort((a, b) => a - b);
    }
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isPresent
    readonly property real batteryLevel: hasBattery ? Math.max(0, Math.min(1, battery.percentage)) : 0
    readonly property bool charging: hasBattery && battery.state === UPowerDeviceState.Charging
    readonly property color batteryColor: charging ? Config.settings.colors.success
        : UPower.onBattery && batteryLevel < 0.2 ? Config.settings.colors.warning
        : Config.settings.colors.muted
    implicitHeight: Config.settings.geometry.barHeight
    color: Config.settings.colors.panel
    WlrLayershell.namespace: "desktop-bar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    SystemClock { id: clock; precision: SystemClock.Minutes }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Config.settings.geometry.padding
        anchors.rightMargin: Config.settings.geometry.padding
        spacing: Config.settings.geometry.spacing
        Repeater {
            model: bar.workspaceIds
            delegate: Rectangle {
                id: workspaceButton
                required property var modelData
                readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === modelData) || null
                readonly property bool active: workspace !== null && workspace.active
                implicitWidth: Math.max(32, workspaceLabel.implicitWidth + 16)
                Layout.fillHeight: true
                color: active ? Config.settings.colors.surface
                    : workspaceMouse.containsMouse ? Config.settings.colors.selection : "transparent"
                ShellLabel {
                    id: workspaceLabel
                    anchors.centerIn: parent
                    text: workspaceButton.workspace ? workspaceButton.workspace.name : String(modelData)
                    color: workspaceButton.active ? Config.settings.colors.accent
                        : workspaceButton.workspace ? Config.settings.colors.text : Config.settings.colors.muted
                    font.family: Config.settings.fonts.barFamily
                    font.pointSize: Config.settings.fonts.sizes.bar
                    font.weight: Font.DemiBold
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                    height: 2
                    visible: workspaceButton.active
                    color: Config.settings.colors.accent
                }
                MouseArea {
                    id: workspaceMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({workspace=" + modelData + "})"])
                }
            }
        }
        Item { Layout.fillWidth: true }
        RowLayout {
            visible: bar.hasBattery
            spacing: 8
            Item {
                implicitWidth: 24
                implicitHeight: 14
                Rectangle {
                    width: 21; height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 2
                    color: "transparent"
                    border.width: 1
                    border.color: bar.batteryColor
                    Rectangle {
                        x: 3; y: 3
                        width: 15 * bar.batteryLevel
                        height: 6
                        radius: 1
                        color: bar.batteryColor
                    }
                }
                Rectangle {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    width: 2; height: 4
                    radius: 1
                    color: bar.batteryColor
                }
            }
            ShellLabel {
                text: Math.round(bar.batteryLevel * 100) + "%" + (bar.charging ? " +" : "")
                color: bar.batteryColor
                font.family: Config.settings.fonts.barFamily
                font.pointSize: Config.settings.fonts.sizes.bar
                font.weight: Font.Medium
            }
        }
        Rectangle {
            visible: bar.hasBattery
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            implicitWidth: 1
            implicitHeight: 12
            color: Config.settings.colors.border
        }
        Item {
            implicitWidth: dateTimeRow.implicitWidth
            implicitHeight: dateTimeRow.implicitHeight
            RowLayout {
                id: dateTimeRow
                spacing: 12
            ShellLabel {
                text: Qt.formatDateTime(clock.date, "ddd, d MMM")
                color: Config.settings.colors.muted
                font.family: Config.settings.fonts.barFamily
                font.pointSize: Config.settings.fonts.sizes.bar
            }
            ShellLabel {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.family: Config.settings.fonts.barFamily
                font.pointSize: Config.settings.fonts.sizes.bar
                font.weight: Font.DemiBold
            }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ShellState.toggle("session")
            }
        }
    }
}
