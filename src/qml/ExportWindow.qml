/**
 * SPDX-FileCopyrightText: 2015 by Kåre Särs <kare.sars@iki .fi>
 * SPDX-FileCopyrightText: 2021 by Alexander Stippich <a.stippich@gmx.net>
 *  
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import @QTQUICK_DIALOGS_IMPORT@

import org.kde.kirigami 2.12 as Kirigami

import org.kde.skanpage 1.0

Window {
    id: exportWindow

    title: i18n("Export PDF")
    color: Kirigami.Theme.backgroundColor
    
    modality: Qt.WindowModal
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint
           | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint | Qt.WindowMaximizeButtonHint

    minimumHeight: 300
    minimumWidth: 600

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.smallSpacing

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.smallSpacing

            Label {
                text: i18n("Title:")
                Layout.alignment: Qt.AlignRight
            }

            TextField {
                id: fileTitleItem
                Layout.fillWidth: true
                text: skanpage.documentModel.name
            }

            Item {
                width: 1
                height: 1
            }

            Label {
                text: i18n("File:")
                Layout.alignment: Qt.AlignRight
            }

            TextField {
                id: fileNameItem
                Layout.fillWidth: true
                text: skanpage.configuration.defaultFolder + "/" + skanpage.documentModel.fileName
            }

            ToolButton {
                icon.name: "folder"
                width: height
                onClicked: fileNameDialog.open()
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            CheckBox {
                id: ocrCheckBox
                visible: skanpage.OCRavailable()
                text: i18n("Enable optical character recognition (OCR)")
                enabled: ocrList.count > 0
                checked: enabled
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Label {
                visible: skanpage.OCRavailable()
                enabled: ocrCheckBox.checked
                text: i18n("Languages:")
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            ScrollView {
                id: ocrScroll
                Layout.fillHeight: true
                Layout.fillWidth: true
                visible: skanpage.OCRavailable()
                enabled: ocrCheckBox.checked

                Component.onCompleted: ocrScroll.background.visible = true

                ListView {
                    id: ocrList
                    clip: true
                    model: skanpage.languageModel

                    delegate: CheckDelegate {
                        text: i18n("%1 [%2]", model.name, model.code)
                        onClicked: model.use = checked
                        width: ocrScroll.width
                    }
                }
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Label {
                visible: skanpage.OCRavailable()
                text: i18n("If your required language is not listed, please install Tesseract's language file with your package manager.")
                font.italic: true
                wrapMode: Text.WordWrap
                Layout.maximumWidth: fileNameItem.width
            }

            Item {
                visible: skanpage.OCRavailable()
                width: 1
                height: 1
            }

            Item { 
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.columnSpan: 3
            }
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.alignment: Qt.AlignRight

            Button {
                id: saveButton
                icon.name: "document-save"
                text: i18n("Save")
                onClicked: { 
                    skanpage.documentModel.exportPDF(fileNameItem.text, fileTitleItem.text, ocrCheckBox.checked && skanpage.OCRavailable())
                    exportWindow.close()
                }
            }

            Button {
                action: cancelAction
            }
        }
    }

    Action {
        id: cancelAction
        icon.name: "dialog-close"
        text: i18n("Cancel")
        shortcut: "Esc"
        onTriggered: exportWindow.close()
    }

    FileDialog {
        id: fileNameDialog
        @FILEDIALOG_CURRENT_FOLDER@: skanpage.configuration.defaultFolder
        @FILEDIALOG_MODE_LOAD_FOLDER_NOTSELECTFOLDER@
        nameFilters: skanpage.formatModel.pdfFormatFilter()
        onAccepted: fileNameItem.text = @FILEDIALOG_SELECTED_FILE@
    }
}

