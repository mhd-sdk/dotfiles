//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Window
import Quickshell
import "./services/"

import qs.modules.bar 
import qs.modules.common
import qs.modules.dock
import qs.modules.lock
import qs.modules.mediaControls
import qs.modules.notificationPopup
import qs.modules.onScreenDisplay
import qs.modules.onScreenKeyboard
import qs.modules.overview
import qs.modules.session
import qs.modules.sidebarLeft
import qs.modules.sidebarRight
import qs.modules.verticalBar

ShellRoot {
    // Enable/disable modules here. False = not loaded at all, so rest assured
    // no unnecessary stuff will take up memory if you decide to only use, say, the overview.
    property bool enableBar: true
    property bool enableDock: true
    property bool enableLock: true
    property bool enableMediaControls: true
    property bool enableNotificationPopup: true
    property bool enableOnScreenDisplayBrightness: true
    property bool enableOnScreenDisplayVolume: true
    property bool enableOnScreenKeyboard: true
    property bool enableOverview: true
    property bool enableReloadPopup: true
    property bool enableScreenCorners: true
    property bool enableSession: true
    property bool enableSidebarLeft: true
    property bool enableSidebarRight: true
    property bool enableVerticalBar: true

    // Force initialization of some singletons
    Component.onCompleted: {
        MaterialThemeLoader.reapplyTheme();
        Hyprsunset.load();
        FirstRunExperience.load();
        ConflictKiller.load();
        Cliphist.refresh();
    }

    LazyLoader {
        active: enableBar && Config.ready && !Config.options.bar.vertical
        component: Bar {}
    }
    //LazyLoader {
    //    active: enableDock && Config.options.dock.enable
    //    component: Dock {}
    //}
    //LazyLoader {
    //    active: enableLock
    //    component: Lock {}
    //}
    //LazyLoader {
    //    active: enableMediaControls
    //    component: MediaControls {}
    //}
    //LazyLoader {
    //    active: enableNotificationPopup
    //    component: NotificationPopup {}
    //}
    //LazyLoader {
    //    active: enableOnScreenDisplayBrightness
    //    component: OnScreenDisplayBrightness {}
    //}
    //LazyLoader {
    //    active: enableOnScreenDisplayVolume
    //    component: OnScreenDisplayVolume {}
    //}
    //LazyLoader {
    //    active: enableOnScreenKeyboard
    //    component: OnScreenKeyboard {}
    //}
    //LazyLoader {
    //    active: enableOverview
    //    component: Overview {}
    //}
    LazyLoader {
        active: enableReloadPopup
        component: ReloadPopup {}
    }
    //LazyLoader {
    //    active: enableSession
    //    component: Session {}
    //}
    //LazyLoader {
    //    active: enableSidebarLeft
    //    component: SidebarLeft {}
    //}
    //LazyLoader {
    //    active: enableSidebarRight
    //    component: SidebarRight {}
    //}
    //LazyLoader {
    //    active: enableVerticalBar && Config.ready && Config.options.bar.vertical
    //    component: VerticalBar {}
    //}
}
