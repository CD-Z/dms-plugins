import QtQuick
import Quickshell.Services.Pipewire
import qs.Services
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "audioSwitcher"

    property var outputDevices: []

    // Current saved values
    property string selectedHeadset: pluginData.headsetSink || ""
    property string selectedStereo: pluginData.stereoSink || ""

    function updateDeviceList() {
        const allNodes = Pipewire.nodes.values;

        // Sort devices: active first, then alphabetically by name
        const sortDevices = (a, b) => {
            if (a === AudioService.sink && b !== AudioService.sink)
                return -1;
            if (b === AudioService.sink && a !== AudioService.sink)
                return 1;
            const nameA = AudioService.displayName(a).toLowerCase();
            const nameB = AudioService.displayName(b).toLowerCase();
            return nameA.localeCompare(nameB);
        };

        const outputs = allNodes.filter(node => {
            return node.audio && node.isSink && !node.isStream;
        });
        outputDevices = outputs.sort(sortDevices).map(node => ({
                    label: AudioService.displayName(node),
                    value: node.name
                }));
    }

    Component.onCompleted: {
        updateDeviceList();
    }

    Connections {
        target: Pipewire.nodes
        function onValuesChanged() {
            root.updateDeviceList();
        }
    }

    StyledText {
        text: "Hint: Rename your audio devices in System > Audio"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceText
    }

    SelectionSetting {
        settingKey: "headsetSink"
        label: "Audio device 1"
        options: root.outputDevices
        defaultValue: root.outputDevices[0].value ?? "No devices found"
    }
    SelectionSetting {
        settingKey: "stereoSink"
        label: "Audio device 2"
        options: root.outputDevices
        defaultValue: root.outputDevices[1].value ?? "No devices found"
    }
}
