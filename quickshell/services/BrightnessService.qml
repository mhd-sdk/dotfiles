// Runs ddcutil detect once at startup to build screen name → I2C bus mapping,
// then pre-fetches brightness for each bus so ScreenBrightness can init instantly.
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Map: screen name (e.g. "DP-3") → I2C bus number (e.g. 15)
    property var busMap: ({})
    // Map: bus number → brightness value (0–1), pre-fetched at startup
    property var brightnessCache: ({})
    property bool ready: false

    function updateCache(bus, value) {
        const m = Object.assign({}, brightnessCache)
        m[bus] = value
        brightnessCache = m
    }

    Component.onCompleted: detectProc.running = true

    Process {
        id: detectProc
        command: ["ddcutil", "detect", "--terse"]
        stdout: StdioCollector {
            onStreamFinished: {
                const map = {}
                let currentBus = -1
                for (const line of text.split("\n")) {
                    const busMatch = line.match(/I2C bus:\s+\/dev\/i2c-(\d+)/)
                    if (busMatch) currentBus = parseInt(busMatch[1])
                    const connMatch = line.match(/DRM connector:\s+\S+?-(\S+)/)
                    if (connMatch && currentBus >= 0)
                        map[connMatch[1]] = currentBus
                }
                root.busMap = map
                root.ready = true
                // Pre-fetch brightness for every detected bus
                const buses = Object.values(map)
                if (buses.length > 0) {
                    fetchProc.queue = buses.slice()
                    fetchProc.fetchNext()
                }
            }
        }
    }

    // Sequential brightness pre-fetch for each bus
    Process {
        id: fetchProc
        property var queue: []
        property int currentBus: -1

        function fetchNext() {
            if (queue.length === 0) return
            currentBus = queue.shift()
            command = ["ddcutil", "--bus", currentBus.toString(), "getvcp", "10", "--terse"]
            running = true
        }

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length >= 5) {
                    const cur = parseInt(parts[3])
                    const max = parseInt(parts[4])
                    if (!isNaN(cur) && !isNaN(max) && max > 0)
                        root.updateCache(fetchProc.currentBus, cur / max)
                }
                fetchProc.fetchNext()
            }
        }
    }
}
