pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications

Scope {
    id: root
    property string mode: ""
    property var activeScreen: null
    property bool doNotDisturb: false
    property string osdText: ""
    property var popup: null
    property var clipboardEntries: []
    readonly property var notifications: server.trackedNotifications.values

    function close() { mode = ""; }
    function toggle(nextMode) {
        if (mode === nextMode) { close(); return; }
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        activeScreen = Quickshell.screens.find(s => s.name === name) || Quickshell.screens[0] || null;
        mode = nextMode;
        if (nextMode === "clipboard") clipboardReader.running = true;
    }
    function showOsd(message) { osdText = message; osdTimer.restart(); }
    function execute(action) {
        // Close before focusing a window or starting an application.
        close();
        if (action.entry) action.entry.execute();
        else if (action.notification) {
            if (action.notification.actions.length > 0) action.notification.actions[0].invoke();
        } else if (action.clipboardId) {
            Quickshell.execDetached(["desktop-clipboard", action.clipboardId]);
        } else if (action.dispatcher) {
            Quickshell.execDetached(["hyprctl", "dispatch", action.dispatcher]);
        } else if (action.command && action.command.length) {
            Quickshell.execDetached(action.command);
        }
    }
    function actions() {
        return Config.settings.shortcuts.map(s => ({
            id: s.id, name: s.description, detail: s.keys.join(" + "),
            command: s.command, dispatcher: s.dispatcher, confirm: s.confirm
        }));
    }

    IpcHandler {
        target: "desktop"
        function toggle(mode: string): void { root.toggle(mode); }
        function close(): void { root.close(); }
        function osd(message: string): void { root.showOsd(message); }
        function dnd(): void { root.doNotDisturb = !root.doNotDisturb; }
        function status(): string {
            return JSON.stringify({ mode: root.mode, dnd: root.doNotDisturb,
                notifications: root.notifications.length, osd: root.osdText,
                applications: DesktopEntries.applications.values.length });
        }
    }
    Timer { id: osdTimer; interval: 1800; onTriggered: root.osdText = "" }
    Timer { id: popupTimer; interval: Config.settings.notifications.notificationTimeoutMs; onTriggered: root.popup = null }
    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: true
        onNotification: notification => {
            notification.tracked = true;
            const old = server.trackedNotifications.values.slice();
            while (old.length > Config.settings.notifications.notificationHistoryLimit) old.shift().dismiss();
            if (!root.doNotDisturb) {
                root.popup = notification;
                popupTimer.restart();
            }
        }
    }
    Process {
        id: clipboardReader
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.clipboardEntries = text.trim().split("\n").filter(line => line.includes("\t")).map(line => {
                    const tab = line.indexOf("\t");
                    return { name: line.slice(tab + 1), detail: "Clipboard", clipboardId: line.slice(0, tab) };
                });
            }
        }
    }
}
