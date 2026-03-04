pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string settingsSinkStereo: pluginData.stereoSink ?? ""
    readonly property string settingsSinkHeadset: pluginData.headsetSink ?? ""

    property var headsetSink: null
    property var stereoSink: null
    property string headsetSinkName: ""
    property string stereoSinkName: ""

    readonly property string currentDevice: {
        const name = AudioService.sink?.name ?? "";
        if (name === settingsSinkHeadset)
            return "headset";
        if (name === settingsSinkStereo)
            return "stereo";
        return "unknown";
    }

    readonly property string currentDeviceName: {
        if (currentDevice === "headset")
            return headsetSinkName;
        if (currentDevice === "stereo")
            return stereoSinkName;
        return "Audio";
    }

    function getAudioDeviceIcon() {
        const name = AudioService.sink?.name.toLowerCase() ?? "";
        if (name.includes("bluez") || name.includes("bluetooth") || name.includes("usb"))
            return "headset";
        if (name.includes("hdmi"))
            return "tv";
        return "speaker";
    }

    function setSinks() {
        if (!settingsSinkHeadset || !settingsSinkStereo)
            return;

        const sinks = Array.from(Pipewire.nodes.values);
        const hSink = sinks.find(n => n.name === settingsSinkHeadset);
        const sSink = sinks.find(n => n.name === settingsSinkStereo);

        if (hSink) {
            headsetSink = hSink;
            headsetSinkName = AudioService.displayName(hSink);
        }
        if (sSink) {
            stereoSink = sSink;
            stereoSinkName = AudioService.displayName(sSink);
        }
    }

    onSettingsSinkStereoChanged: setSinks()
    onSettingsSinkHeadsetChanged: setSinks()
    Component.onCompleted: setSinks()

    Connections {
        target: Pipewire.nodes
        function onValuesChanged() {
            root.setSinks();
        }
    }

    function toggle() {
        setSinks();

        if (!headsetSink || !stereoSink) {
            ToastService.showWarning("Sinks not found. Check settings/hardware.");
            return;
        }

        if (currentDevice === "headset") {
            Pipewire.preferredDefaultAudioSink = stereoSink;
            ToastService.showInfo("Switched to Stereo");
        } else {
            Pipewire.preferredDefaultAudioSink = headsetSink;
            ToastService.showInfo("Switched to Headset");
        }
    }

    horizontalBarPill: Component {
        AudioPillHorizontal {
            deviceName: root.currentDeviceName
            deviceIcon: root.getAudioDeviceIcon()
            onToggle: root.toggle()
        }
    }

    verticalBarPill: Component {
        AudioPillVertical {
            deviceName: root.currentDeviceName
            deviceIcon: root.getAudioDeviceIcon()
            onToggle: root.toggle()
        }
    }
}
