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
    property string currentDevice: setCurrentDevice()

    property string currentDeviceName: ""

    function setCurrentDevice() {
        const current = AudioService.sink;
        var newCurrentDevice = "unknown";
        var newCurrentName = "Audio";

        if (current.name === settingsSinkHeadset) {
            newCurrentDevice = "headset";
            newCurrentName = headsetSinkName;
        }
        if (current.name === settingsSinkStereo) {
            newCurrentDevice = "stereo";
            newCurrentName = stereoSinkName;
        }
        root.currentDeviceName = newCurrentName;
        return newCurrentDevice;
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
            id: pillContainer
            readonly property int pad: Theme.spacingXS

            property string activeName: root.currentDeviceName
            property string displayName: activeName
            property var displayIcon: getAudioDeviceIcon()

            width: hContent.implicitWidth + pad * 2
            height: Math.max(Theme.iconSize, Theme.fontSizeSmall) + pad * 2
            implicitWidth: width
            implicitHeight: height
            clip: false

            // This triggers the "slide" whenever the name changes
            onActiveNameChanged: {
                slideAnimation.restart();
            }

            function getAudioDeviceIcon() {
                const device = AudioService.sink;
                if (!device?.name)
                    return "speaker";
                const name = device.name.toLowerCase();
                if (name.includes("bluez") || name.includes("bluetooth") || name.includes("usb"))
                    return "headset";
                if (name.includes("hdmi"))
                    return "tv";
                return "speaker";
            }

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggle()
            }

            Row {
                id: hContent
                anchors.centerIn: parent
                spacing: Theme.spacingS

                DankIcon {
                    name: pillContainer.displayIcon
                    size: Theme.iconSize
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: pillContainer.displayName
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            SequentialAnimation {
                id: slideAnimation
                readonly property int sDuration: 150
                readonly property int lDuration: 200

                // 1. Slide down and fade out
                ParallelAnimation {
                    NumberAnimation {
                        target: hContent
                        property: "opacity"
                        to: 0
                        duration: slideAnimation.sDuration
                    }
                    NumberAnimation {
                        target: hContent
                        property: "anchors.horizontalCenterOffset"
                        to: 20
                        duration: slideAnimation.sDuration
                        easing.type: Easing.InQuad
                    }
                }

                // 2. Replace old Content
                ScriptAction {
                    script: {
                        pillContainer.displayName = pillContainer.activeName;
                        pillContainer.displayIcon = pillContainer.getAudioDeviceIcon();
                    }
                }

                // 3. Snap to top (invisible)
                PropertyAction {
                    target: hContent
                    property: "anchors.horizontalCenterOffset"
                    value: -20
                }

                // 4. Slide into place and fade in
                ParallelAnimation {
                    NumberAnimation {
                        target: hContent
                        property: "opacity"
                        to: 1
                        duration: slideAnimation.lDuration
                    }
                    NumberAnimation {
                        target: hContent
                        property: "anchors.horizontalCenterOffset"
                        to: 0
                        duration: slideAnimation.lDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }

    // Vertical bar pill
    verticalBarPill: Component {
        Item {
            id: pillContainer
            readonly property int pad: Theme.spacingXS

            property string activeName: root.currentDeviceName
            property string displayName: activeName
            property var displayIcon: getAudioDeviceIcon()

            width: Math.max(vIcon.implicitWidth, vLabel.implicitWidth) + pad * 2
            height: vIcon.implicitHeight + vLabel.implicitHeight + pad * 3
            implicitWidth: width
            implicitHeight: height
            clip: false

            // This triggers the "slide" whenever the name changes
            onActiveNameChanged: {
                slideAnimation.restart();
            }

            function getAudioDeviceIcon() {
                const device = AudioService.sink;
                if (!device?.name)
                    return "speaker";
                const name = device.name.toLowerCase();
                if (name.includes("bluez") || name.includes("bluetooth") || name.includes("usb"))
                    return "headset";
                if (name.includes("hdmi"))
                    return "tv";
                return "speaker";
            }

            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggle()
            }

            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                DankIcon {
                    id: vIcon
                    name: pillContainer.displayIcon
                    size: Theme.iconSize
                    color: Theme.surfaceText
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    id: vLabel
                    text: pillContainer.displayName
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 1
                    wrapMode: Text.WrapAnywhere
                    lineHeight: 1
                    maximumLineCount: 20
                }
            }

            SequentialAnimation {
                id: slideAnimation
                readonly property int sDuration: 150
                readonly property int lDuration: 200

                // 1. Slide down and fade out
                ParallelAnimation {
                    NumberAnimation {
                        target: mainColumn
                        property: "opacity"
                        to: 0
                        duration: slideAnimation.sDuration
                    }
                    NumberAnimation {
                        target: mainColumn
                        property: "anchors.verticalCenterOffset"
                        to: 20
                        duration: slideAnimation.sDuration
                        easing.type: Easing.InQuad
                    }
                }

                // 2. Replace old Content
                ScriptAction {
                    script: {
                        pillContainer.displayName = pillContainer.activeName;
                        pillContainer.displayIcon = pillContainer.getAudioDeviceIcon();
                    }
                }

                // 3. Snap to top (invisible)
                PropertyAction {
                    target: mainColumn
                    property: "anchors.verticalCenterOffset"
                    value: -20
                }

                // 4. Slide into place and fade in
                ParallelAnimation {
                    NumberAnimation {
                        target: mainColumn
                        property: "opacity"
                        to: 1
                        duration: slideAnimation.lDuration
                    }
                    NumberAnimation {
                        target: mainColumn
                        property: "anchors.verticalCenterOffset"
                        to: 0
                        duration: slideAnimation.lDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
}
