import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.modules.bar
import qs.modules.border
import qs.modules.sidebarRight

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: ScreenBorder {}
    }
    Variants {
        model: Quickshell.screens
        delegate: Bar {}
    }
    Variants {
        model: Quickshell.screens
        delegate: BorderExclusions {}
    }
    SidebarRight {}
}
