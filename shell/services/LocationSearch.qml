pragma Singleton

import "../Esp.js" as Es
import QtQuick
import Quickshell
import Caelestia
import Caelestia.Config

Singleton {
    id: root
    property bool loading: false
    property var results: []
    property string errorText: ""
    property int generation: 0

    function search(query: string): void {
        const token = ++generation;
        results = [];
        errorText = "";
        const term = query.trim();
        if (term.length < 2) {
            loading = false;
            errorText = Es.tr("Enter at least two characters.");
            return;
        }
        loading = true;
        const language = (GlobalConfig.general.language || Qt.locale().name).split(/[_-]/)[0];
        const url = "https://geocoding-api.open-meteo.com/v1/search?name=" + encodeURIComponent(term)
            + "&count=8&language=" + encodeURIComponent(language) + "&format=json";
        Requests.get(url, text => {
            if (token !== root.generation) return;
            try {
                const response = JSON.parse(text);
                if (response.error) throw new Error(response.reason);
                root.results = (response.results || []).filter(place =>
                    Number.isFinite(place.latitude) && Number.isFinite(place.longitude));
                if (!root.results.length) root.errorText = Es.tr("No matching cities. Try another name.");
            } catch (error) {
                root.errorText = Es.tr("The city search returned an invalid response.");
            }
            root.loading = false;
        }, error => {
            if (token !== root.generation) return;
            root.errorText = Es.tr("Unable to search for cities. Check your connection and try again.");
            root.loading = false;
        });
    }

    function clear(): void {
        generation++;
        loading = false;
        results = [];
        errorText = "";
    }
}
