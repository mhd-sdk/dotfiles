// Controls system volume via wpctl (WirePlumber CLI).
// Watches for sink changes via pactl subscribe to stay in sync.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real volume: 0   // 0–1
    property bool muted: false
    property bool ready: false

    Component.onCompleted: {
        refreshProc.running = true
        subscribeProc.running = true
    }

    function set(v) {
        const clamped = Math.max(0, Math.min(1, v))
        root.volume = clamped
        setProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", clamped.toFixed(4)]
        setProc.running = true
    }

    function _parse(line) {
        // "Volume: 0.64" or "Volume: 0.64 [MUTED]"
        const m = line.match(/Volume:\s+([\d.]+)(.*\[MUTED\])?/)
        if (!m) return
        const newVol = parseFloat(m[1])
        const newMuted = line.includes("[MUTED]")
        root.volume = newVol
        root.muted = newMuted
        root.ready = true
    }

    // One-shot read of current volume
    Process {
        id: refreshProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => root._parse(data.trim())
        }
    }

    // Watch for sink change events
    Process {
        id: subscribeProc
        command: ["pactl", "subscribe"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("'change'") && data.includes("on sink #"))
                    refreshProc.running = true
            }
        }
    }

    Process { id: setProc }
}
