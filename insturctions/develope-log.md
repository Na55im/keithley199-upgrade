# Develop log

## 2026-05-04 — Legacy PLIB in-tree, XC32 v5 build

- Added `third_party/pic32mx-legacy-plib/` (chipKIT-derived `plib.h`, `GenericTypeDefs.h`, `include/peripheral/**`, `lib/libmchp_peripheral_32MX350F128L.a`). Makefile falls back to this path when XC32 v4 `pic32-libs` is absent.
- Patched vendored headers for GCC 13: `extern inline` → `static inline`, `extern __inline__` → `static __inline__` under `include/peripheral/`.
- `nbproject/Makefile-default.mk`: `PROJECT_ROOT`, bundled PLIB fallback, link `$(PIC32_LEGACY_PERIPH_LIB)`, `utils_math.c` in sources/rules, `_min_heap_size=512`, `-mno-mips16` (was `-mips16`).
- Root `Makefile`: `-O2`, `-ffunction-sections`, `-fdata-sections`, `-minterlink-mips16`, `-mlong-calls`.
- HAL: `hal_adc.c` integration macro cleanup + `interrupt(IPL3AUTO)`; `hal_timer.c` / `hal_uart.c` ISR attributes; removed duplicate `get_baudrate`/`SetRxTxPins` in `hal_uart.c`.
- `src/tasks/task_scpi.c`: error queue buffer type `scpi_error_t[]`.
- Vendored `src/scpi-parser/libscpi` from upstream `j123b567/scpi-parser` (was empty).
- `tools/fetch_pic32mx_legacy_plib.sh`: refresh third_party from chipKIT prebuilt.

Build verified: `make -f nbproject/Makefile-default.mk build` → `dist/default/production/*.hex`.

## 2026-05-04 — Makefile-default regeneration follow-up

- `PIC32_LEGACY_PERIPH_LIB`: `=` → deferred `=` so `MP_PROCESSOR_OPTION` (defined later in the makefile) resolves to `libmchp_peripheral_32MX350F128L.a`.
- Added missing `${OBJECTDIR}/src/utils/src/utils_math.o` to `OBJECTFILES` (was only on `OBJECTFILES_QUOTED_IF_SPACED`, so link ran before compiling `utils_math.c`).
- `POSSIBLE_DEPFILES`: corrected `strutils.o` typo → `strutils.o.d`, kept `utils_math.o.d`.
- Debug link only: `_min_heap_size=0` so the linker reserve leaves enough RAM for stack (`_min_heap_size=512` + `-g` overflowed RAM on 32MX350F128L).

Verified: `make TYPE_IMAGE=DEBUG_RUN -f nbproject/Makefile-default.mk SUBPROJECTS= .build-conf` → `dist/default/debug/keithley_199-master.debug.elf`.

## 2026-05-04 — Target MCU PIC32MX350F256L

- `nbproject/Makefile-default.mk`: `MP_PROCESSOR_OPTION=32MX350F256L` (link picks `libmchp_peripheral_32MX350F256L.a` via deferred `PIC32_LEGACY_PERIPH_LIB`).
- `nbproject/configurations.xml`: `<targetDevice>PIC32MX350F256L</targetDevice>`.
- `tools/fetch_pic32mx_legacy_plib.sh`: default part `32MX350F256L`, overridable `PIC32_MX_PART=…`.
- Added `third_party/pic32mx-legacy-plib/lib/libmchp_peripheral_32MX350F256L.a` (chipKIT mirror).

## 2026-05-04 — MPLAB regenerate: OBJECTFILES wieder ohne utils_math

- Nach erneuter Generierung fehlte `utils_math.o` nur in der **`OBJECTFILES=`**-Zeile (Link-Kommando lud die Datei ein, ohne dass make sie baute → `cannot find utils_math.o`). Zeile angepasst, sodass **`${OBJECTDIR}/src/utils/src/utils_math.o`** wie bei `OBJECTFILES_QUOTED_IF_SPACED` eingetragen ist.
- Hinweis: **`plib.h`** kommt weiterhin vom Root-`Makefile` (`MP_EXTRA_CC_PRE` mit `-I.../third_party/pic32mx-legacy-plib/include`); ohne diesen Prefix zeigt xc32 nach Regen weiter auf **`v4.60/pic32-libs`** — dort liegt bei vielen Installationen keine Legacy-PLIB mehr.
- Produktionsbuild verifiziert: `make -f nbproject/Makefile-default.mk CONF=default build` → erfolgreiches Link + HEX.

## 2026-05-04 — REPO-Makros doppelt → Build-Fehler; Linker `-l`/Pfad falsch

- **Ursache:** Root-`Makefile` setzt bereits sauber `-DREPOVERSION="$(GIT_VERSION)"`; **MPLAB-Preprocessor-Makros** ergänzen kaputte Varianten `-DREPOVERSION=\'"unknown\'\"` → `stray '\'` / zweite Definition. **Fix:** `configurations.xml`: `preprocessor-macros` nur noch `NDEBUG` (Versionsstrings nur über `MP_EXTRA_CC_PRE` im Root-`Makefile`). Zusätzlich entfernte defekte **`-DREPO…`**-Fragmente in allen `Makefile-default.mk`-Compile-Rezepten (`replace_all`).
- **Includes:** Legacy-/`v4.60`-Pfad bereinigt: `extra-include-directories` ohne `/Applications/microchip/xc32/v4.60/pic32-libs/include`; nur Projekt **`third_party/pic32mx-legacy-plib/include`**. Überflüssige **`-I"/…/v4.60/pic32-libs/…"`** in `Makefile-default.mk` gestrichen.
- **Linker:** MPLAB hatte `.a` als **`-l"…/voller/pfad/lib…"`** eingetragen (**`cannot find -lthird_party/...`**); **korrekt** ist Archive als zusätzliche **Invokations-Datei** nach den `.o`-Dateien: `"$(CURDIR)/third_party/.../libmchp_peripheral_32MX350F256L.a"`; **`-Wl,-l…,-L…`** entfernt. Linkzeilen: **`-mips16` → `-mno-mips16`**, Produktion **`_min_heap_size=512`**. **`configurations.xml`:** `input-libraries` / `extra-lib-directories` geleert sowie Linker **`generate-16-bit-code`** `false`, damit ein erneutes **Regenerate** keine kaputten **`-l"pfad/datei.a"`** mehr erzeugt (Legacy-Bibliothek bleibt in der gepatchten `Makefile-default.mk`).
- Produktionsbuild erneut verifiziert: `make -f nbproject/Makefile-default.mk CONF=default build` → HEX.

## 2026-05-04 — MPLAB 6.05 / Regenerate: Makefile erneut zurückgedreht

- IDE hatte `nbproject/Makefile-default.mk` wieder mit **`-I…/xc32/v4.60/pic32-libs/include`**, Link nur **`-L third_party/…/lib`** ohne **`.a`**, **`-mips16`**, **`_min_heap_size=2000`** erzeugt. **Wiederherstellung:** `extra-include-directories` ohne v4.60; **Linker** `extra-lib-directories` leer, **`generate-16-bit-code`** `false`; Makefile: v4.60-**`-I`** entfernt; Link mit **`"$(CURDIR)/…/libmchp_peripheral_32MX350F256L.a"`**, **`-mno-mips16`**, **`_min_heap_size=512`** (Production).  
- Hinweis: Nach **„Regenerate Makefile“** in MPLAB diese Anpassungen ggf. erneut aus Git übernehmen oder Properties so lassen wie im `configurations.xml` im Repo.

## 2026-05-04 — Display-Experimente zurückgenommen

- Entfernt: spezieller Display-Test in `main.c`, Anpassungen an `hal_io*.c`/`hal_io.h` (Zeichen-Mapping/Ohm-Zeichen) und `disfmt.c`. Stand wieder wie vor dem Display-Test-Zweig (`system_init` + `taskmgr_start` in `main.c`, ursprüngliche `map_char`-Logik und Ohm-Strings `"o "` / `"Ko "` / `"Mo "`).

## 2026-05-04 — Display-Hardwaretest wieder aktiv (`main.c`)

- **`src/tasks/main.c`:** Minimal-Firmware nur für Display-Test: `hal_sys_init()`, Task `display_kyb_init()` → Schleife `display_puts("HELLO")` / `display_clear()` je 1 s (2 s Periode). **`HELLO` groß** wegen fehlerhafter Kleinbuchstaben-Abbildung in `hal_io_displayport_map_char_to_segments` im Originalcode. Kommentar im File beschreibt den Rückbau zur Voll-Firmware.

## 2026-05-04 — Display-Test: 10× „L“

- **`src/tasks/main.c`:** Muster `DISPLAY_TEST_PATTERN` = zehn mal `L` auf allen nutzbaren Textstellen; Glyph aus `hal_io_displayport_map_char_to_segments`/`chartable`. Später: **ohne Blink**, dauerhaft sichtbar.

## 2026-05-04 — Display-Test: Segment-Snake (Diagonal, 1 s)

- **`src/drivers/dispkyb.c` / `dispkyb.h`:** `display_segment_snake_step(step)` — pro Schritt wächst die Diagonale (DS1…DS10): Segment-Reihenfolge **l, c, dp**, dann **a, b, d, e, f, g, h, j, k, m, n, i** (Indices `hal_io_get_segment`). Nur **10 Ziffern-Slots** (`NUMBER_OF_CHARACTERS-1`), Mode-Spalte bleibt durch `display_clear` ohne gesetzte Bits.
- **`src/tasks/main.c`:** Ruft jedes s `display_segment_snake_step(step++)` nach `display_kyb_init`, Delay **1000 ms**.
- **`dispkyb.c`:** `#include <stdint.h>`, `<string.h>` für saubere Typen / `memset`.

## 2026-05-10 — SPI2 Display: RG6 kein Takt (Scope)

- **Ursache:** `RG6` ist `SCK2` und **AN16**; nach Reset ist **`ANSG6` in `ANSELG` gesetzt** → Pin bleibt **analog**, kein digitaler SPI-Takt / kein sauberes `SDO2`‑Verhalten am Oszi.
- **`src/hal/hal_spi.c`:** Vor `SpiChnOpen`: `ANSELGCLR = _ANSELG_ANSG6_MASK`, `PORTSetPinsDigitalOut` für `IOPORT_G` `BIT_6` und `IOPORT_C` `BIT_1` (`ddata`); **PPS** (`SDO2` → `RPC1`) in **`mSYSTEMUnlock` / `mSYSTEMLock`** mit `PPSUnLock`/`PPSLock` wie vorgesehen; danach `SpiChnOpen` SPI2.

## 2026-05-10 — SPI2 Scope weiterhin leer (zweite Runde)

- **Erweiterung `src/hal/hal_spi.c`:** `PMD5CLR` SPI2 (nicht im PMD „off“); `ODCG`/`ODCC` Open-Drain für `RG6`/`RC1` clear; **`RPG6R = 0`** nach Unlock (kein RPOR auf `RG6`, damit **fester `SCK2`** das Pad treibt); **`SPI_OPEN_DISSDI`** wie bei SPI1; nach Init **48×** Wechsel `0xAAAA`/`0x5555` als Burst (sofort messbar); **`hal_spi_write_16bit`:** Warten auf **`SPI2STATbits.SPIBUSY`**.

## 2026-05-10 — GPIO-Pinprobe statt SPI

- **`src/tasks/main.c`:** Temporäre Minimal-Firmware ohne FreeRTOS/SPI/Display-Timer: `RG6` (`SCK2`/Clock), `RC1` (`SDO2`/Data), grüne Board-LED `RC3` und AUX-LED `RB4` werden direkt als GPIO konfiguriert und per Core-Timer mit **1 Hz Rechteck** getoggelt (`0,5 s` low/high). `RB4`/`AN4` wird über `ANSELBCLR` digital geschaltet. Zweck: Beweisen, ob das geladene HEX tatsächlich läuft und ob die gemessenen Pins/Netze überhaupt toggeln können.
- Build verifiziert: `make -f nbproject/Makefile-default.mk CONF=default build` → HEX erfolgreich; nur bestehende PLIB-Kommentarwarnung.

## 2026-05-10 — `mSYSTEMUnlock` / Debugger-Hang bei PPS

- **Ursache:** Auf **PIC32MX350F256L** ist **`_DMAC`** gesetzt → `mSYSTEMUnlock` aus `lock.h` ruft **`DmaSuspend()`** auf. Wenn DMA nie genutzt wird, kann **`while(!DMACONbits.SUSPEND)`** in `DmaSuspend` **endlos** laufen (Debugger wirkt wie Absturz in `mSYSTEMUnlock`).
- **`src/hal/hal_spi.c`:** PPS nicht mehr über `mSYSTEMUnlock`/`mSYSTEMLock`; stattdessen **`INTDisableInterrupts` → SYSKEY → `CFGCONbits.IOLOCK` → `RPG6R`/`PPSOutput` → IOLOCK → SYSKEY lock → `INTRestoreInterrupts`** ohne DMA.

## 2026-05-10 — General-Exception: kein PLIB auf RC4 im Handler

- **Beobachtung:** `_gen_exception` → `jr k0` ist normaler Dispatch; der „Absturz“ folgt oft dem ersten **sicheren** Code im Handler (rote LED). **`hal_io_set_led` → `PORTClearBits(BRD_RED_LED)`** ruft PLIB auf und setzt voraus, dass **`hal_io_init()`** schon gelaufen ist — bei Minimal-`main` oft **nicht** der Fall → TRIS/OD kann falsch sein; zusätzlich sind **MIPS16**-Aufrufe im Exception-Pfad riskant.
- **`src/hal/exceptions.c`:** Handler **`__attribute__((nomips16))`**; **SYSERR (RC4)** direkt per **`ODCC`/`TRISC`/`LATC`** (wie Board: aktiv-low); **`PORTClearBits`/`hal_io` entfernt**; **`assert(0)` entfernt** (bei `NDEBUG` ohnehin leer, aber die alten Default-Zweige waren unnötig riskant). **`g_last_excep_cause`** / **`g_last_excep_status`** und **`_excep_code`** bleiben für Watch-Fenster nutzbar.

## 2026-05-10 — Exception-Handler: COP0 EPC/BadVAddr + O0

- **Debugger stoppt bei `g_last_excep_*` / `_excep_code`:** Das ist meist der **erste C-Code** nach dem Assembler-Bootstrap — keine eigene Fehlerursache; mit **`-O2`** können Zeilen beim Steppen springen.
- **`src/hal/exceptions.c`:** Handler **`optimize("O0")`** für nachvollziehbares Steppen; zusätzlich **`g_last_excep_epc`** (`mfc0 …, $14`) und **`g_last_excep_badvaddr`** (`mfc0 …, $8`), damit die **echte Fault-Adresse** und (bei Bus/Adress-Exceptions) die **Bad-Adresse** im Watch-Fenster liegen — **`_excep_code`** weiter aus Cause-Bits.

## 2026-05-10 — SYSERR-LED: RC4 analog→digital

- **`exception_show_syserr_led`:** **`ANSELCCLR`** für RC4 vor OD/TRIS/LAT (falls Pin noch analog war, sonst kein sauberes Digital-Level); Hilfsfunktion **`nomips16`**. Reihenfolge: Analog aus → Open-Drain aus → Ausgang → **LAT low** = aktiv-low LED an.

## 2026-05-10 — ROOT CAUSE: `lock.h` `_DMAC` → `DmaSuspend()` Deadlock

- **Fehlerkette:** `hal_sys_init()` → `SYSTEMConfigPerformance()` → `SYSTEMConfigPB()` → `OSCSetPBDIV()` (inline in `osc.h`) → **`mSYSTEMUnlock()`** → **`DmaSuspend()`** → **`while(!DMACONbits.SUSPEND)`** → **Endlosschleife** (DMA nie initialisiert). Nach dem Timeout/Debugger-Stopp: MCU in Exception → rote LED an.
- **Root Cause:** `_DMAC` ist im Linker-Script / Chip-Header für PIC32MX350F256L definiert. `lock.h` prüft `#ifdef _DMAC` und nimmt den DMA-Pfad — obwohl dieses Projekt DMA nie benutzt.
- **Fix `third_party/pic32mx-legacy-plib/include/peripheral/lock.h`:** `#undef _DMAC` vor den Makros; `#include <peripheral/dma.h>` entfernt. Alle drei Makros (`mSYSTEMUnlock`, `mSYSTEMLock`, `mSysUnlockOpLock`) verwenden jetzt **nur** `INTDisableInterrupts` / `SYSKEY` / `INTRestoreInterrupts` — **kein DMA-Suspend/Resume**.
- **`osc.h`:** `dma_status` mit `= 0; (void)dma_status;` initialisiert, damit `-Wunused-variable` weg ist.
- Clean-Rebuild verifiziert: **keine Errors**, nur vorbekannte Warnungen (pps.h Kommentar, FreeRTOS port.c, tskmgr.c).

## 2026-05-10 — `SYSTEMConfigPerformance` komplett durch direkte SFR-Zugriffe ersetzt

- **Problem:** Auch **ohne** `DmaSuspend` (lock.h-Fix) crashte `mSYSTEMUnlock` weiter — die gesamte PLIB-Inline-Kette (`SYSTEMConfigPerformance` → `SYSTEMConfigPB` → `OSCSetPBDIV` → `mSYSTEMUnlock`) wurde per `always_inline` in MIPS16-Code eingebettet. Ob MIPS16-Encoding / CP0 / SYSKEY-Timing die Ursache war, ist unklar; der Code war jedenfalls nicht überlebbar.
- **`src/hal/hal_sys.c`:** `SYSTEMConfigPerformance()` **entfernt**. Stattdessen `sys_config_performance()` (`nomips16`, `O2`): `CHECON` direkt setzen (2 wait states, prefetch all), `BMXCONCLR` für DRM-WS, **`mfc0`/`mtc0` auf CP0 Config** für KSEG0-Cache. `hal_sys_init()` ebenfalls `nomips16`. **Kein** `mSYSTEMUnlock`, `SYSKEY`, `OSCSetPBDIV` oder PLIB-Inline mehr im Init-Pfad.
- **PBDIV:** Bereits per Fuse `FPBDIV = DIV_1` gesetzt — Änderung via OSCCON entfällt komplett.
- Clean-Rebuild + Preprocessor-Verify: kein `DmaSuspend`, kein `mSYSTEMUnlock` im generierten Code für `hal_sys.c`.

## 2026-05-10 — PLIB-Bibliothek nie gelinkt (Adresse 0x00000000)

- **Root Cause Nr. 2:** `libmchp_peripheral_32MX350F256L.a` war **nicht** im Link-Kommando — nur der Suchpfad (`-L`). Alle PLIB-Funktionen (`INTDisableInterrupts`, `PORTSetBits`, `SpiChnOpen`, `ReadCoreTimer`, …) lagen bei **Adresse 0x00000000** (Typ `N` = Debug-Symbol). Jeder `call` in eine PLIB-Funktion sprang nach Adresse 0 → sofortige Exception.
- **`Makefile`:** `MP_EXTRA_LD_PRE += -Wl,--whole-archive $(PIC32_LEGACY_PERIPH_LIB) -Wl,--no-whole-archive` eingefügt; `--gc-sections` entfernt dann Ungebrauchtes.
- **`src/hal/hal_sys.c`:** **Alle** PLIB-Aufrufe (`INTDisableInterrupts`, `INTRestoreInterrupts`, `INTSetVectorPriority`, `INTConfigureSystem`) durch **Inline-ASM** (`di`, `ei`) und **direkte SFR-Zugriffe** (`IPC9`, `IPC10`, `INTCON`, `CHECON`, `BMXCON`, CP0 Config/Count) ersetzt. `hal_sys_init()` ist jetzt **komplett PLIB-frei**.
- **`src/tasks/main.c`:** `WriteCoreTimer`/`ReadCoreTimer` (PLIB, Adresse 0) durch Inline-ASM **`mtc0`/`mfc0` CP0 Register 9** (Count) ersetzt; Funktion `nomips16`.
- Neues HEX: `main` bei **0x9d001f88**, `hal_sys_init` bei **0x9d001ee0** — real im Flash.

## 2026-05-10 — Segmentanzeige: FreeRTOS + `display_kyb`

- **`src/tasks/main.c`:** Pin-Probe entfernt; **`hal_sys_init()`** → **`xTaskCreate(display_app_task)`** → **`vTaskStartScheduler()`**. Die Task ruft **`display_kyb_init()`** (wie `tskmgr`: `hal_io_init`, **`hal_spi_init_16bit`**, Core-Timer-Multiplex **`hal_timer_init`**) und wechselt zyklisch **`display_puts("HELLO")`** (2 s) und **`display_segment_snake_step`** (Schritte 0–14, je 250 ms).
- Voraussetzung: PLIB-Archiv weiter gelinkt (`Makefile`); Multiplex läuft im **Core-Timer-ISR** (`dispkyb.c` → `hal_disp_scan` / SPI-Ziffernmux).

## 2026-05-10 — `hal_io.c`: GPIO ohne PLIB `PORT*`

- **Symptom:** Beim ersten **`PORTSetPinsDigitalOut`** in **`hal_io_init`** → **`_gen_exception`** (Aufruf über Relocation mit Ziel **0x00000000**, wenn **`PORTSetPinsDigitalOut`** nicht im Flash liegt).
- **`src/hal/hal_io.c`:** Alle **`PORTSetPinsDigitalOut`/`PORTSetPinsDigitalIn`/`PORTSetBits`/`PORTClearBits`/`PORTToggleBits`/`PORTReadBits`** auf diesem Modul durch **`hal_sfr_*`-Hilfsfunktionen** ersetzt: **`ANSELxCLR`**, **`ODCxCLR`**, **`TRISxCLR`/`SET`**, **`LATxSET`/`CLR`/`INV`**, **`PORTx`-Read** — gleiche **`IOPORT_*`/`BIT_*`-Makros** wie zuvor.
- Build: **`make -f nbproject/Makefile-default.mk CONF=default build`** ok; **`hal_io_init`** im ELF nur noch **SFR-`sw`** nach **`0xbf88…`** (kein **`jalr`/`jal` zu PLIB**).

## 2026-05-10 — `hal_spi.c`: SPI2-GPIO ohne PLIB `PORT*`

- **Symptom:** Beim Debuggen mehrfach in **`hal_spi_init_16bit`** → Exception beim **`PORTSetPinsDigitalOut`** (RG6 / RC1), gleiche Klasse wie **`PORTSetPinsDigitalOut` @ 0**.
- **`hal_io.h` / `hal_io.c`:** **`hal_gpio_pins_digital_out(IoPortId, mask)`** öffentlich (`nomips16`), weiterhin SFR-only.
- **`hal_spi.c`:** **`#include <hal_io.h>`**; **`PORTSetPinsDigitalOut`** durch **`hal_gpio_pins_digital_out`** ersetzt; **`hal_spi_init_16bit`** / **`hal_spi_write_16bit`** mit **`nomips16`** (konsistent zum GPIO-Helfer).

## 2026-05-10 — IRQ + SPI2/SPI1 ohne PLIB (`INT*` / `SpiChn*`)

- **Symptom:** Exception schon bei **`unsigned int ist = INTDisableInterrupts();`** — im Map/`readelf` lagen **`INTDisableInterrupts` / `INTRestoreInterrupts` / `SpiChnOpen` / `SpiChnWriteC`** weiterhin bei **VMA `0x00000000`** (nicht im Flash gelinkt).
- **`hal_sys.h` / `hal_sys.c`:** **`hal_irq_disable()`** / **`hal_irq_restore()`** öffentlich, intern dieselbe **`di`/`ei`-Logik** wie **`disable_interrupts`/`restore_interrupts`**.
- **`hal_spi.c`:** PPS-Block nutzt **`hal_irq_*`** statt PLIB; **`SpiChnOpen`/`SpiChnWriteC`** entfernt — **`hal_spi2_hw_open()`** setzt **`SPI2CON`/`SPI2BRG`/`SPI2STAT`** wie früheres **`SpiChnOpen(..., 100)`**; **`hal_spi_write_16bit`** schreibt **`SPI2BUF`** und wartet auf **`SPI2STATbits.SPIBUSY`**.
- **`hal_adc.c`:** **`PORTSetPinsDigitalOut`** → **`hal_gpio_pins_digital_out`**; **`SpiChnOpen`/`SpiChnPutC`** → **`hal_adc_spi1_hw_open(80)`** + **`SPI1BUF`** / **`SPI1STATbits.SPIBUSY`**.
- Build **`CONF=default`** ok; **`xc32-nm`** zeigt **`hal_irq_disable`**, **`hal_spi_init_16bit`** in **kseg0** — keine **`T INTDisableInterrupts`** / **`T SpiChnOpen`** mehr im ELF.

## 2026-05-10 — Linker: PLIB-`.a` und „Symbole @ 0“; `hal_timer` ohne Core-Timer-PLIB

- **Nicht** nur „`.a` fehlt“: `xc32-readelf -S` zeigte z. B. **`.text.OpenCoreTimer`** mit **VMA `0x00000000`** und **ohne** Eintrag im **kseg0-`PT_LOAD`**-Segment — Aufrufe von **`OpenCoreTimer` / `UpdateCoreTimer` / `INTClearFlag`** springen ins Leere → Exception. **`--whole-archive`** um die gesamte **`libmchp_peripheral_*.a`** bricht hier mit **`R_MIPS_26` relocation truncated** (u. a. NVM→`memcpy`) ab.
- **Pragmatischer Fix:** betroffene PLIB-Einstiege im App-Code **vermeiden** (SFR / Inline-ASM / eigene Helfer), Archiv nur für Module, die zuverlässig ins Flash fallen, oder auf von Microchip gelieferte **Peripheral-Libs** für dein **XC32+DFP**-Set umsteigen.
- **`src/hal/hal_timer.c`:** **`OpenCoreTimer` / `UpdateCoreTimer` / `INTClearFlag`** ersetzt durch **`mtc0`/`mfc0` auf CP0 `$9`/`$11`** (wie in **`open_core_timer_lib.o` / `update_core_timer_lib.o`**) und **`IFS0CLR = _IFS0_CTIF_MASK`**; **`mConfigIntCoreTimer`** bleibt Makro (IFS/IPC/IEC). **`hal_timer_init`** / **`CT_handler`** mit **`nomips16`**.
- **`Makefile`:** Kurzkommentar zur Diagnose (orphan **`.text.<name>`** / **`--whole-archive`**-Fallstrick).

## 2026-05-12 — Display-Select: kein 16-Bit-SPI mehr, sondern 1× DATA/CLK pro Slot

- **Messung am Originalboard:** Display-Clock entspricht dem Multiplex (~90 Hz pro Stelle bei 11 Slots), nicht einem SPI-Bitclock-Protokoll. Segmentdaten liegen parallel; **`DATA`** setzt nur den seriellen Digit-Select-Start/Shift-Zustand.
- **`src/hal/hal_spi.c`:** SPI2 wird nicht mehr als SPI geöffnet; **`RG6` (`dclk`)** und **`RC1` (`ddata`)** werden als GPIO initialisiert, PPS von **`RPC1`** getrennt, SPI2 ausgeschaltet/PMD-disabled. Neue Funktion **`hal_display_select_step(frame_start)`** setzt **DATA=1** nur beim Frame-Anfang und pulst genau einmal **CLK**.
- **`src/drivers/dispkyb.c`:** **`display_set`** setzt zuerst den Segmentbus (**`hal_io_displayport_write`**) und pulst danach den Digit-Select mit **`position == 0`** als Frame-Start. **`hal_spi_write_16bit`** bleibt nur als Kompatibilitätswrapper und erzeugt ebenfalls nur einen Display-Select-Clock.
- Build **`make -f nbproject/Makefile-default.mk CONF=default build`** ok; LA ohne Segmentanzeige sollte nun 11 Clock-Pulse pro Frame mit DATA high nur beim ersten Slot zeigen.

## 2026-05-12 — Display-Clock am LA sichtbar machen

- **Problem:** Der GPIO-Clock-Puls war nur wenige NOPs breit und konnte bei normaler Analog-Discovery-Samplerate/Zoom unsichtbar bleiben.
- **`src/hal/hal_spi.c`:** Clock-Puls über **`display_clk_pulse()`** deutlich gestreckt; **`hal_spi_init_16bit()`** erzeugt zusätzlich einen langsamen 16-Puls-Startburst (**DATA high nur beim ersten Puls**) direkt nach der GPIO/PPS-Konfiguration. Damit lässt sich ohne laufenden Multiplex-Timer prüfen, ob **`RG6`/`RC1`** elektrisch am LA ankommen.
- Build **`make -f nbproject/Makefile-default.mk CONF=default build`** ok.

## 2026-05-12 — Harte RG6/RC1-Boot-Probe

- **`src/tasks/main.c`:** Temporär **`DISPLAY_PIN_PROBE=1`**: nach **`hal_sys_init()`** kein FreeRTOS/Display-Treiber, sondern direkte SFR-Endlosschleife. **SPI2 aus**, **PPS `RPG6R`/`RPC1R` abgeklemmt**, **RG6** und **RC1** als GPIO-Ausgänge. **RG6 toggelt kontinuierlich**, **RC1 toggelt langsamer**. Zweck: beweisen, ob geladenes HEX läuft und ob die gemessenen Netze überhaupt vom PIC getrieben werden.
- Build **`make -f nbproject/Makefile-default.mk CONF=default build`** ok. Wenn damit am MCU-Pin/Connector nichts sichtbar ist, liegt es nicht am Multiplex-Code, sondern an Flash/Programmlauf/Pinmapping/Messpunkt/Hardware.

## 2026-05-12 — Pin-Probe aus, Display wieder aktiv

- **Hinweis:** Im Probe-Modus wird **nur `RG6`/`RC1`** getaktet, **kein `PORTD` (Segmentbus)** — die Anzeige bleibt deshalb leer, obwohl CLK/DATA sichtbar sind.
- **`src/tasks/main.c`:** **`DISPLAY_PIN_PROBE=0`**, wieder **FreeRTOS + `display_kyb_init()`** wie zuvor.

## 2026-05-13 — ROOT CAUSE: Core-Timer-ISR nie an Vektor 0 angebunden

- **Symptom:** Display-Multiplex-Timer feuert nie → keine Segment-Ausgabe, nur Init-Burst sichtbar.
- **Ursache:** `CT_wrapper` in `isrWrappers.S` war als `.global` deklariert, aber **nicht** in `.section .vector_0` platziert. `__vector_dispatch_0` kam deshalb aus `libpic32.a(vector0.o)` und sprang zu `_DefaultInterrupt`. Der Core-Timer-Interrupt (1 ms, ~90 Hz Framerate bei 11 Slots) wurde **nie** an `CT_handler` dispatcht.
- **Fix `src/hal/isrWrappers.S`:** `.section .vector_0, code, keep` mit `__vector_dispatch_0: j CT_wrapper; nop` am Ende. Linker-Map bestätigt: `.vector_0` aus `isrWrappers.o`.

## 2026-05-13 — DATA/CLK-Protokoll nach Original-Board-Messung korrigiert

- **Protokoll (gemessen am Keithley 199):**
  - **CLK (RG6):** idle LOW. Kurze HIGH-Pulse zum Digit-Advance.
  - **DATA (RC1):** idle HIGH. Kurzer LOW-Pulse (1→0→1) = Frame-Reset auf Digit 0.
  - **Segmentbus (PORTD):** aktiv HIGH = Segment an.
  - **Framerate:** ~90 Hz (11 Slots × ~1 ms).
- **`src/hal/hal_spi.c`:** `hal_display_select_step(frame_start)`:
  - `frame_start == true` → **DATA kurz LOW** (Reset), kein CLK.
  - `frame_start == false` → **CLK kurz HIGH** (Advance), DATA bleibt HIGH.
  - Init: CLK=LOW, DATA=HIGH, einmaliger DATA-Reset-Puls.
  - Alter Init-Probe-Burst (16 langsame Pulse) entfernt.
- **`src/tasks/main.c`:** Nur `display_puts("HELLO")` – kein Snake, kein Blink. Task wartet in Endlosschleife, Multiplex läuft im Core-Timer-ISR.

## 2026-05-13 — Alle Digits in einem 90-Hz-Frame durchgetaktet

- **Problem:** Timer feuerte bei ~1 kHz und schaltete nur **1 Digit pro ISR**-Aufruf weiter. Ergebnis: auf dem LA sieht man CLK mit ~1 kHz gleichmäßig verteilt, aber nur ein Digit pro Tick → die Anzeige zeigt effektiv nur ein Segment.
- **Fix `src/drivers/dispkyb.c`:**
  - **`FRAME_PERIOD_US = 11111`** (≈ 90 Hz) statt 1000 µs.
  - **`hal_disp_scan()`** iteriert jetzt **alle 11 Digit-Positionen** in einem Aufruf:
    - Position 0: Segmente setzen → **DATA-Pulse** (Reset) → ~1 ms halten.
    - Position 1–10: Segmente setzen → **CLK-Pulse** (Advance) → ~1 ms halten.
  - Keyboard-Scan pro Digit innerhalb der Schleife (Matrix teilt Digit-Select).
  - Nach letztem Digit: **Segmente auf 0** (Ghosting vermeiden).
  - **`DIGIT_HOLD_LOOPS = 16000`** ≈ 1 ms Hold pro Digit bei 80 MHz.
- **Ergebnis am LA:** Pro 90-Hz-Frame: 1× DATA LOW-Pulse + 10× CLK HIGH-Pulse + Segmentbus wechselt synchron.

## 2026-05-13 — Frame-Pause eliminiert + alle 10 Stellen beschrieben

- **Problem 1:** Nach dem 11-Digit-Burst (≈11 ms) wartete der Core-Timer noch ~100 ms bis zum nächsten Frame. **Ursache:** `hal_core_timer_update` addierte `period` auf den **alten Compare-Wert**. Wenn die ISR länger dauerte als `period`, lag der neue Compare bereits in der Vergangenheit → nächster Interrupt erst nach Count-Wrap (~107 s) oder undefiniert spät.
- **Fix `src/hal/hal_timer.c`:** `hal_core_timer_update` liest jetzt **CP0 Count** (`mfc0 $9`) und setzt Compare = Count + delta. Der nächste Interrupt feuert garantiert `period` Ticks nach ISR-Ende.
- **`FRAME_PERIOD_US = 100`** (war 11111): nur 100 µs Pause nach ISR-Ende. Frame-Dauer ≈ 11 ms (Hold-Delays) + 0.1 ms (Timer) ≈ **90 Hz**.
- **Problem 2:** „HELLO" belegt nur Positionen 0–4; Stellen 5–9 waren leer.
- **Fix `src/tasks/main.c`:** `display_puts("0123456789")` – alle 10 sichtbaren Digit-Positionen haben Segmentdaten.

## 2026-05-14 — Digit-Select: 16-Bit-SPI-Worter statt einzelne CLK-Pulse

- **Entdeckung:** LA-Capture vom Originalboard zeigt, dass CLK+DATA ein vollstandiges **16-Bit-SPI-Protokoll** fahren (MSB first, Mode 0). Jede Digit-Position bekommt ein eigenes 16-Bit-Wort in ein kaskadiertes Schieberegister getaktet. **Aktiv-Low:** 0-Bits aktivieren den Digit-Treiber.
- **Gemessene Muster (11 Positionen):**
  `FFDF, FBFF, 7FEF, FDFF, BFF7, FEFF, DFFB, FF7F, EFFD, FFBF, F7FE`
  Positionen 0,1,3,5,7,9 haben je 1 Bit low (reine Digit-Selektion).
  Positionen 2,4,6,8,10 haben je 2 Bits low (Digit + vermutlich Keyboard-Scan-Zeile).
  Position 10 = Mode-LEDs (STO, RCL, FLTR, REM, VOLTS, OHMS, AMPS, AC, ZERO, AUTO).
- **Warum vorher nichts angezeigt wurde:** Der alte Code sendete nur einzelne CLK-Pulse mit DATA=HIGH → Schieberegister bekam 0xFFFF (alle Bits high = **kein Digit aktiv**).
- **`src/hal/hal_spi.c`:** `digit_select[11]`-Lookup-Table mit den 11 Originalmustern. `hal_spi_write_16bit()`: Bitbang 16 Bit MSB-first (CLK idle LOW, DATA sampled auf Rising Edge). `hal_display_select_digit(position)` wahlt das passende Wort.
- **`src/hal/hal_spi.h`:** `hal_display_select_step` → `hal_display_select_digit(int position)`.
- **`src/drivers/dispkyb.c`:** `display_set` ruft `hal_display_select_digit(position)` statt `hal_display_select_step`.

## 2026-05-14 — SPI atomar + AZ↔Bus-Zuordnung

- **Symptom LA:** Wenige CLK-Takte, lange Lücke, dann wieder Takte; SPI-Decoder zeigt keine durchgehende `FFDF…`-Folge — **16-Bit-Wort wurde von einem Interrupt geteilt** (z. B. gleich priorisierte ISR), sodass die Messung wie zwei Bruch-Transfers aussah und DATA/CLK „asynchron“ wirkte.
- **Fix `hal_spi_write_16bit`:** Gesamtes 16-Bit-Shiften unter **`hal_irq_disable` / `hal_irq_restore`**; kurze NOP-Pausen nach DATA-Setup und nach CLK-Low.
- **Falsche Ziffern / doppelte „5“:** Reihenfolge der Glas-Stellen (AZ0…AZ9) stimmt nicht mit Bus-Indizes 0…9 überein (typisch bei Multiplex). **`digit_bus_line[11]`** mappt Zeichen-Slot → Bus: aktuell **`{0,9,8,3,4,5,6,7,2,1,10}`** aus deiner Beobachtung (1↔9 wegen „AZ1 zeigt 9“-Effekt, 2↔8 wegen doppelter „5“). **`hal_digit_bus_line()`** + `display_set` nutzt das automatisch.
- **Tastatur:** Scan-Switch verwendet jetzt den **Bus-Index**, nicht mehr den Zeichen-Slot-Index.
- **`hal_spi.h`:** `hal_digit_bus_line(int char_slot)` dokumentiert.

## 2026-05-14 — Display-SPI: Hardware SPI2 + kürzere Multiplex-Pausen

- **Lange Lücken zwischen 16-Takt-Bursts:** Kommt vom **Multiplex** (`digit_hold` nach jedem Digit), nicht von „fehlendem Takt innerhalb eines Worts“. Zusätzlich war **`PMD5SET` SPI2** nach dem früheren GPIO-Init fälschlich gesetzt worden (SPI2-Modul aus) — entfernt im neuen Pfad.
- **Dünne DATA / falsche Decoder-Werte:** Software-Bitbang war empfindlich; jetzt **SPI2 als Master 16 Bit** wie beim Original: durchgehende **16 SCK-Flanken** pro Wort, **~1 MHz** (`SPI2BRG=39` @ 80 MHz PBCLK), gleiche **CKE/MSTEN/DISSDI/MODE16**-Basis wie `hal_adc_spi1_hw_open`.
- **PPS:** `RPC1R = 6` (**SDO2** laut DFP `PIC32MX350F256L.PIC`), `RPG6R = 0`, **kein** `PMD5SET` am Ende von `hal_spi_init_16bit`.
- **`hal_spi_write_16bit`:** `SPITBE` → `SPI2BUF` → `SPIBUSY` → Dummy-Read `SPI2BUF` (RX leeren).
- **`digit_bus_line`:** wieder **Identität** `0..10` (Permutation war inkonsistent mit LA); bei falscher Glas-Reihenfolge nur diese Tabelle anpassen.
- **`dispkyb.c`:** `DIGIT_HOLD_LOOPS` **1600 → 350** (enger zusammenliegende Wörter im Frame; Helligkeit ggf. nachjustieren).

## 2026-05-14 — Kein `0xFFFF` mehr im laufenden Frame; schwache Status-LEDs

- **LA / Original:** Nach `F7FE` folgt direkt wieder `FFDF` — **kein** zwölftes Wort `FFFF` im Multiplex-Zyklus.
- **`hal_disp_scan`:** Abschluss **`hal_io_displayport_write(0)` + `hal_spi_write_16bit(0xFFFF)`** entfernt. Das erzeugte das extra `FFFF` und hielt nach `F7FE` noch die LED-Zeile mit leerem Segmentbus → **schwach leuchtende** Volts/Auto/STO/REM.
- **LED-Zeile:** Für Slot **10** doppelte **`digit_hold`**, damit die Modus-LEDs länger eingeschaltet sind (heller).
- **`digit_bus_line`:** Wieder **`{0,9,8,3,4,5,6,7,2,1,10}`** (Bring-up-Fotos: 1↔9, 2↔8).
- **`hal_spi_init`:** Einmaliges `0xFFFF` nur **nach dem Reset** (Schieberegister sauber); Kommentar ergänzt.

## 2026-05-14 — Display wieder GPIO-Bitbang (LA: FFDF… korrekt)

- **Problem:** Mit **SPI2-Peripheral** zeigte der LA u. a. eine **Walking-Zero**-Folge (`FEFF`, `FDFF`, …) und lange `FFFF` — **nicht** die 11 festen Muster vom Original. Ursache: SPI-**Modus/CKE/SMP** bzw. **16-Bit-Framing** passt nicht zu dem, was die **74xx-Schieberegister** am Board erwarten (Original wurde mit LA auf **Bitbang-kompatibles** Timing gemessen).
- **Fix `hal_spi.c`:** SPI2 wieder **aus** (`SPI2CON.OFF`, `PPS` ab, `PMD5SET` SPI2MD), **RG6/RC1 als GPIO**, **`hal_spi_write_16bit`** = **16× MSB-first** mit `di`/`ei` und längeren NOP-Delays (stabile DATA vor CLK-Flanke). `digit_select` / `digit_bus_line` unverändert.

## 2026-05-14 — GitHub-Repo vorbereitet (schlanker Clone)

- **`.gitignore`:** Alte Regel **`nbproject/Makefile-*`** ließ **keine** MPLAB-Makefiles zu; mit **`!nbproject/Makefile-{default,impl,variables,local-default}.mk`** werden die für **`make -f nbproject/Makefile-default.mk`** nötigen Dateien wieder eingecheckt. Zusätzlich ignoriert: `doc/logic_analysis/`, KiCad **`hw.kicad/*-backups/`**, **`hw.kicad/**/fp-info-cache`**, **`hw.kicad/**/*-backups/`**, **`hw.kicad/**/rescue-backup/`**, **`hw.kicad/gerber/*.zip`**, **`hw.kicad/gerber.zip`**, **`~*.lck`**, `_autosave-*`/`*.kicad_pcb-bak`, `hw.kicad/.history/`, `nbproject/*.gcode`, `nbproject/*#`, Duplikat-Handbuch `doc/KEI 199 Operation, Programming & Maintenance.pdf`, `.generated_files/`, `.DS_Store`, `.cursor/`. **Nach erstem Commit** genannte KiCad-Caches/Backups/Locks wieder aus dem **Index** entfernt (Dateien bleiben lokal).
- **Entfernt:** `.gitmodules` (kein aktives Submodul; **`src/scpi-parser/libscpi`** ist vendored im Tree).
- **`README.md`:** Zeile mit GitHub-Fork **https://github.com/Na55im/keithley199-upgrade** für Zusammenarbeit.
- **Git-Index:** `hw.kicad/.history` war als **gitlink (160000)** eingetragen — mit **`git rm -f --cached`** entfernt, bleibt nur lokal per `.gitignore` ausgeschlossen.
