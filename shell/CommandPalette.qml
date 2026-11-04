import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: panel
    required property var targetScreen
    screen: targetScreen
    visible: ShellState.mode !== "" && ShellState.activeScreen === targetScreen
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "desktop-palette"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    property var pending: null
    readonly property var entries: {
        const mode = ShellState.mode;
        const needle = search.text.trim().toLowerCase();
        let list;
        if (mode === "notifications") {
            list = ShellState.notifications.slice().reverse().map(n => ({
                name: n.summary, detail: n.appName + (n.body ? ": " + n.body : ""), notification: n
            }));
        } else if (mode === "clipboard") list = ShellState.clipboardEntries;
        else {
            list = ShellState.actions();
            if (mode === "session") list = list.filter(a => a.id.startsWith("session."));
            if (mode === "controls") list = list.filter(a => /^(audio|brightness|network|bluetooth|media|shell\.do-not-disturb)\./.test(a.id) || a.id === "shell.do-not-disturb");
            if (mode === "launcher") list = DesktopEntries.applications.values.map(e => ({ name: e.name, detail: e.genericName || "Application", entry: e })).concat(list);
        }
        return list.filter(a => (a.name + " " + a.detail + " " + (a.id || "")).toLowerCase().includes(needle));
    }
    function activate() {
        if (pending) { const action = pending; pending = null; ShellState.execute(action); return; }
        const action = entries[results.currentIndex];
        if (!action) return;
        if (action.confirm) pending = action;
        else ShellState.execute(action);
    }
    onVisibleChanged: {
        if (visible) {
            search.text = "";
            pending = null;
            results.currentIndex = 0;
            search.forceActiveFocus();
        }
    }
    Connections {
        target: ShellState
        function onModeChanged() { search.text = ""; panel.pending = null; results.currentIndex = 0; }
    }
    MouseArea { anchors.fill: parent; onClicked: ShellState.close() }
    Rectangle {
        id: body
        width: Math.min(Config.settings.geometry.panelWidth, parent.width - Config.settings.geometry.padding * 2)
        height: Math.min(Config.settings.geometry.panelHeight, parent.height - Config.settings.geometry.barHeight - Config.settings.geometry.padding * 2)
        anchors.horizontalCenter: parent.horizontalCenter
        y: Config.settings.geometry.barHeight + Config.settings.geometry.padding
        color: Config.settings.colors.panel
        radius: Config.settings.geometry.radius
        border.width: Config.settings.geometry.borderWidth
        border.color: Config.settings.colors.border
        MouseArea { anchors.fill: parent } // Do not dismiss on unused panel space.
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Config.settings.geometry.padding
            spacing: Config.settings.geometry.spacing
            ShellLabel {
                Layout.fillWidth: true
                text: panel.pending ? "Confirm: " + panel.pending.name : ShellState.mode.toUpperCase()
                font.pointSize: Config.settings.fonts.sizes.heading
                color: panel.pending ? Config.settings.colors.warning : Config.settings.colors.accent
            }
            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search…"
                font.family: Config.settings.fonts.interfaceFamily
                font.pointSize: Config.settings.fonts.sizes.launcher
                color: Config.settings.colors.text
                placeholderTextColor: Config.settings.colors.muted
                selectionColor: Config.settings.colors.selection
                selectedTextColor: Config.settings.colors.text
                background: Rectangle { color: Config.settings.colors.surface }
                onTextChanged: { results.currentIndex = 0; panel.pending = null; }
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        if (panel.pending) panel.pending = null; else ShellState.close();
                    } else if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N)) {
                        results.currentIndex = Math.min(results.currentIndex + 1, panel.entries.length - 1);
                    } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P)) {
                        results.currentIndex = Math.max(0, results.currentIndex - 1);
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) panel.activate();
                    else if (event.key === Qt.Key_Delete && ShellState.mode === "notifications") {
                        const action = panel.entries[results.currentIndex];
                        if (action && action.notification) action.notification.dismiss();
                    } else return;
                    event.accepted = true;
                }
            }
            ListView {
                id: results
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: panel.entries
                currentIndex: 0
                highlightMoveDuration: 0
                boundsBehavior: Flickable.StopAtBounds
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: results.width
                    height: Config.settings.geometry.rowHeight
                    color: ListView.isCurrentItem ? Config.settings.colors.selection : "transparent"
                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: Config.settings.geometry.padding
                        anchors.rightMargin: Config.settings.geometry.padding
                        ShellLabel { width: parent.width; text: modelData.name; height: parent.height * 0.58 }
                        ShellLabel { width: parent.width; text: modelData.detail || ""; height: parent.height * 0.42; color: Config.settings.colors.muted; font.pointSize: Config.settings.fonts.sizes.bar }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: { results.currentIndex = index; panel.activate(); }
                    }
                }
                ShellLabel { anchors.centerIn: parent; visible: panel.entries.length === 0; text: "No results"; color: Config.settings.colors.muted }
            }
            ShellLabel {
                Layout.fillWidth: true
                color: Config.settings.colors.muted
                font.pointSize: Config.settings.fonts.sizes.bar
                text: panel.pending ? "Enter confirms · Escape cancels" : "↑/↓ or Ctrl+N/P · Enter selects · Escape closes" + (ShellState.mode === "notifications" ? " · Delete dismisses" : "")
            }
        }
    }
}
