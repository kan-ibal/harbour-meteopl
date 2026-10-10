import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: settingsPage
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentCol.height + Theme.paddingLarge * 2

        Column {
            id: contentCol
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: tr("Ustawienia")
                description: tr("Zarządzanie ulubionymi i domyślnym miastem")
            }

            // Section 1: Default Startup City
            SectionHeader {
                text: tr("Domyślna miejscowość startowa")
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeMedium

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Label {
                        text: defaultFavoriteCity.name + (defaultFavoriteCity.voivodeship ? " (" + defaultFavoriteCity.voivodeship + ")" : "")
                        color: Theme.highlightColor
                        font.bold: true
                        font.pixelSize: Theme.fontSizeMedium
                    }

                    Label {
                        text: (currentLanguage === "pl" ? ("Siatka UM: R:" + defaultFavoriteCity.row + " C:" + defaultFavoriteCity.col) : ("UM Grid: R:" + defaultFavoriteCity.row + " C:" + defaultFavoriteCity.col)) + " • " + tr("Miejscowość domyślna")
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.secondaryColor
                    }
                }
            }

            // Section 2: Manage Favorites & Choose Default
            SectionHeader {
                text: tr("Ulubione Miejsca i Wybór Domyślnego")
            }

            Column {
                width: parent.width
                visible: favoriteCities.length > 0

                Repeater {
                    model: favoriteCities
                    delegate: ListItem {
                        width: parent.width
                        contentHeight: Theme.itemSizeLarge

                        menu: ContextMenu {
                            MenuItem {
                                text: tr("Ustaw jako domyślną")
                                visible: !isDefaultCity(modelData)
                                onClicked: setDefaultFavoriteCity(modelData)
                            }
                            MenuItem {
                                text: tr("Usuń z ulubionych")
                                onClicked: toggleFavorite(modelData)
                            }
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.horizontalPageMargin
                            anchors.right: actionButtonRow.left
                            anchors.rightMargin: Theme.paddingMedium
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Row {
                                spacing: Theme.paddingSmall
                                Image {
                                    source: isDefaultCity(modelData) ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: Theme.iconSizeSmall
                                    height: Theme.iconSizeSmall
                                }
                                Label {
                                    text: modelData.name + (modelData.voivodeship ? " (" + modelData.voivodeship + ")" : "")
                                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                                    font.bold: isDefaultCity(modelData)
                                    elide: Text.ElideRight
                                    width: 260
                                }
                            }

                            Label {
                                text: (currentLanguage === "pl" ? ("Siatka UM: R:" + modelData.row + " C:" + modelData.col) : ("UM Grid: R:" + modelData.row + " C:" + modelData.col)) +
                                      (isDefaultCity(modelData) ? (" • " + tr("Domyślna")) : "")
                                font.pixelSize: Theme.fontSizeTiny
                                color: Theme.secondaryColor
                            }
                        }

                        Row {
                            id: actionButtonRow
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.horizontalPageMargin
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.paddingSmall

                            Button {
                                text: tr("Domyślna")
                                enabled: !isDefaultCity(modelData)
                                font.pixelSize: Theme.fontSizeTiny
                                preferredWidth: 120
                                onClicked: {
                                    setDefaultFavoriteCity(modelData);
                                }
                            }

                            IconButton {
                                icon.source: "image://theme/icon-m-delete"
                                onClicked: {
                                    toggleFavorite(modelData);
                                }
                            }
                        }
                    }
                }
            }

            Label {
                text: tr("Brak ulubionych miast. Dodaj je podczas przeglądania meteogramu.")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - Theme.paddingLarge * 2
                horizontalAlignment: Text.AlignHCenter
                visible: favoriteCities.length === 0
            }
        }
    }
}
