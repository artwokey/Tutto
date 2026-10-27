# Punktezähler für Tutto 🎲

Der Punktezähler für das Würfelspiel **Tutto** – als Android-App. Wer zuerst **6.000 Punkte** hat, gewinnt.

> Inoffizieller Punktezähler, nicht verbunden mit dem Hersteller des Spiels „Tutto“. Alle Marken gehören ihren jeweiligen Inhabern.

## Funktionen
- Mitspieler in Sitzreihenfolge eintragen (umsortieren, entfernen)
- Beginner aus einer Übersicht antippen oder auslosen
- Punkte pro Zug eintragen (Schnelltasten +50 … +1000, nur 50er-Schritte)
- **Gepatzt** (0 Punkte), **Aussetzer** (Spieler setzt aus), **Plus/Minus** (+1000, der Führende verliert 1000), **Kleeblatt** (sofortiger Sieg)
- Führenden-Anzeige mit Vorsprung und Fortschrittsbalken bis 6.000
- Punktetabelle pro Runde mit Zwischensummen
- Rückgängig, Gewinner-Bildschirm mit Konfetti, Revanche
- Spielstand bleibt beim Schließen der App erhalten

## Installation
Die aktuelle `Tutto.apk` gibt es unter [Releases](https://github.com/artwokey/Tutto/releases).
Auf dem Handy die Installation aus unbekannten Quellen erlauben und die APK öffnen.

## Aufbau
| Pfad | Inhalt |
|---|---|
| `www/index.html` | die komplette App (HTML, CSS, JavaScript) |
| `android/app/` | schlanke WebView-Hülle (Manifest, `MainActivity.java`, Icons) |
| `android/build-apk.ps1` | baut die APK ohne Gradle (aapt → javac → d8 → zipalign → apksigner) |
| `android/build-aab.ps1` | baut das signierte App-Bundle (.aab) für Google Play |
| `android/make-assets.ps1` | erzeugt Launcher-Icons, Store-Icon und Feature-Grafik |
| `store/` | Grafiken und Screenshots für Google Play, Anleitung in [STORE.md](STORE.md) |
| `docs/` | Datenschutzerklärung (GitHub Pages) |

Zum Bauen wird eine lokale Toolchain mit JDK 17, Android build-tools 34 und android-34 benötigt (Pfade oben im Build-Skript).
Zum Testen im Browser reicht es, `www/index.html` über einen lokalen Webserver zu öffnen.

## Versionierung
Version steht in `www/index.html` (`VERSION`) und `android/app/AndroidManifest.xml` (`versionName`/`versionCode`).
Jede Version bekommt einen Git-Tag `vX.Y.Z` und ein Release mit der APK. Änderungen: siehe [CHANGELOG.md](CHANGELOG.md).
