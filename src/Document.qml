/* ============================================================
 *
 * Copyright (C) 2015 by Kåre Särs <kare.sars@iki .fi>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 *  by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License.
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 * ============================================================ */
import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import org.kde.skanpage 1.0

Item {
    id: doc

    focus: true
    clip: true

    property string name: qsTr("Unnamed");


    function grabScanner() {
        skanPage.setDocument(pages);
    }

    function addImage() {
        skanPage.startScan()
    }

    function save() {
        console.log("save");
    }

    DocumentModel {
        id: pages
    }

    SystemPalette { id: palette; colorGroup: SystemPalette.Inactive }

    Timer {
        id: delTmr
        interval: 1
        property int delIndex
        onTriggered: {
            pages.removeImage(delIndex);
            if (listView.count === 0) {
                bigImage.source = "";
            }
        }
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Horizontal
        ScrollView {
            id: scrollView
            Layout.fillWidth: false
            Layout.fillHeight: true
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
            frameVisible: true
            highlightOnFocus: true

            width: 180

            ListView {
                id: listView
                clip: true
                width: scrollView.viewport.width

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
                }

                model: pages

                onCurrentItemChanged: {
                    bigImage.source = listView.currentItem.imageSrc
                }

                delegate: Item {
                    id: delegateRoot
                    focus: index === listView.currentIndex

                    property string imageSrc: "file://"+model.name
                    property int index: model.index
                    width: listView.width;
                    height: icon.height+2*Screen.pixelDensity

                    MouseArea {
                        id:mouseArea
                        anchors.fill: parent
                        drag.target: icon

                        acceptedButtons: Qt.LeftButton | Qt.RightButton


                        onClicked: {
                            listView.currentIndex = index;
                            if (mouse.button === Qt.RightButton) {
                                myContextMenu.popup();
                            }
                        }
                        onDoubleClicked: {
                            delTmr.delIndex = index;
                            delTmr.restart();
                        }
                    }

                    DropArea {
                        anchors.fill: parent
                        onEntered: {
                            pages.moveImage(drag.source.index, delegateRoot.index, 1);
                        }
                    }

                    Item {
                        id: icon
                        width: iconImage.width
                        height: iconImage.height + number.height + Screen.pixelDensity*0.5
                        anchors {
                            horizontalCenter: parent.horizontalCenter;
                            verticalCenter: parent.verticalCenter
                        }

                        Drag.active: mouseArea.drag.active
                        Drag.source: delegateRoot
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        states: [
                        State {
                            when: mouseArea.drag.active
                            ParentChange {
                                target: icon
                                parent: doc
                            }

                            AnchorChanges {
                                target: icon;
                                anchors.horizontalCenter: undefined;
                                anchors.verticalCenter: undefined
                            }
                        }
                        ]

                        Image {
                            id: iconImage
                            sourceSize.width: listView.width-2*Screen.pixelDensity
                            anchors {
                                horizontalCenter: parent.horizontalCenter;
                                top: parent.top
                            }
                            source:  "file://"+model.name
                        }
                        Text {
                            id: number
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: model.index+1
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        color: palette.highlight
                        visible: index === listView.currentIndex
                    }
                    Keys.onPressed: {
                        console.log("pressed");
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent

                ScrollView {
                    id: imageViewer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Item {
                        width: Math.max(imageViewer.viewport.width, bigImage.width)
                        height: Math.max(imageViewer.viewport.height, bigImage.height)
                        Image {
                            anchors.centerIn: parent
                            id: bigImage
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: skanPage.progress === 100;
                    ToolButton { action: zoomInAction }
                    ToolButton { action: zoomOutAction }
                    ToolButton { action: zoomFitAction }
                    Item { id: toolbarSpacer; Layout.fillWidth: true }
                }
                RowLayout {
                    Layout.fillWidth: true
                    visible: skanPage.progress < 100;
                    ProgressBar {
                        Layout.fillWidth: true
                        value: skanPage.progress / 100;
                    }
                    ToolButton { action: cancelAction }
                }
            }
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Delete) {
            console.log("Delete");
            event.accepted = true;
            delTmr.delIndex = listView.currentIndex;
            delTmr.restart();
        }
    }
    Keys.onUpPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            moveUp()
        }
        else {
            listView.decrementCurrentIndex()
        }
        event.accepted = true;
    }

    Keys.onDownPressed: {
        if (event.modifiers & Qt.ControlModifier) {
            moveDown()
        }
        else {
            listView.incrementCurrentIndex()
        }
        event.accepted = true;
    }

    function moveUp() {
        if (listView.currentIndex > 0) {
            pages.moveImage(listView.currentIndex, listView.currentIndex-1, 1);
            listView.currentIndex--;
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
        }
    }
    function moveDown() {
        if (listView.currentIndex < listView.count-1) {
            pages.moveImage(listView.currentIndex, listView.currentIndex+1, 1);
            listView.currentIndex++;
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
        }
    }

    Action {
        id: zoomInAction
        iconName: "zoom-in"
        text: qsTr("Zoom In")
        shortcut: StandardKey.ZoomIn
        onTriggered: console.log("zoom in")
    }

    Action {
        id: zoomOutAction
        iconName: "zoom-out"
        text: qsTr("Zoom Out")
        shortcut: StandardKey.ZoomOut
        onTriggered: console.log("zoom out")
    }

    Action {
        id: zoomFitAction
        iconName: "zoom-fit-best"
        text: qsTr("Zoom Fit")
        shortcut: StandardKey.ZoomOut
        onTriggered: console.log("zoom out")
    }

    Action {
        id: cancelAction
        iconName: "window-close"
        text: qsTr("Cancel")
        shortcut: StandardKey.ESC
        onTriggered: skanPage.cancelScan()
    }

    Menu{
        id: myContextMenu
        title: "Edit"

        MenuItem {
            text: "Delete"
            onTriggered: {
                delTmr.delIndex = listView.currentIndex;
                delTmr.restart();
            }
        }

        MenuItem {
            text: "Move Up"
            onTriggered: moveUp()
        }
        MenuItem {
            text: "Move Down"
            onTriggered: moveDown()
        }
    }
}
