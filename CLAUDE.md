# CLAUDE.md – Keithley 199 Digital Board Upgrade

Austausch der Digitalplatine des Keithley 199 (PIC32MX350F256L, FreeRTOS, SCPI über FT230X-USB).
Sprache mit dem Nutzer: Deutsch. Code/Kommentare: wie im Bestand (Englisch/Deutsch gemischt).
Fortschritt steht in `insturctions/develope-log.md` (neueste Einträge unten) – **dort nach jeder relevanten Änderung einen datierten Eintrag ergänzen**.

## Build
- Toolchain laut `nbproject/configurations.xml`: **XC32 v5.00**, Pack **PIC32MX_DFP 1.6.369**, Gerät **PIC32MX350F256L**.
  (Im Makefile stehen noch Reste von `/Applications/microchip/xc32/v4.60/...` – nur Kompatibilitätsrest, nicht benutzen.)
- Produktionsbuild:  `make -f nbproject/Makefile-default.mk CONF=default build`  → `dist/default/production/*.hex`
- Debugbuild:        `make TYPE_IMAGE=DEBUG_RUN -f nbproject/Makefile-default.mk SUBPROJECTS= .build-conf`
- Unit-Tests (Host): `rake test:all` (Ceedling in `vendor/ceedling`, Tests in `test/`)
- Versionsstring (`REPOVERSION`) kommt aus dem Root-`Makefile` (`MP_EXTRA_CC_PRE`), NICHT aus MPLAB-Preprocessor-Makros.
- Prüfen, ob `xc32-gcc` im PATH liegt (`ls /Applications/microchip/xc32/`), sonst Pfad der installierten v5.xx verwenden.

## Flashen (bestätigt 2026-11-15)
- **PICkit 3** an Header **J2** (Pin 1 MCLR, 2 +3,3 V, 3 GND, 4 PGD, 5 PGC). Keithley versorgt sich selbst, PICkit liefert **keine** Spannung (kein `-W`).
- **MPLAB X 6.05** benutzen (6.25 unterstützt den PICkit 3 nicht mehr). Der Wrapper startet den USB-Helfer `/etc/.mplab_ide/mchpmacusbdevice` und setzt cwd/PATH richtig:
  ```
  sh /Applications/microchip/mplabx/v6.05/mplab_platform/mplab_ipe/bin/ipecmd.sh \
     -P32MX350F256L -TPPK3 -F"$PWD/dist/default/production/keithley_199-master.production.hex" -M -Y -OL < /dev/null
  ```
  **`-OL` ist Pflicht:** Ohne ihn hält der angesteckte PICkit den PIC über MCLR im Reset (Display schwarz). Nur freigeben: `ipecmd.sh -P32MX350F256L -TPPK3 -OL < /dev/null`.
  Nur verbinden/lesen: dieselbe Zeile ohne `-F … -M -Y`. Erfolg: `Program Succeeded` bzw. `Verify Succeeded`.
- Erst ein lesender Verbindungstest, dann flashen. `< /dev/null` nicht weglassen (sonst hängt ipecmd).
- „could not detect target voltage VDD“ = Kontakt-/Masseproblem am Kabel (beim Bring-up eine lose GND-Leitung). Reine „Connection Failed“-Meldung = PICkit hängt → USB neu einstecken.
- Kontakte sind wackelig: Ein Lauf brach nach dem Löschen ab, ein anderer meldete beim nachgelagerten Verify einen Fehler; ein separates `-Y` bestand danach. Bei Fehler einfach wiederholen und mit `-Y` prüfen.

## Bekannte Fallstricke (alle aus echten Bring-up-Fehlern)
1. **MPLAB „Regenerate Makefile" zerstört `nbproject/Makefile-default.mk`** (v4.60-Include-Pfade, PLIB-Link, `-mips16`, `_min_heap_size`). Nicht regenerieren; Details im Log (2026-05-04).
2. **Legacy-PLIB wird teilweise nicht ins Flash gelinkt** (Symbole bei Adresse 0 → sofort Exception). Deshalb arbeiten `hal_sys/hal_io/hal_spi/hal_timer/hal_adc` direkt über SFRs/Inline-ASM. **Keine neuen `PORT*`/`INT*`/`Spi*`/`OpenCoreTimer`-PLIB-Aufrufe einführen.**
3. `mSYSTEMUnlock` (lock.h, `_DMAC`) deadlockt in `DmaSuspend()` – dort gepatcht (`#undef _DMAC`), PBDIV kommt aus Fuses.
4. Core-Timer-ISR hängt an `.vector_0` in `src/hal/isrWrappers.S` – nicht entfernen.
5. RG6 (SCK2/AN16) ist nach Reset analog: `ANSELGCLR` nötig. RC4 = SYSERR-LED (aktiv low).
6. Exception-Handler (`exceptions.c`) ist `nomips16`/`O0` – ohne PLIB lassen.
7. **Takt:** Quarz X1 schwingt nicht an → mit `PRIPLL` lief der PIC auf FRC 8 MHz ohne PLL (10× zu langsam). `fuses.c` nutzt `FRCPLL` (80 MHz). Beim Start zeigt `main.c` `OSC n` (COSC, 1 = FRC+PLL).
8. **Display-ISR:** eine Stelle pro Core-Timer-Interrupt (1 ms), keine Warteschleifen im ISR – sonst verhungern FreeRTOS-Tick und OC3/ADC-ISR.
9. **Vektoren:** OC3 (Vektor 14) wird über den `vector()`-Prototyp in `hal_adc.c` angebunden, der Core Timer (Vektor 0) über `isrWrappers.S`. Nicht doppelt anlegen.
10. **PPS nie sperren:** Fuse `IOL1WAY = ON` → ein einmal gesetztes `CFGCONbits.IOLOCK` bleibt bis zum Reset. Die Display-Init hatte es gesetzt und damit alle PPS-Zuweisungen des ADC (SDO1→RF8, OC3→RG1, T4CK←RE3) blockiert. Kein `IOLOCK = 1` mehr einbauen.
11. **Kalibrierwerte NIE überschreiben:** Vorhandene Kalibrierdaten (I²C-EEPROM / `calibration_*` / `settings_*`, Analogmodul) dürfen nicht beschrieben werden. Eigene Kalibrierung liegt als Konstanten in `src/tasks/cal_dcv.h` (PIC-Flash). Vor dem Einbinden von `tskmgr`/`calibration_*`/`eeprom_*` mit dem Nutzer klären und sicherstellen, dass nur gelesen wird.

## Hardware-Eckdaten
- Display: 10 Zeichen (14-Segment) + Modus-LEDs, Multiplex ~90 Hz, 11 Slots. Segmentbus an PORTD (aktiv high).
- Digit-Select: **16-Bit-Wörter MSB-first per GPIO-Bitbang** (CLK=RG6 idle low, DATA=RC1), aktiv-low:
  `FFDF, FBFF, 7FEF, FDFF, BFF7, FEFF, DFFB, FF7F, EFFD, FFBF, F7FE` (Slot 10 = Mode-LEDs). Hardware-SPI2 passte nicht zum Original.
- Zeichen-Slot→Bus-Zuordnung: `digit_bus_line[] = {8,6,4,2,0,9,7,5,3,10,1}` in `hal_spi.c` (per Kamera bestätigt). Glas hat 9 sichtbare Ziffern; **LED-Zeile hängt an Bus 1** (Slot 10), Bus 10 überlagert die 1. Glasstelle (Slot 9 leer lassen). Unteres Segment der 1. Stelle defekt.
- ADC: diskreter Charge-Balance-Wandler auf der Analogplatine; Start/Stop-Timing exakt (16,66 ms Integration). Steuerung über Schieberegister.
- Schaltplan/Layout: `hw.kicad/` (KiCad 9). Schaltplan MCU-Symbol/BOM nennen noch **F128L**, Firmware zielt auf **F256L** (gleiches TQFP-100) – bei Gelegenheit angleichen.
- Fertigungsdaten (`hw.kicad/gerber`, `production/`) sind älter als der Stand von Dez 2025 → vor Bestellung neu erzeugen.

## Messaufbau / Test-Loop (Plan)
- **Riden RD6018P** (Netzteil, Modbus-RTU über USB-Seriell, i. d. R. 115200 Baud, Slave 1). Verbindungstest:
  `python3 tools/rd6018_probe.py` (rein lesend, schreibt `tools/rd6018_probe_result.json`).
- RD6018P: Skriptgrenze 60 V / 0,5 A (auf Nutzerwunsch, max. erreichbar ~56,9 V). Ist **keine Referenz** (~0,1 %, 1-mV-/1-mA-Schritte, per Frontpanel bestätigt): nur für Linearität/Rauschen/Bereichsumschaltung, nicht für absolute Kalibrierung. Widerstandsmessung damit nicht prüfbar.
- Kamera: nur zur Sichtprüfung der Anzeige; für schnelles Multiplex-Verhalten Logikanalysator nutzen.
- Messwerte des 199 bevorzugt per **SCPI über USB (FT230X)** lesen.

## Sicherheitsregeln für automatische Loops
- Vor jedem Lauf am RD6018P setzen: **OVP, OCP, Strombegrenzung**; Ausgang nach jedem Test und bei Fehler **ausschalten**.
- Standard-Maximum bei Spannungsmessungen: Strombegrenzung klein (z. B. ≤ 0,1 A); nie über die Bereichsgrenze des gewählten 199-Bereichs.
- Strommessungen (30 mA / 3 A) nur mit definierter Last und Strombegrenzung am Netzteil.
- Maximale Iterationszahl pro Loop festlegen; bei Fehlschlag auf den letzten funktionierenden Stand (`git`) zurückfallen.
- Kein Anschluss/Umstecken von Prüfspitzen durch Claude – das macht der Nutzer.
- Nichts am RD6018P schreiben, bevor Modell/Baudrate per Probe bestätigt sind.

## Arbeitsweise
- Kleine, überprüfbare Schritte; nach jeder Änderung Build ausführen und Ergebnis ins Log schreiben.
- Keine Dateien in `build/`, `dist/`, `nbproject/private/` von Hand ändern.
- Stand 2026-11-15: DCV misst in allen vier Bereichen; kalibriert gegen Riden (`cal_dcv.h`), Kontrolle ≤ ±1,1 mV. Bereich per `MEAS_RANGE` in `main.c`. Offen: Kalibrierung, andere Bereiche/Funktionen, `tskmgr` (Tasten/Settings/EEPROM), SCPI.
