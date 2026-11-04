import QtQuick
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property var modelData
            DesktopBackground { screen: modelData }
            Bar { screen: modelData }
            CommandPalette { targetScreen: modelData }
            Toasts { screen: modelData }
        }
    }
}
