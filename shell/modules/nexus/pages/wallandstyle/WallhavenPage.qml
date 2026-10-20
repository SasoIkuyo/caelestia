import "../../../../Esp.js" as Es
import QtQuick
import QtQuick.Layouts
import qs.modules.dashboard
import qs.modules.nexus.common

PageBase {
    title: Es.tr(qsTr("Wallhaven"))
    isSubPage: true
    scrollable: false

    WallhavenTab {
        anchors.fill: parent
    }
}
