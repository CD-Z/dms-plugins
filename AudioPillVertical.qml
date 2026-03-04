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

    width: Math.max(vIcon.implicitWidth, vLabel.implicitWidth) + pad * 2
    height: vIcon.implicitHeight + vLabel.implicitHeight + pad * 3
    implicitWidth: width
    implicitHeight: height

    onDeviceNameChanged: slideAnimation.restart()

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
        onClicked: pillContainer.toggle()
    }

    Column {
        id: mainColumn
        anchors.centerIn: parent
        spacing: Theme.spacingXS

        DankIcon {
            id: vIcon
            name: pillContainer._displayIcon
            size: Theme.iconSize
            color: Theme.surfaceText
            anchors.horizontalCenter: parent.horizontalCenter
        }

        StyledText {
            id: vLabel
            text: pillContainer._displayName
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

        ScriptAction {
            script: {
                pillContainer._displayName = pillContainer.deviceName;
                pillContainer._displayIcon = pillContainer.deviceIcon;
            }
        }

        PropertyAction {
            target: mainColumn
            property: "anchors.verticalCenterOffset"
            value: -20
        }

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
