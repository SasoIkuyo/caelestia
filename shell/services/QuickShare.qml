pragma Singleton
import "../Esp.js" as Es
import Quickshell.Io
import QtQuick
import Caelestia
import Caelestia.Config
import Caelestia.Services

QtObject {
    id: root

    property bool isEnabled: QuickShareService.isEnabled
    property bool isVisible: QuickShareService.isVisible
    property var nearbyDevices: QuickShareService.nearbyDevices
    property var transferHistory: QuickShareService.transferHistory

    property IpcHandler ipc: IpcHandler {
        target: "quickshare"
        function status(): string {
            return JSON.stringify({enabled: root.isEnabled, visible: root.isVisible, devices: root.nearbyDevices});
        }
        function restart(): void {
            root.setVisible(false);
            root.setEnabled(false);
            root.setEnabled(true);
            root.setVisible(true);
        }
    }

    property var currentNotification: null
    property string currentDeviceName: ""
    property string currentFileName: ""
    property string currentPinCode: ""
    property int currentProgress: -1

    function setEnabled(enabled: bool) {
        QuickShareService.isEnabled = enabled
    }

    function setVisible(visible: bool) {
        QuickShareService.isVisible = visible
    }

    function sendFile(deviceId: string, filePath: string) {
        QuickShareService.sendFile(deviceId, filePath)
    }

    function acceptIncomingTransfer() {
        console.log("Quick Share: Accept clicked for " + root.currentFileName)
        QuickShareService.acceptIncomingTransfer()
        if (root.currentNotification) {
            root.currentNotification.summary = "Recibiendo archivo"
            root.currentNotification.body = root.currentFileName + "\nEspera mientras se completa la transferencia."
            root.currentNotification.actions = []
        }
    }

    function rejectIncomingTransfer() {
        QuickShareService.rejectIncomingTransfer()
    }

    function clearHistory() {
        QuickShareService.clearHistory()
    }

    function removeHistoryEntry(index: int) {
        QuickShareService.removeHistoryEntry(index)
    }

    function startBleWakeupBroadcast() {
        QuickShareService.startBleWakeupBroadcast()
    }

    function stopBleWakeupBroadcast() {
        QuickShareService.stopBleWakeupBroadcast()
    }

    // Connect to C++ signals
    Component.onCompleted: {
        QuickShareService.transferProgress.connect(function(deviceId, received, total) {
            if (deviceId !== "incoming" || !root.currentNotification) return;
            let percent = total > 0 ? Math.floor(received * 100 / total) : 100;
            if (percent === root.currentProgress) return;
            root.currentProgress = percent;
            root.currentNotification.summary = "Recibiendo: " + percent + "%";
            root.currentNotification.body = root.currentFileName + "\n" +
                (received / 1048576).toFixed(1) + " / " + (total / 1048576).toFixed(1) + " MiB";
        });
        QuickShareService.incomingTransferRequested.connect(function(deviceName, fileName, fileSize) {
            root.currentProgress = -1;
            console.log("Quick Share: Incoming transfer from " + deviceName + " - " + fileName)
            root.currentDeviceName = deviceName
            root.currentFileName = fileName
            let body = Es.tr(qsTr("%1 wants to share %2")).arg(deviceName).arg(fileName)
            if (root.currentPinCode)
                body += Es.tr(qsTr("\nPIN: %1")).arg(root.currentPinCode)
            root.currentNotification = Notifs.addCustomNotification(
                Es.tr(qsTr("Incoming file")),
                body,
                "",
                [
                    { text: Es.tr(qsTr("Decline")), invoke: function() { root.rejectIncomingTransfer(); } },
                    { text: Es.tr(qsTr("Accept")), invoke: function() { root.acceptIncomingTransfer(); } }
                ],
                true
            );
        })
        QuickShareService.incomingTransferPinReady.connect(function(pinCode) {
            root.currentPinCode = pinCode
            if (root.currentNotification) {
                root.currentNotification.body = Es.tr(qsTr("%1 wants to share %2\nPIN: %3")).arg(root.currentDeviceName).arg(root.currentFileName).arg(pinCode)
            }
        })
        QuickShareService.errorOccurred.connect(function(message) {
            Toaster.toast(Es.tr(qsTr("Quick Share Error")), message, "error");
        })
        QuickShareService.transferFinished.connect(function(deviceId, success) {
            if (deviceId === "incoming") {
                console.log("Quick Share: Transfer finished, success=" + success)
                Toaster.toast(success ? "Archivo recibido" : "Transferencia interrumpida",
                              success ? "Guardado en Descargas: " + root.currentFileName : "Vuelve a intentar el envío desde el celular.",
                              success ? "download_done" : "error");
            }
            if (root.currentNotification) {
                root.currentNotification.close();
                root.currentNotification = null;
            }
            root.currentDeviceName = ""
            root.currentFileName = ""
            root.currentPinCode = ""
        })

        if (GlobalConfig.services.quickShareAutoStart) {
            root.setEnabled(true);
            root.setVisible(true);
        }
    }
}
