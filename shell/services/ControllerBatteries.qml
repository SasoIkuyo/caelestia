pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    readonly property string home: Quickshell.env("HOME")
    IpcHandler {
        target: "controllerBattery"
        function status(): string { return JSON.stringify(root.levels); }
    }
    property var levels: ({})
    function available(device): bool {
        return !!device && (device.batteryAvailable || levels[device.address.toUpperCase()] !== undefined);
    }
    function level(device): real {
        if (!device) return 0;
        return device.batteryAvailable ? device.battery : (levels[device.address.toUpperCase()] ?? 0);
    }
    function setColor(address: string, red: int, green: int, blue: int): void {
        if (color.running) return;
        color.command = [`${root.home}/.local/bin/dualsensectl`, "-d", address.toLowerCase(), "lightbar", String(red), String(green), String(blue)];
        color.running = true;
    }
    Process {
        id: scan
        command: ["/usr/bin/python", `${root.home}/.local/share/dualsense-control/batteries.py`]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.levels = JSON.parse(text); } catch (e) { console.warn("Controller battery:", e); }
            }
        }
    }
    Process {
        id: color
        onExited: (code, status) => {
            if (code !== 0) Toaster.toast("DualSense", "Faltan permisos para cambiar la luz. Ejecuta habilitar-dualsense.sh y reconecta el mando.", "error");
        }
    }
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!scan.running) scan.running = true }
}
