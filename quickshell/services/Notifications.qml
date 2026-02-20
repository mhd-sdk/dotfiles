pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool silent: false
    property list<Notification> list: server.trackedNotifications

    NotificationServer {
        id: server
        keepOnReload: false
        onNotification: notification => {
            notification.tracked = true
        }
    }

    function discardNotification(notificationId) {
        for (const n of root.list) {
            if (n.id === notificationId) {
                n.dismiss()
                return
            }
        }
    }

    function discardAllNotifications() {
        const toRemove = [...root.list]
        for (const n of toRemove) {
            n.dismiss()
        }
    }
}
