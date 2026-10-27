# Google Play – Punktezähler für Tutto

Minimal-Checkliste für die Veröffentlichung. Alles zum Kopieren, Dateien liegen in `store/`.

## 1. Dateien
| Was | Datei / Wert |
|---|---|
| App-Bundle (Upload) | `PunktezaehlerTutto.aab` – bauen mit `android/build-aab.ps1` |
| App-Icon 512×512 | `store/icon-512.png` |
| Feature-Grafik 1024×500 | `store/feature-graphic.png` |
| Handy-Screenshots (1080×1920) | `store/screenshots/1-spielstand.png` … `4-spieler.png` |
| Datenschutzerklärung | https://artwokey.github.io/Tutto/datenschutz.html |
| Paketname (dauerhaft!) | `com.rene.tutto` |
| Upload-Schlüssel | `C:\WMBuild\keys\tutto-upload.jks` (Passwort in `tutto-upload.txt` daneben) – **sichern, nicht ins Repo** |

## 2. Store-Eintrag
**App-Name** (max. 30):
```
Punktezähler für Tutto
```
**Kurzbeschreibung** (max. 80):
```
Punkteblock für das Würfelspiel Tutto: Punkte, Tabelle und Sieger bei 6.000.
```
**Vollständige Beschreibung:**
```
Nie wieder Zettel und Stift: Der Punktezähler für das Würfelspiel Tutto rechnet für euch mit.

• Mitspieler eintragen und den Beginner per Fingertipp oder Zufall wählen
• Punkte pro Zug eingeben – mit Schnelltasten +50 bis +1000
• Gepatzt, Aussetzer, Plus/Minus (+1000, der Führende verliert 1000) und Kleeblatt mit einem Tipp
• Immer im Blick: wer führt, mit welchem Vorsprung und wie viel bis 6.000 fehlt
• Übersichtliche Punktetabelle mit Zwischensummen für jede Runde
• Rückgängig-Taste für Vertipper
• Siegerehrung mit Endstand, Revanche mit einem Tipp
• Spielstand bleibt erhalten, auch wenn die App geschlossen wird

Ohne Werbung, ohne Anmeldung, ohne Internet, ohne Datensammlung.

Hinweis: Inoffizieller Punktezähler, nicht verbunden mit dem Hersteller des Spiels „Tutto“. Alle Marken gehören ihren jeweiligen Inhabern.
```
- **App oder Spiel:** App · **Kategorie:** Unterhaltung
- **Kontakt-E-Mail:** r.mertens@gmx.de (wird im Store öffentlich angezeigt)
- **Kostenlos**, keine Werbung, keine In-App-Käufe

## 3. App-Inhalte (Play Console → Richtlinien → App-Inhalte)
| Formular | Antwort |
|---|---|
| Datenschutzerklärung | URL oben |
| App-Zugriff | Alle Funktionen ohne Anmeldung verfügbar |
| Werbung | Nein |
| Einstufung (IARC-Fragebogen) | Kategorie „Alle anderen App-Typen“, überall **Nein** → USK 0 / PEGI 3 |
| Zielgruppe | **13 Jahre und älter** (unter 13 löst die strengeren Familien-Richtlinien aus) |
| Datensicherheit | Erhebt/teilt Daten: **Nein** · keine Datentypen |
| Behörden-, Finanz-, Gesundheits-, News-App | jeweils Nein |

## 4. Ablauf
1. App in der Play Console anlegen (Name, Sprache Deutsch, App, kostenlos).
2. Abschnitt 3 ausfüllen, Store-Eintrag aus Abschnitt 2 + Grafiken hochladen.
3. **Play App Signing** aktiviert lassen (Standard) – Google verwaltet den App-Schlüssel, wir signieren nur mit dem Upload-Schlüssel.
4. AAB in einen Test-Track hochladen.
   **Privates Entwicklerkonto (nach Nov. 2023 erstellt):** Vor der Produktion ist ein geschlossener Test mit
   mindestens **12 Testern über 14 Tage** Pflicht. Danach Produktionszugriff beantragen.
5. Release für Produktion einreichen → Prüfung durch Google (meist wenige Tage).

## 5. Neue Version
`VERSION` in `www/index.html`, `versionCode` (+1) und `versionName` in `android/app/AndroidManifest.xml`,
`CHANGELOG.md` ergänzen → `android/build-aab.ps1` → AAB in der Play Console hochladen.
Ziel-API: aktuell 36 (Google hebt die Pflicht jährlich im August an).
