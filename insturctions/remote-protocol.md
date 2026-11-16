# Fernsteuer-Protokoll (UART3, P8/P9)

Stand 2026-11-16. Firmware: `src/tasks/remote.c` (in `app_dmm.c` eingebunden).
PC-Seite: `tools/k199_app.py` + `tools/k199_app.html`.

## Verbindung

- 115200 Baud (real 114943), 8N1, 3,3-V-Pegel, kein Handshake.
- Der FT230X (U2) ist nicht bestückt; ein USB-TTL-Wandler hängt an P8/P9.
  - **P8** = Netz „TxD“ = PIC-Eingang U3RX (RB3, Pin 22) ← **TX des Wandlers**
  - **P9** = Netz „RxD“ = PIC-Ausgang U3TX (RB5, Pin 20) → **RX des Wandlers**
  - dazu GND; VCC des Wandlers nicht anschließen.
- Nach dem Einschalten sendet das Gerät einmal `K199 READY`.
- Das EEPROM wird von diesem Code nicht angefasst.
- Hinweis: Auf der ersten Platine war PIC-Pin 22 (U3RX) nicht verlötet → Senden ging, Empfangen nicht.

## Befehle (PC → Gerät)

Eine Zeile pro Befehl, Abschluss LF (CR wird ignoriert), Groß-/Kleinschreibung egal,
höchstens 63 Zeichen. Antwort `OK`, `ERR,<Grund>` oder die abgefragten Daten.

| Befehl | Wirkung |
|---|---|
| `*IDN?` | `KEITHLEY,199-UPGRADE,0,<Build-Datum>` |
| `*RST` | Grundzustand: DCV, Autorange, Filter ein, 6½ Stellen, Dauertrigger, kein Kanal |
| `STAT?` | Zustandszeile `S,…` (siehe unten) |
| `READ?` | letzter Messwert als `R,…`-Zeile, sonst `ERR,NO READING` |
| `STREAM 0\|1` | jeden Messwert unaufgefordert senden |
| `FUNC DCV\|ACV\|DCA\|ACA\|OHM2\|OHM4` | Messfunktion |
| `RANG AUTO\|UP\|DOWN\|<n>` | Bereich; `<n>` = Index 0… in der Liste von `RANG?` (schaltet Autorange aus) |
| `RANG?` | Endwerte aller Bereiche der aktiven Funktion, kommagetrennt |
| `FILT 0\|1` | Filter (gleitender Mittelwert über 100 Wandlungen) |
| `DIG 4\|5\|6` | Anzeige 4½ / 5½ / 6½ Stellen |
| `ZERO 0\|1` | Relativmessung; Bezug ist der letzte Messwert |
| `DB 0\|1` | dB-Anzeige am Gerät (nur AC) |
| `TRIG CONT\|ONE` | Dauer- oder Einzeltrigger |
| `*TRG` | Messung auslösen (bei `TRIG ONE`) |
| `CHAN 0…8` | Scannerkanal, 0 = keiner |
| `KEY <Name>` | Tastendruck: VOLTS OHMS AMPS AC ZERO AUTO DOWN UP SCANNER TRIGGER NEXT LOCAL |
| `LOCAL` | Stream aus, REM-LED aus |

Fehlergründe: `CMD` (unbekannt), `ARG` (Argument), `NO READING`, `LINE` (Zeile zu lang).
Der erste Befehl schaltet die REM-LED ein.

## Zeilen vom Gerät

**Messwert** (bei `STREAM 1` nach jeder Wandlung, oder auf `READ?`):

    R,<ms>,<wert>,<roh>,<funktion>,<bereich>,<flags>

- `ms`: Millisekunden seit dem Einschalten
- `wert`: wie angezeigt (nach Filter und Zero) in V, A oder Ω, auch bei dB
- `roh`: diese eine Wandlung, kalibriert, vor Filter und Zero
- `flags` (Summe): 1 Autorange, 2 Zero, 4 Filter, 8 Filter gefüllt, 16 Überlauf, 32 dB aktiv
- Überlauf: `wert` und `roh` sind ±9.9E+37

**Zustand** (auf `STAT?` und nach jeder Änderung, auch durch Tasten oder Autorange,
sobald ein Befehl empfangen wurde):

    S,<funktion>,<bereich>,<endwert>,<auto>,<filter>,<stellen>,<zero>,<zero-bezug>,<db>,<CONT|ONE>,<kanal>,<stream>

Zahlen haben das Format `d.dddddddddE±ee`.

## PC-Programm

    tools/k199_app.command            (Doppelklick) oder
    python tools/k199_app.py [--port /dev/cu.usbserial-XXXX] [--sim]

Sucht das Gerät per `*IDN?` an allen USB-Seriell-Ports und öffnet
http://127.0.0.1:8200. `--sim` startet ohne Hardware mit einem simulierten 199.
Aufzeichnungen landen in `tools/logs/`.
