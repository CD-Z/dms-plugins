pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    pillClickAction: () => root.toggle()

    readonly property string settingsSinkStereo: pluginData.stereoSink ?? ""
    readonly property string settingsSinkHeadset: pluginData.headsetSink ?? ""
    readonly property string settingsHeadsetIcon: pluginData.headsetIcon ?? "auto"
    readonly property string settingsStereoIcon: pluginData.stereoIcon ?? "auto"

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

    readonly property string currentIcon: {
        if (currentDevice === "headset" && settingsHeadsetIcon && settingsHeadsetIcon !== "auto")
            return settingsHeadsetIcon;
        if (currentDevice === "stereo" && settingsStereoIcon && settingsStereoIcon !== "auto")
            return settingsStereoIcon;
        return autoDeviceIcon();
    }

    function autoDeviceIcon() {
        const sink = AudioService.sink;
        if (!sink)
            return "speaker";
        const label = (sink.description || sink.name || "").toLowerCase();
        if (label.includes("headset") || label.includes("headphone") || label.includes("bluez") || label.includes("bluetooth") || label.includes("usb"))
            return "headset";
        if (label.includes("hdmi") || label.includes("tv"))
            return "tv";
        return "speaker";
    }

    function setSinks() {
        const sinks = Array.from(Pipewire.nodes.values);

        const hSink = settingsSinkHeadset ? sinks.find(n => n.name === settingsSinkHeadset) : null;
        headsetSink = hSink ?? null;
        headsetSinkName = hSink ? AudioService.displayName(hSink) : "";

        const sSink = settingsSinkStereo ? sinks.find(n => n.name === settingsSinkStereo) : null;
        stereoSink = sSink ?? null;
        stereoSinkName = sSink ? AudioService.displayName(sSink) : "";
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
            deviceIcon: root.currentIcon
        }
    }

    verticalBarPill: Component {
        AudioPillVertical {
            deviceName: root.currentDeviceName
            deviceIcon: root.currentIcon
        }
    }
}
