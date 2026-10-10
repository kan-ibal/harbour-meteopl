import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4
import "pages"
import "cover"
import "translations.js" as I18n

ApplicationWindow {
    id: appWindow
    initialPage: Qt.resolvedUrl("pages/WeatherPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // Language state: 'pl' (default) or 'en'
    property string currentLanguage: "pl"

    function tr(text, arg1, arg2, arg3) {
        return I18n.getTranslation(text, currentLanguage, arg1, arg2, arg3);
    }

    function toggleLanguage() {
        currentLanguage = (currentLanguage === "pl") ? "en" : "pl";
        saveSettings();
        fetchMeteogram(activeCity, false);
    }

    function setLanguage(lang) {
        currentLanguage = (lang === "en") ? "en" : "pl";
        saveSettings();
        fetchMeteogram(activeCity, false);
    }

    // Global application properties
    property var defaultFavoriteCity: ({
        "name": "Warszawa",
        "row": 406,
        "col": 250,
        "id": 2216,
        "voivodeship": "mazowieckie"
    })

    property var activeCity: defaultFavoriteCity
    
    property string meteogramLocalPath: ""
    property string cacheTimeText: tr("Brak danych")
    property string cacheSizeText: ""
    property bool isCachedForecast: false
    property bool isDownloading: false
    property string activeError: ""
    
    // Sailfish OS cache folder path
    property string cacheDir: StandardPaths.cache + "/harbour-meteopl"

    // Database of favorites managed locally
    property var favoriteCities: []

    // Python executor helper
    Python {
        id: py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("py"));
            importModule('mgram_fetcher', function() {
                console.log("Python backend engine initialized successfully!");
                loadInitialMeteogram();
            });
        }

        onError: {
            console.log("PyOtherSide error: " + trace);
            appWindow.activeError = qsTr("Błąd silnika Python: ") + trace;
        }

        onReceived: {
            console.log("Python event received: " + data);
        }
    }

    function loadInitialMeteogram() {
        py.call('mgram_fetcher.load_settings', [cacheDir], function(resultJson) {
            if (resultJson) {
                try {
                    var settings = JSON.parse(resultJson);
                    if (settings.language) {
                        currentLanguage = settings.language;
                    }
                    if (settings.favoriteCities && Array.isArray(settings.favoriteCities)) {
                        favoriteCities = settings.favoriteCities;
                    }
                    if (settings.defaultFavoriteCity && settings.defaultFavoriteCity.name && settings.defaultFavoriteCity.row && settings.defaultFavoriteCity.col) {
                        defaultFavoriteCity = settings.defaultFavoriteCity;
                        activeCity = defaultFavoriteCity;
                    } else if (favoriteCities.length > 0) {
                        defaultFavoriteCity = favoriteCities[0];
                        activeCity = defaultFavoriteCity;
                    } else if (settings.activeCity && settings.activeCity.name && settings.activeCity.row && settings.activeCity.col) {
                        activeCity = settings.activeCity;
                    }
                } catch(e) {
                    console.log("Error parsing settings: " + e);
                }
            }
            fetchMeteogram(activeCity, false);
        });
    }

    function saveSettings() {
        var data = {
            "language": currentLanguage,
            "favoriteCities": favoriteCities,
            "defaultFavoriteCity": defaultFavoriteCity,
            "activeCity": activeCity
        };
        py.call('mgram_fetcher.save_settings', [cacheDir, JSON.stringify(data)], function(res) {
            console.log("Settings saved.");
        });
    }

    function fetchMeteogram(city, forceRefresh) {
        if (isDownloading) return;
        isDownloading = true;
        activeError = "";
        
        py.call('mgram_fetcher.fetch', [city.id || 0, city.row || 0, city.col || 0, cacheDir, forceRefresh, currentLanguage], function(resultJson) {
            isDownloading = false;
            var result = JSON.parse(resultJson);
            if (result.error) {
                activeError = result.error;
                meteogramLocalPath = "";
            } else {
                meteogramLocalPath = "file://" + result.filePath;
                isCachedForecast = result.isCached;
                
                var date = new Date(result.fetchedAt * 1000);
                cacheTimeText = date.toLocaleTimeString() + " (" + date.toLocaleDateString() + ")";
                cacheSizeText = result.size;
                
                // Keep coordinates updated
                activeCity.row = result.row;
                activeCity.col = result.col;

                saveSettings();
            }
        });
    }

    function toggleFavorite(city) {
        var foundIdx = -1;
        for (var i = 0; i < favoriteCities.length; i++) {
            if (favoriteCities[i].row === city.row && favoriteCities[i].col === city.col) {
                foundIdx = i;
                break;
            }
        }
        if (foundIdx >= 0) {
            favoriteCities.splice(foundIdx, 1);
            if (defaultFavoriteCity.row === city.row && defaultFavoriteCity.col === city.col) {
                defaultFavoriteCity = favoriteCities.length > 0 ? favoriteCities[0] : ({ "name": "Warszawa", "row": 406, "col": 250, "id": 2216, "voivodeship": "mazowieckie" });
            }
        } else {
            favoriteCities.push(city);
        }
        favoriteCities = favoriteCities;
        saveSettings();
    }

    function setDefaultFavoriteCity(city) {
        defaultFavoriteCity = city;
        if (!isCityFavorite(city)) {
            favoriteCities.push(city);
            favoriteCities = favoriteCities;
        }
        saveSettings();
    }

    function isCityFavorite(city) {
        for (var i = 0; i < favoriteCities.length; i++) {
            if (favoriteCities[i].row === city.row && favoriteCities[i].col === city.col) {
                return true;
            }
        }
        return false;
    }

    function isDefaultCity(city) {
        return defaultFavoriteCity.row === city.row && defaultFavoriteCity.col === city.col;
    }
}
