pragma ComponentBehavior: Bound
import QtQuick
import qs.Common
import qs.Widgets

Item {
    id: pillContainer

    readonly property int pad: Theme.spacingXS

    property string deviceName: ""
    property string deviceIcon: "speaker"

    signal toggle

    property string _displayName: deviceName
    property string _displayIcon: deviceIcon

    width: hContent.implicitWidth + pad * 2
    height: Math.max(Theme.iconSize, Theme.fontSizeSmall) + pad * 2
    implicitWidth: width
    implicitHeight: height

    onDeviceNameChanged: slideAnimation.restart()

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
        onClicked: pillContainer.toggle()
    }

    Row {
        id: hContent
        anchors.centerIn: parent
        spacing: Theme.spacingS

        DankIcon {
            name: pillContainer._displayIcon
            size: Theme.iconSize
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: pillContainer._displayName
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceText
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    SequentialAnimation {
        id: slideAnimation
        readonly property int sDuration: 150
        readonly property int lDuration: 200

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

        ScriptAction {
            script: {
                pillContainer._displayName = pillContainer.deviceName;
                pillContainer._displayIcon = pillContainer.deviceIcon;
            }
        }

        PropertyAction {
            target: hContent
            property: "anchors.horizontalCenterOffset"
            value: -20
        }

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
