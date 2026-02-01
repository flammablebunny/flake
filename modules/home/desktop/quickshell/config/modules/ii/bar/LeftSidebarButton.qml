import QtQuick
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    property real buttonPadding: 5
    implicitWidth: distroIcon.width + buttonPadding * 2
    implicitHeight: distroIcon.height + buttonPadding * 2

    CustomIcon {
        id: distroIcon
        anchors.centerIn: parent
        width: 19.5
        height: 19.5
        source: SystemInfo.distroIcon
        colorize: false
    }
}
