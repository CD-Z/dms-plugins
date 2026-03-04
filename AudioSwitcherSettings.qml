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
        text: "This plugin watches the file '/tmp/dms-plugin-audio-switcher'. If you write anything into this file, the audio devices will be switched and the file cleared."
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
                text: `echo "1" > /tmp/dms-plugin-audio-switcher`
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
}
