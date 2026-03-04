pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool busy: false // Start as false so it's usable

    // 1. Simplify settings: reactive properties without the {} block logic
    readonly property string settingsSinkStereo: pluginData.stereoSink ?? ""
    readonly property string settingsSinkHeadset: pluginData.headsetSink ?? ""

    // 2. Initialize as null for proper boolean checks
    property var headsetSink: null
    property var stereoSink: null
    property string headsetSinkName: ""
    property string stereoSinkName: ""

    // 3. Current device logic
    readonly property string currentDevice: {
        const current = AudioService.sink;
        if (!current || !current.name)
            return "unknown";

        // Compare against the raw system name from settings
        if (current.name === settingsSinkHeadset)
            return "headset";
        if (current.name === settingsSinkStereo)
            return "stereo";
        return "unknown";
    }

    // 4. Centralized update function
    function setSinks() {
        // Don't run if settings aren't loaded yet
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

    // 5. REACTIVE CONNECTIONS
    // This is the part you were missing: update when settings arrive
    onSettingsSinkStereoChanged: setSinks()
    onSettingsSinkHeadsetChanged: setSinks()

    Connections {
        target: Pipewire.nodes
        function onValuesChanged() {
            root.setSinks();
        }
    }

    Component.onCompleted: setSinks()

    // Toggle function logic
    function toggle() {
        if (busy)
            return;

        // Re-check sinks just in case they were unplugged
        setSinks();

        if (!headsetSink || !stereoSink) {
            ToastService.showWarning("Sinks not found. Check settings/hardware.");
            return;
        }

        busy = true;
        if (currentDevice === "headset") {
            Pipewire.preferredDefaultAudioSink = stereoSink;
            ToastService.showInfo("Switched to Stereo");
        } else {
            Pipewire.preferredDefaultAudioSink = headsetSink;
            ToastService.showInfo("Switched to Headset");
        }
        busy = false;
    }

    // Horizontal bar pill
    horizontalBarPill: Component {
        Item {
            readonly property int pad: Theme.spacingS

            implicitWidth: hContent.implicitWidth + pad * 2
            implicitHeight: Math.max(Theme.iconSize, Theme.fontSizeSmall) + pad * 2

            Row {
                id: hContent
                anchors.centerIn: parent
                spacing: Theme.spacingS

                DankIcon {
                    name: getAudioDeviceIcon(AudioService.sink)
                    size: Theme.iconSize
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter

                    function getAudioDeviceIcon(device) {
                        if (!device?.name)
                            return "speaker";
                        const name = device.name.toLowerCase();
                        if (name.includes("bluez") || name.includes("bluetooth"))
                            return "headset";
                        if (name.includes("hdmi"))
                            return "tv";
                        if (name.includes("usb"))
                            return "headset";
                        return "speaker";
                    }
                }

                StyledText {
                    text: root.currentDevice === "headset" ? root.headsetSinkName : (root.currentDevice === "stereo" ? root.stereoSinkName : "Audio")
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggle()
            }
        }
    }

    // Vertical bar pill
    verticalBarPill: Component {
        Item {
            id: pillContainer
            readonly property int pad: Theme.spacingXS

            // Track the current device name to trigger the animation
            property string activeName: root.currentDevice === "headset" ? root.headsetSinkName : (root.currentDevice === "stereo" ? root.stereoSinkName : "Audio")

            width: Math.max(vIcon.implicitWidth, vLabel.implicitWidth) + pad * 2
            height: vIcon.implicitHeight + vLabel.implicitHeight + pad * 3
            implicitWidth: width
            implicitHeight: height
            clip: true

            // This triggers the "slide" whenever the name changes
            onActiveNameChanged: {
                slideAnimation.restart();
            }

            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                // We animate the Y position of the whole content
                // or just the internal elements.

                DankIcon {
                    id: vIcon
                    name: getAudioDeviceIcon(AudioService.sink)
                    size: Theme.iconSize
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter

                    // Add a slide behavior
                    Behavior on y {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutBack
                        }
                    }

                    function getAudioDeviceIcon(device) {
                        if (!device?.name)
                            return "speaker";
                        const name = device.name.toLowerCase();
                        if (name.includes("bluez") || name.includes("bluetooth") || name.includes("usb"))
                            return "headset";
                        if (name.includes("hdmi"))
                            return "tv";
                        return "speaker";
                    }
                }

                StyledText {
                    id: vLabel
                    text: pillContainer.activeName
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // The "Sliding" logic:
            // Instead of complex state machines, we can use a SequentialAnimation
            // that moves the content out, switches text, and snaps back.
            SequentialAnimation {
                id: slideAnimation

                // 1. Slide down and fade out
                ParallelAnimation {
                    NumberAnimation {
                        target: mainColumn
                        property: "opacity"
                        to: 0
                        duration: 150
                    }
                    NumberAnimation {
                        target: mainColumn
                        property: "anchors.verticalCenterOffset"
                        to: 20
                        duration: 150
                    }
                }

                // 2. Snap to top (invisible)
                PropertyAction {
                    target: mainColumn
                    property: "anchors.verticalCenterOffset"
                    value: -20
                }

                // 3. Slide into place and fade in
                ParallelAnimation {
                    NumberAnimation {
                        target: mainColumn
                        property: "opacity"
                        to: 1
                        duration: 200
                    }
                    NumberAnimation {
                        target: mainColumn
                        property: "anchors.verticalCenterOffset"
                        to: 0
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
