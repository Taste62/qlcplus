/*
  Q Light Controller Plus
  RGBMatrixEditor.qml

  Copyright (c) Massimo Callegari

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0.txt

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.1

import com.qlcplus.classes 1.0
import "."

Rectangle
{
    id: rgbmeContainer
    //anchors.fill: parent
    color: "transparent"

    property int functionID: -1
    property RGBMatrix matrix

    signal requestView(int ID, string qmlSrc)

    onFunctionIDChanged:
    {
        console.log("RGBMatrix ID: " + functionID)
        matrix = functionManager.getFunction(functionID)
    }

    Rectangle
    {
        id: topBar
        color: UISettings.bgMedium
        width: rgbmeContainer.width
        height: 40
        z: 2

        Rectangle
        {
            id: backBox
            width: 40
            height: 40
            color: "transparent"

            Image
            {
                id: leftArrow
                anchors.fill: parent
                rotation: 180
                source: "qrc:/arrow-right.svg"
                sourceSize: Qt.size(width, height)
            }
            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: backBox.color = "#666"
                onExited: backBox.color = "transparent"
                onClicked: requestView(-1, "qrc:/FunctionManager.qml")
            }
        }
        TextInput
        {
            id: cNameEdit
            x: leftArrow.width + 5
            height: 40
            width: topBar.width - x
            color: UISettings.fgMain
            clip: true
            text: matrix ? matrix.name : ""
            verticalAlignment: TextInput.AlignVCenter
            font.family: "RobotoCondensed"
            font.pixelSize: 20
            selectByMouse: true
            Layout.fillWidth: true
            onTextChanged:
            {
                if (matrix)
                    matrix.name = text
            }
        }
    }

    //onWidthChanged: editorFlickable.width = width - 10

    Flickable
    {
        id: editorFlickable
        x: 5
        y: topBar.height + 2
        width: parent.width - 10
        height: parent.height - y

        contentHeight: editorColumn.height
        boundsBehavior: Flickable.StopAtBounds

        Component.onCompleted: console.log("Flickable height: " + height + ", Grid height: " + editorColumn.height + ", parent height: " + parent.height)

        Column
        {
            id: editorColumn
            width: parent.width
            spacing: 2

            property int itemsHeight: 38
            property int firstColumnWidth: 0
            property int colWidth: parent.width - (sbar.visible ? sbar.width : 0)

            //onHeightChanged: editorFlickable.contentHeight = height //console.log("Grid layout height changed: " + height)

            function checkLabelWidth(w)
            {
                firstColumnWidth = Math.max(w, firstColumnWidth)
            }

            // row 1
            RowLayout
            {
                width: editorColumn.colWidth

                RobotoText
                {
                    label: qsTr("Fixture Group");
                    onWidthChanged:
                    {
                        editorColumn.checkLabelWidth(width)
                        width = Qt.binding(function() { return editorColumn.firstColumnWidth })
                    }
                }
                CustomComboBox
                {
                    Layout.fillWidth: true
                    height: editorColumn.itemsHeight
                    model: fixtureManager.groupsListModel
                    currentValue: rgbMatrixEditor.fixtureGroup
                    onValuechanged: rgbMatrixEditor.fixtureGroup = value
                }
            }

            // row 2
            RGBMatrixPreview
            {
                width: editorColumn.width
                matrixSize: rgbMatrixEditor.previewSize
                matrixData: rgbMatrixEditor.previewData
            }

            // row 3
            RowLayout
            {
                width: editorColumn.colWidth

                RobotoText
                {
                    label: qsTr("Pattern")
                    onWidthChanged:
                    {
                        editorColumn.checkLabelWidth(width)
                        width = Qt.binding(function() { return editorColumn.firstColumnWidth })
                    }
                }
                CustomComboBox
                {
                    Layout.fillWidth: true
                    height: editorColumn.itemsHeight
                    model: rgbMatrixEditor.algorithms
                    currentIndex: rgbMatrixEditor.algorithmIndex
                    onCurrentTextChanged:
                    {
                        rgbMatrixEditor.algorithmIndex = currentIndex
                        rgbParamsLoader.sourceComponent = null
                        if (currentText == "Text")
                            rgbParamsLoader.sourceComponent = textAlgoComponent
                        else if (currentText == "Image")
                            rgbParamsLoader.sourceComponent = imageAlgoComponent
                        else
                            rgbParamsLoader.sourceComponent = scriptAlgoComponent
                    }
                }
            }

            // row 4
            RowLayout
            {
                width: editorColumn.colWidth

                RobotoText
                {
                    label: qsTr("Blend mode")
                    onWidthChanged:
                    {
                        editorColumn.checkLabelWidth(width)
                        width = Qt.binding(function() { return editorColumn.firstColumnWidth })
                    }
                }
                CustomComboBox
                {
                    Layout.fillWidth: true
                    height: editorColumn.itemsHeight

                    ListModel
                    {
                        id: blendModel
                        ListElement { mLabel: qsTr("Default (HTP)"); }
                        ListElement { mLabel: qsTr("Mask"); }
                        ListElement { mLabel: qsTr("Additive"); }
                        ListElement { mLabel: qsTr("Subtractive"); }
                    }
                    model: blendModel
                    //currentIndex: rgbMatrixEditor.currentAlgo
                    //onCurrentIndexChanged: rgbMatrixEditor.currentAlgo = currentIndex
                }
            }

            // row 5
            Row
            {
                width: editorColumn.colWidth
                height: editorColumn.itemsHeight
                spacing: 4

                RobotoText
                {
                    label: qsTr("Colors")
                    visible: rgbMatrixEditor.algoColors > 0 ? true : false
                    onWidthChanged:
                    {
                        editorColumn.checkLabelWidth(width)
                        width = Qt.binding(function() { return editorColumn.firstColumnWidth })
                    }
                }

                Rectangle
                {
                    id: startColButton
                    width: 80
                    height: parent.height
                    radius: 5
                    border.color: scMouseArea.containsMouse ? "white" : UISettings.bgLight
                    border.width: 2
                    color: startColTool.selectedColor
                    visible: rgbMatrixEditor.algoColors > 0 ? true : false

                    MouseArea
                    {
                        id: scMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: startColTool.visible = !startColTool.visible
                    }

                    ColorTool
                    {
                        id: startColTool
                        parent: mainView
                        x: rightSidePanel.x - width
                        y: rightSidePanel.y
                        visible: false
                        closeOnSelect: true
                        selectedColor: rgbMatrixEditor.startColor

                        onColorChanged:
                        {
                            startColButton.color = Qt.rgba(r, g, b, 1.0)
                            rgbMatrixEditor.startColor = startColButton.color
                        }
                    }
                }
                Rectangle
                {
                    id: endColButton
                    width: 80
                    height: parent.height
                    radius: 5
                    border.color: ecMouseArea.containsMouse ? "white" : UISettings.bgLight
                    border.width: 2
                    color: rgbMatrixEditor.hasEndColor ? rgbMatrixEditor.endColor : "transparent"
                    visible: rgbMatrixEditor.algoColors > 1 ? true : false

                    MouseArea
                    {
                        id: ecMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: endColTool.visible = !startColTool.visible
                    }

                    ColorTool
                    {
                        id: endColTool
                        parent: mainView
                        x: rightSidePanel.x - width
                        y: rightSidePanel.y
                        visible: false
                        closeOnSelect: true
                        selectedColor: rgbMatrixEditor.endColor

                        onColorChanged: rgbMatrixEditor.endColor = Qt.rgba(r, g, b, 1.0)
                    }
                }
                IconButton
                {
                    width: parent.height
                    height: parent.height
                    imgSource: "qrc:/cancel.svg"
                    visible: rgbMatrixEditor.algoColors > 1 ? true : false
                    onClicked: rgbMatrixEditor.hasEndColor = false
                }
                // filler
                //Rectangle { Layout.fillWidth: true; height: parent.height; color: "transparent" }
            }

            Rectangle
            {
                width: parent.width
                height: editorColumn.itemsHeight
                visible: rgbParamsLoader.sourceComponent ? true : false

                color: UISettings.bgLight
                RobotoText { label: qsTr("Parameters") }
            }

            Loader
            {
                id: rgbParamsLoader
                width: editorColumn.colWidth
                source: ""
            }
        } // ColumnLayout
    } // Flickable
    ScrollBar { id: sbar; flickable: editorFlickable }

    // *************************************************************
    // Here starts all the Algorithm-specific Component definitions,
    // loaded at runtime depending on the selected algorithm
    // *************************************************************

    // Text Algorithm parameters
    Component
    {
        id: textAlgoComponent
        GridLayout
        {
            columns: 2
            columnSpacing: 5

            // Row 1
            RobotoText { label: qsTr("Text") }
            Rectangle
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight
                color: "transparent"

                Rectangle
                {
                    height: parent.height
                    width: parent.width - fontButton.width - 5
                    radius: 3
                    color: UISettings.bgMedium
                    border.color: "#222"

                    TextInput
                    {
                        id: algoTextEdit
                        anchors.fill: parent
                        anchors.margins: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: rgbMatrixEditor.algoText
                        font.pointSize: 16
                        color: "white"

                        onTextChanged: rgbMatrixEditor.algoText = text
                    }
                }
                IconButton
                {
                    id: fontButton
                    anchors.right: parent.right
                    imgSource: "qrc:/font.svg"

                    onClicked: fontDialog.visible = true

                    FontDialog
                    {
                        id: fontDialog
                        title: qsTr("Please choose a font")
                        //font: wObj ? wObj.font : ""
                        visible: false

                        onAccepted:
                        {
                            console.log("Selected font: " + fontDialog.font)
                            algoTextEdit.font = fontDialog.font
                            algoTextEdit.font.pointSize = 16
                            //wObj.font = fontDialog.font
                        }
                    }
                }
            }

            // Row 2
            RobotoText { label: qsTr("Animation") }
            CustomComboBox
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight

                ListModel
                {
                    id: textAnimModel
                    ListElement { mLabel: qsTr("Letters"); }
                    ListElement { mLabel: qsTr("Horizontal"); }
                    ListElement { mLabel: qsTr("Vertical"); }
                }
                model: textAnimModel
            }

            // Row 3
            RobotoText { label: qsTr("Offset") }
            Rectangle
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight
                color: "transparent"

                Row
                {
                    spacing: 20
                    anchors.fill: parent

                    RobotoText { label: qsTr("X") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }

                    RobotoText { label: qsTr("Y") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }
                }
            }
        }
    }
    // ************************************************************

    // Image Algorithm parameters
    Component
    {
        id: imageAlgoComponent

        GridLayout
        {
            id: imageAlgoGrid
            columns: 2
            columnSpacing: 5

            // Row 1
            RobotoText { label: qsTr("Image") }
            Rectangle
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight
                color: "transparent"

                Rectangle
                {
                    height: parent.height
                    width: parent.width - fontButton.width - 5
                    radius: 3
                    color: UISettings.bgMedium
                    border.color: "#222"
                    clip: true

                    TextInput
                    {
                        id: algoTextEdit
                        anchors.fill: parent
                        anchors.margins: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: rgbMatrixEditor.algoImagePath
                        font.pointSize: 16
                        color: "white"

                        onTextChanged: rgbMatrixEditor.algoImagePath = text
                    }
                }
                IconButton
                {
                    id: fontButton
                    anchors.right: parent.right
                    imgSource: "qrc:/background.svg"

                    onClicked: fileDialog.visible = true

                    FileDialog
                    {
                        id: fileDialog
                        visible: false
                        title: qsTr("Select an image")
                        nameFilters: [ "Image files (*.png *.bmp *.jpg *.jpeg *.gif)", "All files (*)" ]

                        onAccepted: rgbMatrixEditor.algoImagePath = fileDialog.fileUrl
                    }

                }
            }

            // Row 2
            RobotoText { label: qsTr("Animation") }
            CustomComboBox
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight

                ListModel
                {
                    id: imageAnimModel
                    ListElement { mLabel: qsTr("Static"); }
                    ListElement { mLabel: qsTr("Horizontal"); }
                    ListElement { mLabel: qsTr("Vertical"); }
                    ListElement { mLabel: qsTr("Animation"); }
                }
                model: imageAnimModel
            }

            // Row 3
            RobotoText { label: qsTr("Offset") }
            Rectangle
            {
                Layout.fillWidth: true
                height: editorColumn.itemsHeight
                color: "transparent"

                Row
                {
                    spacing: 20
                    anchors.fill: parent

                    RobotoText { label: qsTr("X") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }

                    RobotoText { label: qsTr("Y") }
                    CustomSpinBox
                    {
                        height: parent.height
                    }
                }
            }
        }
    }

    // ************************************************************

    // Script Algorithm parameters
    Component
    {
        id: scriptAlgoComponent

        GridLayout
        {
            id: scriptAlgoGrid
            columns: 2
            columnSpacing: 5

            function addComboBox(propName, model, currentIndex)
            {
                comboComponent.createObject(scriptAlgoGrid,
                               {"propName": propName, "model": model, "currentIndex": currentIndex });
                if (comboComponent.status !== Component.Ready)
                    console.log("Combo component is not ready !!")
            }

            function addSpinBox(propName, min, max, currentValue)
            {
                spinComponent.createObject(scriptAlgoGrid,
                              {"propName": propName, "minimumValue": min, "maximumValue": max, "value": currentValue });
                if (spinComponent.status !== Component.Ready)
                    console.log("Spin component is not ready !!")
            }

            Component.onCompleted:
            {
                rgbMatrixEditor.createScriptObjects(scriptAlgoGrid)
            }
        }
    }

    // Script algorithm combo box property
    Component
    {
        id: comboComponent

        CustomComboBox
        {
            id: sCombo
            Layout.fillWidth: true
            property string propName

            onCurrentTextChanged: rgbMatrixEditor.setScriptStringProperty(propName, currentText)
        }
    }

    // Script algorithm spin box property
    Component
    {
        id: spinComponent

        CustomSpinBox
        {
            id: sSpin
            Layout.fillWidth: true
            property string propName

            onValueChanged: rgbMatrixEditor.setScriptIntProperty(propName, value)
        }
    }

}