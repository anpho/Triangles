/*
 * Copyright (c) 2011-2014 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.0
import bb.platform 1.0
import bb.system 1.0
import bb 1.0
Page {
    actions: [
        ActionItem {
            imageSource: "asset:///icons/setas.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            title: qsTr("Set wallpaper")
            onTriggered: {
                hs.setWallpaper(image.imageSource)
            }
        },
        ActionItem {
            imageSource: "asset:///icons/ref.png"
            title: qsTr("Generate")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                refresh();
            }
        },

        ActionItem {
            imageSource: "asset:///icons/share.png"
            title: qsTr("Share")
            ActionBar.placement: ActionBarPlacement.InOverflow
            onTriggered: {
                _app.shareFile(image.imageSource)
            }
        },

        ActionItem {
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///icons/save.png"
            title: qsTr("Save To Album")
            onTriggered: {
                var filename = _app.saveToAlbum();
                if (filename.length > 0) {
                    savesucc.fn = filename;
                    savesucc.show()
                } else {
                    savefail.show();
                }
            }
            attachedObjects: [
                SystemToast {
                    id: savefail
                    body: qsTr("Save Failed, Can't Access File System.")
                },
                SystemToast {
                    property string fn: ""
                    id: savesucc
                    body: qsTr("Saved.")
                    button.label: qsTr("Open")
                    onFinished: {
                        console.log(value)
                        if (value == 1) {
                            Qt.openUrlExternally("file://" + fn)
                        }
                    }
                }
            ]
        },
        ActionItem {
            imageSource: "asset:///icons/set.png"
            title: qsTr("Customize")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                settingspane.visible = ! settingspane.visible;
            }
        }
    ]
    actionBarVisibility: ChromeVisibility.Visible
    Container {
        layout: DockLayout {

        }
        background: Color.Black
        ImageView {
            id: image
            scalingMethod: ScalingMethod.Fill
            verticalAlignment: VerticalAlignment.Fill
            horizontalAlignment: HorizontalAlignment.Fill
        }
        ActivityIndicator {
            id: act
            running: true
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            preferredWidth: 120.0
            preferredHeight: 120.0
            visible: false

        }
        Container {
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            //preferredHeight: DisplayInfo.height * .9
            preferredWidth: DisplayInfo.width * .9
            ScrollView {
                id: settingspane
                visible: true
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                preferredWidth: DisplayInfo.width
                Container {
                    leftPadding: 10.0
                    rightPadding: 10.0
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    topPadding: 10.0
                    bottomPadding: 10.0
                    background: Color.create("#ff383837")
                    Header {
                        title: qsTr("Customize")
                    }
                    Label {
                        text: qsTr("Cell Size: ") + parseInt(cellsize.value) + "px"
                    }
                    Label {
                        text: qsTr("This sets how large the generated cells should be, default is 150px.")
                        multiline: true
                        textStyle.fontStyle: FontStyle.Italic
                        textStyle.fontSize: FontSize.Small

                    }
                    Slider {
                        horizontalAlignment: HorizontalAlignment.Fill
                        value: 150.0
                        fromValue: 40.0
                        toValue: 720.0
                        id: cellsize
                    }
                    Label {
                        text: qsTr("Cell Padding: ") + parseInt(cellpadding.value) + "px"
                    }
                    Label {
                        multiline: true
                        text: qsTr("This sets the minimum distance between each point, default is Cell Size * 0.1, Max is Cell Size * 0.5.")
                        textStyle.fontStyle: FontStyle.Italic
                        textStyle.fontSize: FontSize.Small

                    }
                    Slider {
                        id: cellpadding
                        horizontalAlignment: HorizontalAlignment.Fill
                        value: cellsize.value * 0.1
                        fromValue: 0
                        toValue: cellsize.value * 0.5
                    }
                    Divider {

                    }
                    Container {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight

                        }
                        Button {
                            horizontalAlignment: HorizontalAlignment.Center
                            text: qsTr("Default")
                            onClicked: {
                                cellsize.value = 150;
                                cellpadding.value = 15;
                                settingspane.visible = false
                                refresh();
                            }
                        }
                        Button {
                            horizontalAlignment: HorizontalAlignment.Center
                            text: qsTr("Generate")
                            onClicked: {
                                settingspane.visible = false
                                refresh();
                            }
                        }

                    }

                }
            }
        }
    }
    function conv() {
        image.imageSource = "asset:///b.png";
        image.imageSource = _app.updateImage();
        console.log(image.imageSource);
    }
    function uri2pngpath(uri) {
        var fileContent = Qt.atob(uri.split('base64,')[1]);
        if (_app.writeTextFile("data/background.svg", fileContent)) {
            console.log("file write OK.");
            conv();
        } else {
            console.log("File write error.");
        }
    }
    function refresh() {
        console.log("Refreshing");
        act.visible = true;
        image.visible = false;
        settingspane.visible = false;
        try {
            tri.postMessage(JSON.stringify({
                        width: DisplayInfo.width,
                        height: DisplayInfo.height,
                        csize: cellsize.value,
                        cpad: cellpadding.value
                    }));

        } catch (e) {

        }
    }
    attachedObjects: [
        WebView {
            id: tri
            url: "local:///assets/trianglify/index.html"
            onMessageReceived: {
                console.log("Got, update image");
                var svguri = message.data;
                uri2pngpath(svguri);
                image.visible = true;
                act.visible = false;
            }
            settings.webInspectorEnabled: true
            onCreationCompleted: {

            }

        },
        HomeScreen {
            id: hs
        }
    ]
    onCreationCompleted: {
    }
    id: ro
    Menu.definition: MenuDefinition {
        helpAction: HelpActionItem {
            onTriggered: {
                about.open()
            }
            attachedObjects: [
                Sheet {
                    attachedObjects: [
                        ApplicationInfo {
                            id: ap
                        }
                    ]
                    id: about
                    Page {
                        titleBar: TitleBar {
                            title: qsTr("about")
                            dismissAction: ActionItem {
                                title: qsTr("Back")
                                onTriggered: {
                                    about.close();
                                }
                            }
                        }
                        ScrollView {
                            Container {
                                leftPadding: 10
                                rightPadding: 10
                                topPadding: 10
                                bottomPadding: 10
                                Divider {
                                }
                                ImageView {
                                    imageSource: "asset:///114.png"
                                    horizontalAlignment: HorizontalAlignment.Center
                                    topMargin: 50
                                    bottomMargin: 50
                                }
                                Label {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    text: qsTr("Triangles ") + ap.version
                                }
                                Label {
                                    horizontalAlignment: HorizontalAlignment.Center
                                    text: qsTr("by anpho")
                                }
                                Header {
                                    title: qsTr("Credits")
                                }
                                Label {
                                    text: qsTr("Trianglify.js which is used to generate the beautiful triangles is created by <a href=\"http://qrohlf.com\">Quinn Rohlf</a>,under GPLv3 license.")
                                    multiline: true
                                    textFormat: TextFormat.Html
                                }
                                Label {
                                    text: qsTr("D3.js created by <a href=\"http://d3js.org/\">Mike Bostock</a>, under BSD license.")
                                    multiline: true
                                    textFormat: TextFormat.Html
                                }
                                Label {
                                    text: qsTr("App Icon is created by <a href=\"http://www.danieledesantis.net\">Daniele De Santis</a>, under CC Attribution 4.0 license.")
                                    multiline: true
                                    textFormat: TextFormat.Html
                                }
                                Label {
                                    text: qsTr("Action bar icons are created by <a href=\"http://graphicloads.com/\">graphicloads</a>, under Creative Commons Attribution-Share Alike 3.0 Unported License.")
                                    multiline: true
                                    textFormat: TextFormat.Html
                                }
                            }
                        }
                    }
                }
            ]

        }
        actions: [
            ActionItem {
                onTriggered: {
                    Qt.openUrlExternally("http://appworld.blackberry.com/webstore/content/59945956")
                }
                title: qsTr("Review")
                imageSource: "asset:///icons/ic_edit_favorite.png"
            }
        ]
    }
}
