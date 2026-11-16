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

    readonly property var iconOptions: [
        { label: "Automatic", value: "auto" },
        { label: "Headset", value: "headset" },
        { label: "Headphones", value: "headphones" },
        { label: "Speaker", value: "speaker" },
        { label: "TV", value: "tv" },
        { label: "Monitor", value: "monitor" },
        { label: "Laptop", value: "laptop" },
        { label: "Phone", value: "smartphone" },
        { label: "Bluetooth", value: "bluetooth" },
        { label: "Gamepad", value: "sports_esports" },
        { label: "Radio", value: "radio" },
        { label: "Record player", value: "album" }
    ]

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

    SelectionSetting {
        settingKey: "headsetSink"
        label: "Audio device 1"
        options: root.outputDevices
        defaultValue: root.outputDevices[0]?.value ?? ""
    }
    SelectionSetting {
        settingKey: "stereoSink"
        label: "Audio device 2"
        options: root.outputDevices
        defaultValue: root.outputDevices[1]?.value ?? ""
    }
    SelectionSetting {
        settingKey: "headsetIcon"
        label: "Audio device 1 icon"
        description: "Icon shown when device 1 is the active output"
        options: root.iconOptions
        defaultValue: "auto"
    }
    SelectionSetting {
        settingKey: "stereoIcon"
        label: "Audio device 2 icon"
        description: "Icon shown when device 2 is the active output"
        options: root.iconOptions
        defaultValue: "auto"
    }
    StyledText {
        text: "Hint: Rename your audio devices in System > Audio"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceText
    }
    StyledRect {
        width: parent.width
        height: 1
        color: Theme.surfaceVariant
    }
    StyledText {
        text: "Shortcut Integration"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }
    StyledText {
        text: "This plugin toggles through the DMS widget IPC."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        width: parent.width
        wrapMode: Text.WordWrap
    }
    StyledText {
        text: "Usage example"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.DemiBold
        color: Theme.surfaceText
    }
    StyledRect {
        width: parent.width
        height: col.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh
        Column {
            id: col
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: `dms ipc call widget toggle audioSwitcher\n\nHyprland: bind = $mod, F9, exec, dms ipc call widget toggle audioSwitcher\n\nNiri: Mod+F9 { spawn "dms" "ipc" "call" "widget" "toggle" "audioSwitcher"; }`
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
}
