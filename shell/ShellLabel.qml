import QtQuick

Text {
    color: Config.settings.colors.text
    font.family: Config.settings.fonts.interfaceFamily
    font.pointSize: Config.settings.fonts.sizes.interface
    textFormat: Text.PlainText
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
