import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2

Page {
    id: gridPage
    allowedOrientations: defaultAllowedOrientations

    property var gridCities: []
    property bool isLocating: false
    property string gpsStatusText: ""
    property string gpsLatitude: ""
    property string gpsLongitude: ""

    PositionSource {
        id: src
        updateInterval: 1000
        active: false
        preferredPositioningMethods: PositionSource.AllPositioningMethods

        onPositionChanged: {
            var coord = src.position.coordinate;
            console.log("Coordinate:", coord.longitude, coord.latitude);
            if (coord.isValid && coord.latitude !== 0 && coord.longitude !== 0) {
                isLocating = false;
                src.active = false;
                var latStr = (coord.latitude >= 0 ? coord.latitude.toFixed(4) + "°N" : Math.abs(coord.latitude).toFixed(4) + "°S");
                var lonStr = (coord.longitude >= 0 ? coord.longitude.toFixed(4) + "°E" : Math.abs(coord.longitude).toFixed(4) + "°W");
                gpsLatitude = latStr;
                gpsLongitude = lonStr;
                gpsStatusText = latStr + ", " + lonStr;

                py.call("mgram_fetcher.gps", [coord.latitude, coord.longitude, currentLanguage], function (resultJson) {
                    try {
                        var res = JSON.parse(resultJson);
                        if (res.row && res.col) {
                            rowInput.text = res.row.toString();
                            colInput.text = res.col.toString();
                            gpsStatusText = latStr + ", " + lonStr + " → Row: " + res.row + ", Col: " + res.col;
                        }
                    } catch (e) {
                        console.log("Error parsing GPS result: " + e);
                    }
                });
            }
        }

        onSourceErrorChanged: {
            if (sourceError !== PositionSource.NoError) {
                isLocating = false;
                src.active = false;
                gpsStatusText = tr("Nie udało się ustalić pozycji GPS.");
            }
        }
    }

    Component.onCompleted: {
        loadGridCities();
    }

    function loadGridCities() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("../data/grid_cities.json"), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) {
                    try {
                        gridCities = JSON.parse(xhr.responseText);
                    } catch (e) {
                        console.log("Error parsing grid_cities.json: " + e);
                    }
                }
            }
        };
        xhr.send();
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: isLocating ? tr("Pobieranie pozycji GPS...") : tr("Pobierz pozycję GPS")
                enabled: !isLocating
                onClicked: {
                    isLocating = true;
                    gpsStatusText = tr("Pobieranie pozycji GPS...");
                    src.active = true;
                    src.update();
                }
            }
        }

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: tr("Siatka Współrzędnych")
                description: tr("Ręczny dobór punktu modelu UM")
            }

            Label {
                text: tr("Wprowadź współrzędne wiersza (X) i kolumny (Y) siatki numerycznej meteo.pl.")
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
            }

            Label {
                visible: isLocating || gpsStatusText.length > 0 || gpsLatitude.length > 0
                text: {
                    if (isLocating) {
                        return tr("Pobieranie pozycji GPS...");
                    }
                    if (gpsLatitude.length > 0 && gpsLongitude.length > 0) {
                        return (currentLanguage === "pl" ? "Lokalizacja GPS: " : "GPS Location: ") + gpsLatitude + ", " + gpsLongitude;
                    }
                    if (gpsStatusText.length > 0) {
                        if (gpsStatusText.indexOf("°") !== -1) {
                            return (currentLanguage === "pl" ? "Lokalizacja GPS: " : "GPS Location: ") + gpsStatusText;
                        }
                        return gpsStatusText;
                    }
                    return "";
                }
                width: parent.width - Theme.paddingLarge * 2
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: rowInput
                width: parent.width
                label: tr("Wiersz (Row)")
                placeholderText: tr("np. 406 (Zakres: 100 - 650)")
                text: activeCity.row.toString()
                inputMethodHints: Qt.ImhDigitsOnly
            }

            TextField {
                id: colInput
                width: parent.width
                label: tr("Kolumna (Column)")
                placeholderText: tr("np. 250 (Zakres: 10 - 500)")
                text: activeCity.col.toString()
                inputMethodHints: Qt.ImhDigitsOnly
            }

            Button {
                text: tr("Zastosuj współrzędne")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    var r = parseInt(rowInput.text, 10);
                    var c = parseInt(colInput.text, 10);
                    
                    if (!isNaN(r) && !isNaN(c) && r >= 100 && r <= 650 && c >= 10 && c <= 500) {
                        var resolvedName = (currentLanguage === "pl" ? "Siatka [" : "Grid [") + r + ", " + c + "]";
                        for (var i = 0; i < gridCities.length; i++) {
                            if (parseInt(gridCities[i].row, 10) === r && parseInt(gridCities[i].col, 10) === c) {
                                resolvedName = gridCities[i].name;
                                break;
                            }
                        }

                        activeCity = {
                            "name": resolvedName,
                            "row": rowInput.text,
                            "col": colInput.text,
                            "id": 0
                        };
                        console.log("gridData", activeCity.row);
                        fetchMeteogram(activeCity, false);
                        pageStack.pop();
                    } else {
                        console.log("Nieprawidłowe współrzędne.");
                    }
                }
            }

            SectionHeader {
                text: tr("Popularne punkty kontrolne")
            }

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Repeater {
                    model: gridCities

                    delegate: BackgroundItem {
                        width: parent.width
                        height: Theme.itemSizeSmall

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.horizontalPageMargin
                            anchors.rightMargin: Theme.horizontalPageMargin
                            spacing: Theme.paddingLarge

                            Label {
                                text: modelData.name
                                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: (currentLanguage === "pl" ? "Wiersz: " : "Row: ") + modelData.row + (currentLanguage === "pl" ? " Kol: " : " Col: ") + modelData.col
                                color: Theme.secondaryColor
                                font.pixelSize: Theme.fontSizeTiny
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        onClicked: {
                            rowInput.text = modelData.row.toString();
                            colInput.text = modelData.col.toString();
                        }
                    }
                }
            }
        }
    }
}
