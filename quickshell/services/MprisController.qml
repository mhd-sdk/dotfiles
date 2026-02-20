pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer trackedPlayer: null
    property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null
    property var allPlayers: Mpris.players

    property bool isPlaying: activePlayer?.isPlaying ?? false
    property bool canTogglePlaying: activePlayer?.canTogglePlaying ?? false
    property bool canGoPrevious: activePlayer?.canGoPrevious ?? false
    property bool canGoNext: activePlayer?.canGoNext ?? false

    function togglePlaying(): void {
        if (canTogglePlaying) activePlayer.togglePlaying()
    }

    function previous(): void {
        if (canGoPrevious) activePlayer.previous()
    }

    function next(): void {
        if (canGoNext) activePlayer.next()
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (!root.trackedPlayer || modelData.isPlaying)
                    root.trackedPlayer = modelData
            }

            Component.onDestruction: {
                if (!root.trackedPlayer || !root.trackedPlayer.isPlaying) {
                    for (const p of Mpris.players.values) {
                        if (p.isPlaying) {
                            root.trackedPlayer = p
                            return
                        }
                    }
                    root.trackedPlayer = Mpris.players.values[0] ?? null
                }
            }

            function onPlaybackStateChanged() {
                if (root.trackedPlayer !== modelData)
                    root.trackedPlayer = modelData
            }
        }
    }
}
