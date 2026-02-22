pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool sidebarRightOpen: false
    property string sidebarRightScreen: ""
}
