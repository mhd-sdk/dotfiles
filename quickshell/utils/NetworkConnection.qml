pragma Singleton

import qs.services
import QtQuick

/**
 * NetworkConnection
 *
 * Centralized utility for network connection logic.
 */
QtObject {
    id: root

    /**
     * Handle network connection with automatic disconnection if needed.
     */
    function handleConnect(network, onPasswordNeeded): void {
        if (!network) {
            return
        }

        if (Nmcli.active && Nmcli.active.ssid !== network.ssid) {
            Nmcli.disconnectFromNetwork()
            Qt.callLater(() => {
                root.connectToNetwork(network, onPasswordNeeded)
            })
        } else {
            root.connectToNetwork(network, onPasswordNeeded)
        }
    }

    /**
     * Connect to a wireless network.
     * Handles both secured and open networks, checks for saved profiles,
     * and shows password dialog if needed.
     */
    function connectToNetwork(network, onPasswordNeeded): void {
        if (!network) {
            return
        }

        if (network.isSecure) {
            const hasSavedProfile = Nmcli.hasSavedProfile(network.ssid)

            if (hasSavedProfile) {
                Nmcli.connectToNetwork(network.ssid, "", network.bssid, null)
            } else {
                // Use password check with callback
                Nmcli.connectToNetworkWithPasswordCheck(network.ssid, network.isSecure, result => {
                    if (result.needsPassword) {
                        // Clear pending connection if exists
                        if (Nmcli.pendingConnection) {
                            Nmcli.pendingConnection = null
                        }

                        // Show password dialog
                        if (onPasswordNeeded) {
                            onPasswordNeeded(network)
                        }
                    }
                }, network.bssid)
            }
        } else {
            Nmcli.connectToNetwork(network.ssid, "", network.bssid, null)
        }
    }

    /**
     * Connect to a wireless network with a provided password.
     * Used by password dialogs when the user has already entered a password.
     */
    function connectWithPassword(network, password, onResult): void {
        if (!network) {
            return
        }

        Nmcli.connectToNetwork(network.ssid, password || "", network.bssid || "", onResult || null)
    }
}
