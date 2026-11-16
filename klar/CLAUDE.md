# KLAR – Modernes Interface für das Keithley 199 (Upgrade-Platine)

Diese App steuert das Keithley 199 **mit der neuen Digitalplatine** (PIC32, eigene
Firmware in diesem Repo), zeigt Messwerte live an, analysiert und loggt sie.
Das visuelle Design ist **fertig** und liegt in `design/`. Halte dich exakt daran.

> Angepasst am 2026-11-16: Das ursprüngliche Paket ging von einem originalen 199
> mit GPIB aus. Die Upgrade-Platine hat **kein GPIB**, sondern eine serielle
> Schnittstelle mit eigenem Zeilenprotokoll. Alles zu GPIB/PyVISA/Adaptern ist
> gestrichen; maßgeblich ist `../insturctions/remote-protocol.md`.

## Design-Quellen (verbindlich für Aussehen und Aufbau)

| Datei | Inhalt |
|---|---|
| `design/tokens.css` | Alle Farben, Schriften, Radien, Abstände als CSS-Variablen. **Keine anderen Farben verwenden.** |
| `design/screens/Main.reference.html` | Desktop · Messen (Hauptbildschirm) |
| `design/screens/Analyse.reference.html` | Desktop · Analyse mit Bereichsauswahl + Statistik |
| `design/screens/Touch.reference.html` | Touch-Panel 1280×720 (dunkel) |
| `design/screens/Mobile.reference.html` | Handy-Ansicht 390×844 |
| `design/screens/Connect.reference.html` | Verbindungsdialog „Gerät gefunden“ (Inhalt anpassen, siehe unten) |
| `design/screens/System.reference.html` | Designprinzipien, Farben, Typo, Bausteine |
| `design/screenshots/` | (optional) Screenshots der Entwürfe – haben Vorrang bei Unklarheiten |

Die `*.reference.html` stammen aus einem Design-Tool und laufen nicht eigenständig
(`support.js`, `<x-dc>`, `<sc-for>`, `{{platzhalter}}`). Lies sie als Spezifikation für
Layout, Abstände und Texte. Beispieldaten (Sinus + Rauschen) durch echte Messwerte
ersetzen. **Texte und Werte, die dem Gerät widersprechen, nach der Liste
„Abweichungen vom Entwurf“ unten anpassen.**

## Designprinzipien (nicht verhandelbar)

1. **Der Messwert ist der Held**: größte Fläche, JetBrains Mono, `tabular-nums`, Einheit kleiner daneben. Nichts darf beim Aktualisieren springen.
2. **Modi statt Parameter**: „Schnell / Standard / Präzise“ bündeln Integrationszeit, Filter und Stellenzahl (Zuordnung unten).
3. **Statistik folgt der Auswahl**: Bereich im Diagramm ziehen → Panel rechts zeigt Mittelwert, Min, Max, σ, Δ, Drift, p-p nur für die Auswahl.
4. **Ein Akzent, eine Bedeutung**: Grün = aktiv/gewählt/ok. Orange nur für Hinweise. Keine weiteren Signalfarben.
5. **Verbinden ohne Konfiguration**: serielle Ports automatisch durchsuchen, mit `*IDN?` und einer Testmessung bestätigen. Manuelles (Port wählen) nur unter „Erweitert“.
6. **Gleiche Struktur, jede Größe**: Desktop, Touch-Panel und Handy teilen Menüpunkte (Messen, Analyse, Logger, Scanner-Kanäle, Einstellungen, Hinweise) und Begriffe. Touch-Ziele ≥ 44 px.

## Architektur

```
backend/   Python 3.11+
  instrument/k199.py          Treiber für das Zeilenprotokoll (remote-protocol.md)
  instrument/transport.py     pyserial (115200 8N1) | Simulator
  server.py                   FastAPI + WebSocket: streamt Messwerte, nimmt Befehle an
  logger.py                   CSV-Logging
frontend/  Vite + React + TypeScript
  src/styles/tokens.css       = design/tokens.css
  src/screens/Measure.tsx     aus Main.reference.html
  src/screens/Analyse.tsx     aus Analyse.reference.html
  src/screens/Connect.tsx     aus Connect.reference.html
  src/components/             Reading, FunctionSegment, RangeChips, ModeCard, StatGrid, TrendChart, LimitBar
  Diagramme: uPlot (schnell, viele Punkte, Bereichsauswahl per Drag)
```

- **Vorhandene Referenz:** `../tools/k199_app.py` spricht das Protokoll bereits
  vollständig (Portsuche per `*IDN?`, Zeilen-Parser, Neustart-Erkennung über
  `K199 READY`, Verlauf im Speicher, CSV, Simulator `SimPort`). Treiber, Parser und
  Simulator von dort übernehmen statt neu zu erfinden.
- Ein **Simulator-Transport** ist Pflicht (UI ohne Hardware entwickeln und testen).
- Die App soll im LAN auch auf Tablet/Handy laufen: Server auf `0.0.0.0` lauschen
  lassen (nur auf Wunsch, Standard `127.0.0.1`), Befehls-Endpunkte gegen fremde
  Origins absichern.
- Dunkler Modus = Touch-Panel-Palette (`--panel-*`).

## Gerät: Keithley 199 mit Upgrade-Platine

- **Schnittstelle:** USB-TTL-Wandler (CH340) an P8/P9 der Platine, 115200 Baud, 8N1,
  Zeilenende LF. Unter macOS `/dev/cu.usbserial-*`. Kein GPIB, keine Adresse.
- **Protokoll:** `../insturctions/remote-protocol.md` ist verbindlich. Kurzfassung:
  - Befehle: `*IDN?` `*RST` `STAT?` `READ?` `STREAM 0|1` `FUNC` `RANG` `RANG?` `FILT`
    `DIG` `ZERO` `DB` `TRIG` `*TRG` `CHAN` `SCAN` `SPEED` `LINE` `LOCK` `HOLD` `KEY` `LOCAL`.
  - Messwert: `R,<ms>,<wert>,<roh>,<funktion>,<bereich>,<flags>,<kanal>`.
  - Zustand: `S,…` nach jeder Änderung (auch durch Tasten am Gerät und Autorange).
  - Nach Reset sendet das Gerät `K199 READY` → Stream neu einschalten.
- **Funktionen:** `DCV`, `ACV`, `DCA`, `ACA`, `OHM2`, `OHM4`. dB ist **keine eigene
  Funktion**, sondern ein Schalter (`DB 1`) bei `ACV`/`ACA` (Bezug 1 V bzw. 1 mA).
- **Bereiche:** immer mit `RANG?` vom Gerät holen (Endwerte), nie fest im Frontend.
  Stand heute: V 300 mV/3 V/30 V/300 V, A 30 mA/3 A, Ω 300 Ω/3 kΩ/30 kΩ/300 kΩ/3 MΩ.
- **Messrate:** aus den `<ms>`-Zeitstempeln berechnen und anzeigen
  (heute ca. 9/s Standard, ca. 21/s Schnell, bei Filter entsprechend gemittelt).
- **Kennung/Version:** `*IDN?` → `KEITHLEY,199-UPGRADE,0,<Build-Datum>`. Statt
  „Firmware B13“ das Build-Datum anzeigen.

### Messmodi → Befehle

| Modus | Befehle | Bedeutung |
|---|---|---|
| Schnell | `SPEED FAST` `FILT 0` `DIG 4` | ¼ Netzperiode Integration, 4½ Stellen (Kalibrierung gilt, geprüft 2026-11-16; keine Brummunterdrückung) |
| Standard | `SPEED LINE` `FILT 0` `DIG 5` | 1 Netzperiode (Brummunterdrückung), 5½ Stellen |
| Präzise | `SPEED LINE` `FILT 1` `DIG 6` | dazu Filter über 100 Wandlungen, 6½ Stellen |

Der aktive Modus wird aus der `S`-Zeile abgeleitet (Feld speed/filter/digits); passt
keine Kombination, „Benutzerdefiniert“ anzeigen.

## Abweichungen vom Entwurf (beim Nachbau ändern)

- **Funktionsleiste:** sechs Felder V⎓, V∼, Ω, A⎓, A∼, **Ω 4W** statt dB.
  dB als Schalter neben dem Messwert, nur bei V∼/A∼ aktiv.
- **Bereichs-Chips:** aus `RANG?` erzeugen; Ω hat zusätzlich 3 MΩ.
- **Modus-Karten:** Texte nach der Tabelle oben (Präzise = 6½ Stellen, Tag „Filter“
  statt „S1 P1“; Tags allgemein ohne GPIB-Codes, z. B. „¼ NPLC“, „1 NPLC“).
- **„live · 5 Messungen/s“:** echte Messrate einsetzen.
- **Kopfbereich:** „UsbGpib · GPIB-Adresse 26“ → Portname (z. B. „USB-Seriell · cu.usbserial-111110“);
  „Firmware B13“ → Build-Datum.
- **Hold:** `HOLD 1|0` (Anzeige am Gerät steht, Messwerte laufen weiter mit Flag 64;
  das Frontend hält seine Großanzeige ebenfalls an).
- **Nullen (REL):** `ZERO 1|0`, Bezug = letzter Messwert.
- **Verbindungsdialog (Connect):** statt Adapter/VISA-Adresse:
  „Port: /dev/cu.usbserial-…“, „Kennung: KEITHLEY 199-UPGRADE, Build …“,
  „Testmessung: +1.024381 V ✓“. „Erweitert“: Port manuell wählen.
  „Scanner-Karte vorhanden“ entfällt (Firmware kann die Karte nicht erkennen).
- **Einstellungen (Touch):**
  - Verbindung: Port, Testen (kein GPIB, kein Zeitlimit-Feld nötig).
  - Messung: Integration (Schnell/Netzperiode), **Netzfrequenz 50/60 Hz** (`LINE`), Filter, Trigger (Dauernd/Einzeln).
  - Speicher: Ablageordner, Dateiformat (kein „Formatieren“).
  - Kalibrierung: **nur Anzeige** – die Kalibrierung liegt als Konstanten in der Firmware
    (`cal_dcv.h`, `cal_dca.h`); keine Erinnerung „überfällig“, keine Historie, kein Schreiben.
  - Anzeige: Hell/Dunkel, Stellenzahl (kein „Ruhezustand“).
  - Über: Build-Datum, Software-Version.
  - **„Frontpanel sperren“** bleibt: `LOCK 1|0` (Tasten am Gerät zeigen dann „LOCKED“).
- **Scanner-Kanäle / Analyse mit mehreren Kanälen:** `SCAN 1-3` oder `SCAN 1,4,7`
  misst die Kanäle reihum; jede `R`-Zeile trägt die Kanalnummer. Mit Filter wird pro
  Kanal erst nach 100 Wandlungen ein Wert gesendet (langsam!), ohne Filter jede
  Wandlung nach einer verworfenen Einschwing-Wandlung. `SCAN 0` beendet, `CHAN n`
  wählt einen festen Kanal. Kanalnamen („Referenz“, „Prüfling“) nur im Frontend.
- **Grenzwerte, Aufnahme (Laufzeit, Punkte), Marker A/B, Drift, Δ, Notizen,
  PNG-Export, Zoom:** reine Frontend-/Backend-Funktionen, keine Gerätebefehle.
- **Grenzwert-Mitteilung aufs Handy:** Browser-Benachrichtigungen brauchen HTTPS
  (außer auf localhost) → im LAN entweder selbstsigniertes Zertifikat oder nur
  Anzeige in der Seite.

## CSV-Format

`timestamp;t_s;value;unit;raw;function;range;channel;flags` (Semikolon, Dezimalpunkt).
`timestamp` ISO 8601 mit Millisekunden, `t_s` Sekunden seit Aufnahmebeginn.

## Reihenfolge der Umsetzung

1. Backend: Transport (pyserial + Simulator) + Treiber nach `remote-protocol.md`
   (aus `tools/k199_app.py` übernehmen) + Unit-Tests für den Zeilen-Parser.
2. WebSocket-Stream + Befehle (Funktion, Bereich, Modus, REL, Hold, Lock, Scan, Aufnahme start/stopp).
3. Frontend: Tokens → Bausteine → Screen „Messen“ nach `Main.reference.html`.
4. Verbindungsdialog nach `Connect.reference.html` (Ports per `*IDN?` durchprobieren).
5. Analyse-Screen mit uPlot, Bereichsauswahl, Auswahl-Statistik, Notizen, CSV/PNG-Export.
6. Responsive: Touch-Layout und Handy-Layout.

## Sicherheitsregeln (Gerät)

- Das Frontend/Backend schreibt **nie** Kalibrierdaten; es gibt dafür absichtlich
  keinen Befehl. Das EEPROM des Analogteils wird nicht angefasst.
- Die App steuert nur das 199. Eine angeschlossene Quelle (Riden RD6018P) wird von
  dieser App nicht bedient.

## Qualitätsregeln

- Echte `<button>`, `<label>`, `aria-label` an Icon-Buttons, Kontrast ≥ 4.5:1.
- Keine Emojis als Icons, Icons als Stroke-SVG (z. B. lucide-react).
- Messwert-Updates ohne Layout-Sprünge (`tabular-nums`, feste Breite).
- Lange Aufnahmen: Daten im Backend halten, Frontend bekommt herunterskalierte Daten (min/max pro Pixel).
