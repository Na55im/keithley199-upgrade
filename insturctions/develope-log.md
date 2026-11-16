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

## 2026-11-15 — Erstes Flashen per PICkit 3 / ipecmd (MPLAB X 6.05)

- **Befehl bestätigt** und in `CLAUDE.md` eingetragen: `ipecmd.sh` aus **v6.05** mit `-P32MX350F256L -TPPK3 -F<hex> -M -Y`, PICkit an **J2**, keine Versorgung durch den PICkit.
- **Bring-up-Probleme:** „could not detect target voltage VDD“ kam von einer **losen GND-Verbindung** im Programmierkabel. Nach einem Abbruch hing der PICkit („Connection Failed“) bis zum USB-Neustecken.
- **Erster Flash-Lauf** brach nach dem Löschen ab, der zweite programmierte erfolgreich, ein separater Verify gegen `keithley_199-master.production.hex` (Build vom 2026-11-15) bestand.
- **Nachtrag:** Ohne `-OL` hält der angesteckte PICkit 3 den PIC im Reset (Display schwarz, mit abgezogenem PICkit läuft er). `ipecmd … -OL` gibt ihn frei; `-OL` gehört deshalb fest in den Flash-Befehl.

## 2026-11-15 — `digit_bus_line` per Kamera-Loop korrigiert

- **Vorher** `{0,9,8,3,4,5,6,7,2,1,10}`: Test-String `0123456789` erschien als `?64801753` (Kamera C920 auf dem Display).
- **Abgeleitet:** Glasposition links→rechts wird von Bus **8, 6, 4, 2, 0, 9, 7, 5, 3** getrieben; Bus 1 hat keine sichtbare Stelle (9 Ziffernpositionen am Glas).
- **`hal_spi.c`:** `digit_bus_line = {8,6,4,2,0,9,7,5,3,1,10}`. Ergebnis nach dem Flashen (1. Iteration): `012345678` in richtiger Reihenfolge, das 10. Zeichen (`9`) landet auf dem unsichtbaren Bus 1.
- **Erste Glasposition:** Das untere Segment leuchtet nicht (`0` sieht aus wie `Π`, vorher `2` ohne Unterstrich). Laut Nutzer vermutlich ein **defektes Segment im Display** — kein Firmware-Fehler, nicht weiter verfolgt.

## 2026-11-15 — Messpfad-Bring-up (DCV 3 V): Takt, Display-ISR, ADC ohne PLIB

- **`main.c`:** Statt Display-Test jetzt Messaufgabe: `adc_init(50 Hz, DCV, 3 V)` → `adc_read_value()` → Anzeige `+x.xxxxx`. Beim Start 3 s `OSC n C c` (OSCCON.COSC / CF). Mit `MEAS_DEBUG_COUNTS 1` danach je 2,5 s die Rohzählwerte **A** (Signal), **B** (Signal-Null), **C** (Ref-Null), **D** (Ref). `tskmgr.c` (Settings/EEPROM/Tasten/SCPI) wird noch nicht gestartet.
- **ROOT CAUSE Takt:** COSC = 0 → der PIC lief auf **FRC 8 MHz ohne PLL** (10× zu langsam; alles, was mit 80 MHz rechnet, war falsch). Mit `FNOSC = PRIPLL` + `IESO = ON` bleibt er auf FRC, weil **Quarz X1 nicht anschwingt** (Wert im Schaltplan nicht angegeben). **Fix `fuses.c`:** `FNOSC = FRCPLL` (8 MHz/2×20 = 80 MHz, ±~1 %). Danach COSC = 1, Timing stimmt (per Kamera geprüft). Quarz/Bestückung von X1 prüfen.
- **Display-ISR (`dispkyb.c`):** Vorher alle 100 µs ein kompletter 11-Stellen-Frame mit Warteschleifen im Interrupt → CPU fast nur im ISR, FreeRTOS-Tick ausgebremst, OC3-ISR (gleiche Priorität 3) bis zu einen Frame verzögert. Jetzt **eine Stelle pro Core-Timer-Interrupt** (`SLOT_PERIOD_US = 1000`, 11 Slots ≈ 90 Hz), keine Warteschleifen; Tastenauswertung einmal pro Frame. Anzeige gleichmäßig hell.
- **`hal_adc.c` ohne PLIB:** Timer2/3 (32 bit, PBCLK/32), OC3 Continuous-Pulse (32 bit, `OC3RS = Periode − 63`, `OC3R = 0`, IPL3), Timer4/5 als 32-bit-Zähler an T4CK, PPS direkt: `RPG1R = 11` (OC3→ASTROBE), `RPF8R = 8` (SDO1→ADATA), `T4CKR = 6` (RPE3←ACOUNT). Bug behoben: `hal_adc_set_integration_period` setzte OC3RS mit der µs-Zahl statt mit Timer-Ticks. OC3-Vektor 14 kommt aus dem `vector()`-Prototyp in `hal_adc.c` (keine zweite Dispatch-Section in `isrWrappers.S` anlegen → doppelte Definition). `OC3_handler` jetzt `nomips16`. RE3 mit internem Pull-up (`CNPUESET`), weil ACOUNT auf der Platine keinen hat.
- **Ergebnis:** Messschleife läuft durch, aber **A = B = D = 256, C = 257** (bei 0 V und Riden aus): Zähler sieht praktisch keine Pulse (256 = 2 × 128 + 0). Signal − Null = 0, Referenz − Null ≈ 0 → Anzeige `+0.00000`. Pull-up an RE3 änderte nichts.
- **Nächster Schritt (braucht Messgerät):** Mit LA/Oszi an ASTROBE (RG1), ACLOCK (RF6), ADATA (RF8) und ACOUNT (RE3/P18.6) prüfen, ob Strobe/Mux-Bytes rausgehen und ob die Analogplatine Zählpulse liefert. Netlist: ACLOCK/ADATA/ASTROBE gehen über U9, ACOUNT direkt von P18.6.
- **Nachtrag (Riden als Reiz, 0/1/2 V stabil):** Mit 80 MHz zählt ACOUNT **0 Pulse** (auch 1 s freilaufend). Die vorherigen 256/512-Werte entstanden nur beim Umschalten des Riden-Ausgangs (Störimpulse).
- **Gegenproben:** (a) alte `~/Downloads/keithley_199/build/release/k199.hex` (Dez 2025, F128L-Build): Display bleibt dunkel. (b) KMM-Timing ×10 langsamer (`KMM_SLOW`, SPI 100 kHz, Strobe 250 µs): A=B=C=D (387/774), phasenunabhängig → Übersprechen, keine Messung. (c) ganzer Chip auf FRC 8 MHz (Zustand vor dem Takt-Fix): ebenfalls nur 129…512, „OVERFLO“. In keiner Variante liefert die Analogplatine phasenabhängige Zählwerte.
- `KMM_SLOW` (Default 1) bleibt als Stellschraube in `hal_adc.c`.
- **„0.00000 mit wackelnden letzten Stellen“ reproduziert:** Das war die **erste Messfirmware dieser Session** (Fuse `PRIPLL` → real FRC 8 MHz, alter Display-ISR, der die CPU fast komplett belegt). Nachgebaut und mit Riden geprüft: A/B/C/D ≈ **11532…11535** (vereinzelt 11916), freilaufend F ≈ 460…930 Pulse/s, Anzeige `+0.00000`, selten `+0.02205` oder `NAN`. **Bei 0, 1 und 2 V identisch** → die Analogplatine liefert in diesem Zustand Zählpulse, der Eingang wird aber nicht gemessen (Mux-Befehle schalten offenbar nicht auf den Eingang). Bei 80 MHz kommen dagegen gar keine Pulse → Timing der KMM-Schnittstelle ist entscheidend (Integration hier effektiv 200 ms statt 20 ms, Strobe 250 µs, SPI 100 kHz, Wartezeiten ~100× länger).

## 2026-11-15 — Timing-Loop an der KMM-Schnittstelle (80 MHz, Riden 0 V / 2 V)

- **Stellschrauben in `hal_adc.c`:** `KMM_SLOW` (Strobe-Breite, Start-Wartezeit, SPI1-Teiler), `ADC_INT_SCALE` (Integrationszeit × n), `KMM_MUX_WAIT`, `KMM_INT_WAIT`, `KMM_SETTLE_WAIT`, `KMM_RUNDOWN_WAIT` (FreeRTOS-Ticks, 1,67 ms). `main.c` zeigt S = A−B (Signal−Null), R = D−C (Ref−Null), A (roh).
- **Alles schnell (Original-Werte):** 0 Pulse. **r1 alles langsam** (Strobe 250 µs, SPI 100 kHz, Integration 200 ms, Wartezeiten 100–200 ms): A 3346…17110, S/R nur 0/±1/±127/±128/254.
- **r2** (nur Integration 20 ms), **r3** (nur Strobe/SPI schnell), **r4** (nur Wartezeiten kurz): alle liefern Pulse, A schwankt zwischen Zyklen stark (1297…9216), **S und R bleiben ≈ 0 (±1 Zählschritt) bei 0 V und 2 V**.
- **Deutung:** Innerhalb eines Zyklus zählen alle vier Integrationen gleich viel, über die Zyklen schwankt es. Das Zählsignal hängt also nur vom Zeitfenster ab, nicht von Mux-Konfiguration oder Eingangsspannung → entweder kommen die Mux-/Integrator-Befehle auf der Analogplatine nicht an, oder auf ACOUNT liegt ein freilaufendes Signal/Störung statt der A/D-Pulse. Laut Handbuch 5.4: Charge-Balance-Pulse mit konstanter Frequenz + Final-Slope mit 3,84-MHz-Takt; ACOUNT kommt über einen Optokoppler (AT1 HCPL-2631) und braucht vermutlich einen kräftigen Pull-up.

## 2026-11-15 — Software-Logikanalysator auf ACOUNT (RE3)

- **`main.c`:** `la_sample()` tastet RE3 mit ~10 MHz bei gesperrten Interrupts ab (Flanken, High-Anteil, min./max. Pulsbreite). Anzeige T (kHz), H (‰ High), E (steigende Flanken), P/Q (min. High/Low-Breite), X (max. High). Über `hal_adc_int_hook` (neu in `hal_adc.c`) wird 10 ms **direkt nach dem Start-Strobe der Integration** abgetastet.
- **Ergebnis (0 V und 2 V, Pull-up an):** H = 1000 ‰, E = 0 – auch während der Integration **keine einzige Flanke**.
- **Polarität geprüft** (`KMM_DATA_INV`, `KMM_CKP`, alle 4 Kombinationen): unverändert H = 1000, E = 0.
- **Mit Pull-down statt Pull-up:** weiterhin H = 1000 → ACOUNT wird von der Analogseite **aktiv High** gehalten (Optokoppler-Ausgang versorgt, aber nie angesteuert).
- **Schluss:** Der A/D-Wandler auf der Analogplatine pulst nicht. Entweder kommen Takt/Daten/Strobe dort nicht an (U9 = CD4050 → P18.4/5/7 → Optokoppler), oder die Analogplatine wandelt aus anderem Grund nicht. Weitere Eingrenzung nur mit Messung an P18.4/5/7 bzw. am Optokoppler-Eingang auf der Analogplatine. Die früheren Zählwerte (256, 2049, 11535 …) waren Störimpulse.
- Pull-up an RE3 wieder aktiv; Stellschrauben stehen auf `KMM_SLOW 10`, `ADC_INT_SCALE 10`, kurze Wartezeiten, keine Inversion.

## 2026-11-15 — ROOT CAUSE ADC: PPS-Sperre aus der Display-Init → **DCV misst**

- **Eingrenzung ohne Messgerät:** Statischer Pin-Test (P18.4/5/7 schalten 0 V ↔ 5 V, Nutzer gemessen), Analogversorgungen U50–U53 ok (Nutzer). Bitbang-Test: Befehl „Integration starten“ (`0x01FFE29D`) per GPIO-Bitbang + GPIO-Strobe → ~65 770 Flanken / 50 ms auf ACOUNT, „Stopp“ → 0. Mit Hardware-SPI1 (SDO1→RF8) **oder** OC3-Strobe (→RG1): 0 Flanken.
- **Ursache:** `hal_spi_init_16bit()` (Display) setzte nach dem Umstellen von RPG6R/RPC1R `CFGCONbits.IOLOCK = 1`. Mit Fuse `IOL1WAY = ON` ist die Sperre bis zum Reset endgültig → `RPF8R = 8`, `RPG1R = 11`, `T4CKR = 6` aus `hal_adc_init()` wurden ignoriert. SDO1/OC3 kamen nie an die Pins; die Analogplatine bekam nie einen Befehl.
- **Fix `hal_spi.c`:** IOLOCK nicht mehr setzen (Kommentar im Code).
- **Ergebnis (Original-Timing, `KMM_*` alle Standard, Riden als Quelle, 3-V-Bereich, unkalibriert gain = 1, offset = 0):**

  | Riden | Keithley |
  |---|---|
  | 0,001 V | +0.00050 |
  | 0,501 V | +0.49060 |
  | 1,002 V | +0.98095 |
  | 1,502 V | +1.47130 |
  | 2,002 V | +1.96089 |
  | 2,503 V | +2.45093 |

  Ausgleichsgerade: Steigung 0,97947, Offset −0,27 mV, Restfehler ≤ ±0,41 mV (Riden-Auflösung 1 mV). → Linear; die −2,05 % sind fehlende Kalibrierung.
- Die vorherigen Timing-/Polaritäts-/Takt-Experimente waren alle durch die PPS-Sperre maskiert. Diagnosewerkzeuge bleiben im Code: `KMM_*`-Stellschrauben (`hal_adc.c`), `KMM_PIN_TEST` und `MEAS_DEBUG_COUNTS` (`main.c`, beide 0), Software-LA `la_sample()`.

## 2026-11-15 — DCV-Kalibrierung gegen Riden, Werte im PIC-Flash (`src/tasks/cal_dcv.h`)

- **Vorgabe Nutzer:** Vorhandene Kalibrierwerte (EEPROM / Analogmodul) **nie überschreiben**. Geprüft: Die aktuelle Firmware linkt keinen EEPROM-, I²C-, NVM-, `calibration_*`- oder `settings_*`-Code (xc32-nm, nur Code/Daten-Symbole). Flashen per ipecmd beschreibt nur den PIC-Programmspeicher.
- **Speicherort:** Konstanten-Tabelle `cal_dcv_table[]` in `src/tasks/cal_dcv.h` (Teil der Firmware, überlebt jedes Neuflashen, versioniert). Modell: Anzeige y = gain·x + offset → x = (y − offset)/gain, angewendet in `main.c` (`cal_dcv_apply`). Anzeige-Nachkommastellen pro Bereich ebenfalls dort (5½ Stellen).
- **Referenz:** Riden-Rückmessung über Modbus (1 mV Auflösung, ~0,1 %). Genauer als das Riden kann die Kalibrierung nicht sein.

  | Bereich | Punkte | gain | offset | Restfehler |
  |---|---|---|---|---|
  | 300 mV | 11 × 0…0,3 V | 0,976344 | −253,8 µV | ±0,5 mV (Riden-Stufen) |
  | 3 V | 11 × 0…3,0 V | 0,9795148 | +43,2 µV | ±0,5 mV |
  | 30 V | 11 × 0…30 V | 0,9793800 | −69 µV | ±1,1 mV |
  | 300 V | 11 × 0…30 V (nur 10 % des Bereichs, Riden-Grenze 30 V im Skript) | 1,074483 | +0,73 mV | ±4,5 mV |

- **Kontrolle mit Kalibrierung (neue Punkte):** 30 V: 5,0023 / 10,5020 / 19,7516 / 28,4989 / 30,0002 V gegen Riden 5,0025 / 10,5015 / 19,752 / 28,500 / 30,000 → ≤ ±1,1 mV. 3 V: 0,15035 / 1,00134 / 2,25154 / 2,95228 V gegen 0,1505 / 1,0015 / 2,252 / 2,953 → ≤ ±0,8 mV.
- Bereich wird noch per `MEAS_RANGE` in `main.c` gewählt (Standard jetzt `ADC_RANGE_3`). 300-mV-Nullpunkt besser mit kurzgeschlossenem Eingang nachkalibrieren; 300-V-Bereich oberhalb 30 V ungeprüft.

## 2026-11-15 — Frontpanel-Filter (FLTR) + LED-Zeile repariert

- **Filter (`main.c`):** Gleitender Mittelwert über `FILTER_N = 30` Wandlungen wie im Original (Handbuch 2.6.3). Fenster `FILTER_WINDOW = 1e-3` × Bereichsendwert (Originalwert im Scan nicht lesbar): liegt ein neuer Wert außerhalb, startet die Mittelung neu. FLTR-LED blinkt bis 30 Werte gemittelt sind, dann Dauerlicht; bei Über-/Unterlauf Reset. Angewendet nach der Kalibrierung. Abschaltbar mit `FILTER_ENABLED 0`.
- **Test mit Riden:** 1,500 V eingeschwungen: Anzeige 1,50194…1,50196 (±1 Digit, vorher ±3…5). Sprung 1,5 → 2,0 V: nach 0,5 s 2,00165, danach 6 s Nachkriechen auf 2,00174 (Riden-Ausgang).
- **`dispkyb.c` `display_clear()`:** Modus-Bits wurden in einem `char` zwischengespeichert → FLTR/AUTO/OHMS/REM gingen bei jedem `display_clear()` verloren. Jetzt `uint16_t`.
- **LED-Zeile:** Mit `0xFFFF` als Modus erschien „alle Segmente“ auf der 1. Glasstelle statt in der LED-Zeile. Die LEDs hängen an **Bus 1** (FBFF), nicht an Bus 10 (F7FE); Bus 10 überlagert die 1. Glasstelle. `digit_bus_line = {8,6,4,2,0,9,7,5,3,10,1}`. Danach leuchten alle 10 LEDs (STO, RCL, FLTR, REM, VOLTS, OHMS, AMPS, AC, ZERO, AUTO); im Messbetrieb VOLTS + FLTR.

## 2026-11-15 — Einheit in der Anzeige, 6½ Stellen, stärkere Mittelung

- **`cal_dcv.h`:** pro Bereich Nachkommastellen, Anzeigeskala und Einheit: 300 mV → `+303.000mV` (5½, „mV“ braucht 2 Stellen), 3 V → `+3.030000V`, 30 V → `+30.30000V`, 300 V → `+303.0000V` (6½ Stellen wie im Original-README angegeben). `format_value()` hängt die Einheit an und richtet rechtsbündig auf 9 Glasstellen aus.
- **Filter:** `FILTER_N` 30 → **100**. Bei 1,5 V (Riden): mit 30 springt die 7. Stelle um 3…12 µV pro Sekunde, mit 100 in 1…3-µV-Schritten. In beiden Fällen sinkt der Wert um ~30 µV in 10 s — Drift des Riden-Ausgangs, nicht des 199. Sprünge > 0,1 % FS setzen den Mittelwert weiterhin sofort zurück.
- Die 7. Stelle ist Auflösung, keine Genauigkeit: Kalibrierreferenz ist das Riden (1 mV, ~0,1 %).

## 2026-11-15 — Autorange DCV

- **`main.c`:** Bereichsfolge 300 mV → 3 V → 30 V → 300 V. Hoch bei Über-/Unterlauf, runter wenn |U| < 90 % (`AUTORANGE_DOWN`) des Endwerts des nächstkleineren Bereichs. Beim Wechsel `adc_set_range()`, Filter-Reset, erste Wandlung verworfen. AUTO-LED an. Startbereich `MEAS_RANGE` (3 V), abschaltbar mit `AUTORANGE 0`. Einheit/Nachkommastellen folgen dem aktiven Bereich.
- **Test mit Präzisions-5-V-Quelle des Nutzers:** vorher fest 3 V → „OVERFLO“. Jetzt automatisch 30 V-Bereich, Anzeige **+4.99985 V** (±1 Digit, entspricht −30 ppm bei 5,00000 V); VOLTS, AUTO, FLTR leuchten.
- Abwärts-/Aufwärtswechsel mit dem Riden noch nicht getestet (Präzisionsquelle hing am Eingang).

## 2026-11-15 — DCV-Nachkalibrierung gegen Keithley 2700

- **Aufbau:** RD6018P als Quelle parallel an 199 und 2700 (6½ Stellen, SLOW, Filter, Autorange); vorher Sicherheitsprüfung (1 V, 0 mA, CV). Beide Anzeigen per Kamera (`tools/cal_vs_ref.py`: baut/flasht pro Bereich mit `AUTORANGE 0`, fährt 11 Punkte, 22 s Einschwingzeit, Kachelbild 2700 | 199). Werte aus den Bildern abgelesen; Fit der bisher kalibrierten 199-Anzeige gegen das 2700, mit der alten Kalibrierung verkettet (gain_neu = g·g2, offset_neu = g·o2 + o).

  | Bereich | gain | offset | Restfehler | vorher (Riden) |
  |---|---|---|---|---|
  | 300 mV | 0,9757958 | +5,6 µV | ≤ 19 µV | 0,976344 / −253,8 µV |
  | 3 V | 0,9794453 | +24,8 µV | ≤ 17 µV | 0,9795148 / +43,2 µV |
  | 30 V | 0,9794307 | −84,3 µV | ≤ 0,24 mV | 0,9793800 / −69 µV |
  | 300 V (nur 0…30 V) | 1,0746249 | −385,6 µV | ≤ 0,55 mV | 1,074483 / +0,73 mV |

- **30-V-Bereich:** Das 2700 wechselt bei 10 V vom 10-V- in den 100-V-Bereich; beide unterscheiden sich um ~40 ppm (innerhalb 2700-Spez. 30/45 ppm). Fit über alle Punkte = Mittel.
- **Kontrolle (Autorange, neue Punkte), 199 − 2700:** 100,298 vs 100,2936 mV (+4 µV); 0,50076x vs 0,500775 V (≈ −12 µV); 1,502005 vs 1,50200 (+3 ppm); 2,902357 vs 2,90235 (+2 ppm); 4,50186 vs 4,50193 (−16 ppm); 10,00086 vs 10,00119 (−33 ppm); 24,99958 vs 24,9997 (−5 ppm). → alle ≤ ±35 ppm, im Rahmen der 2700-Genauigkeit.

## 2026-11-15 — Display-Flackern reduziert

- **Ursachen:** (1) 11 Slots × 1 ms = ~90 Hz Bildwiederholung. (2) Bei jedem Messwert `display_clear()` + `display_puts()` → der Multiplex-ISR konnte eine halb gelöschte Anzeige zeigen (kurzes Dunkelblitzen ~8×/s).
- **Fix `dispkyb.c`:** `SLOT_PERIOD_US` 1000 → **500** (~180 Hz, gleiche Helligkeit, da Tastverhältnis 1/11 bleibt). Neue Funktion **`display_show()`**: baut den Text in einem lokalen Puffer und kopiert ihn mit gesperrten Interrupts in `screen[]` (LED-Zeile und ADC-Punkt bleiben). `main.c` nutzt sie für alle Messwert-Ausgaben.
- **Kamera-Check:** Einzelbilder (ohne Mittelung) zeigen jetzt immer die komplette Anzeige; vorher oft nur 1–3 Stellen pro Bild.
- **Nachtrag (Nutzer sah weiter Flackern):** Der Software-LA-Hook (`la_int_hook`) lief noch bei jeder Messung und tastete ~10 ms mit **gesperrten Interrupts** ab → Multiplex stand ~8×/s still (eine Stelle hell, Rest dunkel). Hook jetzt nur noch mit `MEAS_DEBUG_COUNTS 1` aktiv.

## 2026-11-15 — 300-V-Bereich bis 56,5 V gegen Keithley 2700

- **Riden-Grenze** in `tools/rd6018.py` auf ausdrücklichen Wunsch des Nutzers von 30 V auf **60 V** angehoben (Strom weiter 0,5 A max., Läufe mit 0,1 A, OVP 58–61 V).
- Das RD6018P erreicht mit 60,6 V Eingangsspannung nur ~56,9 V (bei 59,5 V Soll → CC-Meldung, Lauf sicher abgebrochen). Oberster Punkt daher 56,5 V. `cal_vs_ref.py` speichert die Bilder jetzt auch nach einem Abbruch.
- **11 Punkte 0…56,5 V:** Restfehler ≤ 0,33 mV (Anzeigeauflösung 0,1 mV). Neu: gain **1,0746032**, offset **−64,2 µV** (vorher 1,0746249 / −385,6 µV aus 0…30 V).
- **Kontrolle (Autorange):** 32,9989 vs 32,9985 V (+12 ppm), 44,9970 vs 44,9967 V (+7 ppm), 55,9928 vs 55,9934 V (−11 ppm).

## 2026-11-16 — Alle Frontpanel-Funktionen des 199 (`src/tasks/app_dmm.c`)

- **Neue App** `app_dmm.c` (aus `main.c` per `#include`, damit das Makefile unverändert bleibt; nach Änderungen `touch src/tasks/main.c`). Kein EEPROM-/Settings-Zugriff (geprüft mit `xc32-nm`).
- **Funktionen:** DCV, ACV, DCA, ACA, Ω 2-Draht, Ω 4-Draht. Bereiche: V 300 mV…300 V, A 30 mA/3 A, Ω 300 Ω…3 MΩ. Autorange je Funktion, manuell mit ▲/▼. Nur DCV ist kalibriert (`cal_dcv.h`), alles andere zeigt Rohwerte.
- **Tasten** (Tastatur liefert jetzt Rohcodes `KEY_RAW(bus,ch)`, vom Nutzer per Anzeige „KEY bb.c“ ermittelt): VOLTS 6.1, AMPS 6.2, AUTO 6.3, OHMS 10.1, LOCAL 10.2, ▲ 10.3, AC 8.1, TRIGGER 8.2, ▼ 8.3, ZERO 2.3, SCANNER 4.1, NEXT/SHIFT 4.2.
- **SHIFT-Funktionen:** STORE (100 Werte RAM), RECALL (▲/▼ blättern), FILTER ein/aus, dB (re 1 V bzw. 1 mA, nur AC), RESOLN 6½→4½→5½, DMM SETUP = LED-Test, TRIG SETUP = Einzel/Dauer, SCAN SETUP = 2/4-Draht. SCANNER schaltet Kanal 0…8.
- **Kamera-Tests mit `APP_DEMO` 1/2** (skriptete Tastenfolge, Riden 1 V): ZERO (+0,000003 V), RESOLN 1.0011 / 1.00110 / 1.001095 V, ACV ~3,3 mV bei DC-Eingang, dB −49,596 = 20·log(3,31 mV), Ω 2W/4W, DCA/ACA, STORE/RECALL, ▼ → OVERFLO im 300-mV-Bereich, ▲, AUTO, FILTER aus/ein, Kanal 1…8→0, LED-Test, Autorange runter nach Riden-Aus. Ω an den abgeschalteten Riden-Klemmen ≈ 2 Ω (ohne bekannten Widerstand nicht bewertbar).
- **DCV-Kontrolle gegen 2700 mit der App:** 149,989 mV vs 0,149989 V; 2,001564 vs 2,00159 V (−15 ppm); 24,9996 vs 24,9989 V (+28 ppm). Die zuvor gesehene Abweichung 1,8 mV war ein eingefrorenes Kamerabild (C920 nach USB-Ausfall weg, Kameraserver neu gestartet).
- **Fix Einzelmessung:** „ONE SHOT“ blieb stehen; jetzt hält die Anzeige den letzten Wert, TRIGGER zeigt „-------“ bis der (bei Filter gefüllte) Wert vorliegt.
- `tools/cal_vs_ref.py` setzt Bereich/Autorange jetzt im Startzustand von `app_dmm.c`.

## 2026-11-16 — Einfrieren nach ZERO + Spannungsänderung

- **Symptom (Nutzer):** ZERO, Spannung anlegen und verändern → Anzeige bleibt stehen (+1.001261 V bei 0,985 V Eingang), Tasten tot. Multiplex (IPL3) lief weiter → die Mess-Task stand.
- Mit scharfen Riden-Sprüngen 0,1…5 V (ZERO bei 0 V und bei 1 V, `APP_DEMO 3`) nicht reproduzierbar.
- **Fix `hal_adc.c`:** Warten auf den OC3-Strobe-Interrupt (`xQueueReceive`) hatte `portMAX_DELAY` → ein verlorener Interrupt (Queue-Länge 1, `xQueueSendFromISR` verwirft bei voller Queue) blockierte für immer. Jetzt `adc_wait_strobe()` mit 200 ms Timeout, Timer2 aus, Zähler `hal_adc_timeouts`. Die App verwirft die Messung und zeigt kurz „ADC TMO n“.
- **Diagnose `main.c`:** `vAssertCalled` zeigt „AS“ + Datei-Kürzel + Zeile, Stack-Overflow-Hook „SO“ + Taskname.
- Nutzer-Test danach: friert nicht mehr ein.

## 2026-11-16 — DCA-Kalibrierung gegen Keithley 2700 (`src/tasks/cal_dca.h`)

- **Aufbau (Nutzer):** RD6018P → 2700 AMPS → 199 AMPS → zurück, in Reihe. Kreiswiderstand (beide Shunts + Leitungen) ≈ 16 Ω (2700 20-mA-Bereich), ≈ 11 Ω (100 mA), ≈ 0,82 Ω (199 3 A / 2700 1 A).
- **Neu `tools/cal_amps.py`:** Punkte als CC (`12` = 12 mA) oder CV (`v0.16` = 0,16 V, Strom = U/R_Kreis, Strombegrenzung nur als Schutz). Abbruch bei offenem Kreis/Schutz. `cal_vs_ref.py` importierbar gemacht (`grab()`, `flash()`), `grab()` wartet bis 30 s auf ein frisches Kamerabild.
- **CC bei kleinen Strömen unbrauchbar:** die Riden-Stromregelung schwankt, 199 und 2700 mitteln über verschiedene Zeitfenster → Verhältnis streute 0,983…0,996. Im CV-Betrieb scharfe, stabile Anzeigen. Ab ~50 mA ist CC ausreichend stabil.
- **30 mA** (11 Punkte 0…29 mA, CV; 25…29 mA nach CC-Vorlauf, damit das 2700 im 100-mA-Bereich bleibt): gain **0,9852014**, offset **−17,28 µA**, Restfehler ≤ 2,5 µA (Sprung ~4 µA zwischen 2700-Bereichen 20/100 mA).
- **3 A** (7 Punkte 0…0,48 A, CC; Riden-Grenze 0,5 A): gain **0,9747351**, offset **−975,96 µA**, Restfehler ≤ 150 µA (leichte Krümmung, vermutlich Shunt-Erwärmung; 2700-Genauigkeit 1-A-Bereich ~0,1 %). Über 0,48 A extrapoliert.
- **Kontrolle (Autorange), 199 vs 2700:** 0 A −0,0008 vs −0,00033 mA; 7,6504 vs 7,65030 mA; 12,7889 vs 12,78898 mA; 19,192x vs 19,19291 mA; 0,150219 vs 0,150270 A (−340 ppm); 0,350427 vs 0,350404 A (+66 ppm).
- **Kameraserver:** liefert keine alten Bilder mehr (503 wenn > 2 s alt) und öffnet die Kamera neu, wenn keine Bilder kommen. Nach USB-Ausfall trotzdem Server-Neustart nötig.

## 2026-11-16 — 3-A-Bereich bis 2,8 A

- **Riden-Strombegrenzung** in `tools/rd6018.py` auf ausdrücklichen Wunsch des Nutzers von 0,5 A auf **3 A** angehoben (Ende der 3-A-Bereiche von 199 und 2700). `cal_amps.py`: Spannungsgrenze 3 V, OVP 4 V, OCP 3,1 A.
- **Lauf** (CC, erst 1 A als Probe, dann 2,8 A abwärts bis 0): Kreis ≈ 0,82 Ω (2,30 V bei 2,8 A). Restfehler ≤ 0,41 mA ohne erkennbare Krümmung (≤ 0,02 % vom Messwert; 2700 im 3-A-Bereich nur 10 µA Auflösung). Der Nullpunkt verschob sich nach den hohen Strömen um +83 µA (Erwärmung).
- Neu (verkettet mit dem Fit bis 0,48 A): gain **0,9753406**, offset **−1002,95 µA**.
- **Kontrolle (Autorange):** 0,299946 vs 0,300048 A (−340 ppm, wie bei 150 mA: Bereichsunterschied 1 A/3 A des 2700); 1,500026 vs 1,50006 A (−23 ppm); 2,600273 vs 2,60025 A (+9 ppm); 0 A zurück im 30-mA-Bereich ≈ −1 µA.
- `cal_vs_ref.grab()` startet den Kameraserver selbst neu, wenn 6 Versuche ohne frisches Bild bleiben (Kamera fällt beim Umstecken des PICkit mit aus, gemeinsamer Hub).

## 2026-11-16 — Fernsteuerung über UART3 (P8/P9) und Mac-Programm

- **Hardware (Nutzer):** FT230X (U2) nicht bestückt; USB-TTL-Wandler (CH340) an P8/P9. P8 = Netz „TxD“ = PIC U3RX (RB3), P9 = Netz „RxD“ = PIC U3TX (RB5).
- **Neu `src/tasks/remote.c`** (aus `app_dmm.c` inkludiert): Zeilenprotokoll 115200 8N1, Beschreibung in `insturctions/remote-protocol.md`. Befehle für Funktion, Bereich, Filter, Stellen, Zero, dB, Trigger, Kanal, Tasten; `STREAM 1` sendet jede Wandlung als `R,…` (Anzeige- und Rohwert), Zustandszeile `S,…` bei jeder Änderung. Kein FreeRTOS im RX-Interrupt (Ringpuffer), Auswertung in der Mess-Task zwischen den Wandlungen. Kein EEPROM-Zugriff, libscpi/`task_scpi` bleiben ungenutzt.
- **Falle: Legacy-plib ist nicht gelinkt.** `UARTConfigure`, `UARTEnable`, `INTEnable`, `INTGetFlag` … stehen im ELF auf Adresse 0 (`xc32-nm`: `00000000 N UARTConfigure`); `hal_uart_open()` springt damit nach 0 → Absturz beim Start. Deshalb UART3 in `remote_init()` direkt über SFRs (U3RXR = 8, RPB5R = 1, U3BRG = 173, BRGH) und `hal_uart3_isr_handler()` in `hal_uart.c` neu ohne plib. `hal_uart_open()`/`hal_uart_interrupt_handler()` nicht verwenden.
- **Bugfix `hal_uart.c`:** `#define HAL_UART_NUMBER_OF_PORTS 2` entfernt (Arrays hatten 2 Einträge, UART3 ist Index 2).
- **Neu `tools/k199_app.py` + `k199_app.html` + `k199_app.command`:** lokaler Webserver (nur Standardbibliothek + pyserial, Port 8200) mit Großanzeige, Bedienung, Verlauf, Statistik, Histogramm, Befehlszeile, CSV-Export und Aufzeichnung nach `tools/logs/`. Sucht das Gerät per `*IDN?`; `--sim` = simuliertes 199. Im Simulator im Browser geprüft.
- `tools/rd6018.py find_port()`: bei mehreren CH340 wird der Riden per Modbus-Modellabfrage erkannt.
- **Test am Gerät:** Wandler per TX-RX-Brücke geprüft (Echo ok). **PIC → Mac funktioniert** (`K199 READY`, `R,…`-Zeilen, ca. 15 Wandlungen/s bei offenem Eingang). **Mac → PIC funktioniert nicht:** Diagnosezeile (`REMOTE_DEBUG 1`) zeigt UART3 richtig konfiguriert (U3STA 0x1610, U3MODE 0x8008, U3RXR 8, IEC1 Bit 31, IPC9 Prio 3), aber RB3 (Pin 22) folgt dem TX des Wandlers nicht: mit internem Pull-down dauerhaft 0, obwohl die Leitung im Ruhezustand High ist; kein anderer Portpin reagiert auf ein Break. Laut `KeithleyUpgrade.kicad_pcb` liegen P8, U3 Pin 22 und U2 Pad 15 auf Netz `/TxD` → auf der Platine ist die Verbindung P8 → Pin 22 offen (Lötstelle Pin 22 oder Leiterbahn). Hardware-Prüfung durch den Nutzer steht aus.
- **Nach Nachlöten von Pin 22 durch den Nutzer: beide Richtungen funktionieren.** Alle Befehle am Gerät geprüft (`*IDN?`, `STAT?`, `RANG?`, `READ?`, `STREAM`, `FUNC`, `RANG`, `FILT`, `DIG`, `ZERO`, `TRIG ONE` + `*TRG`, `CHAN`, `KEY AUTO`, `*RST`, `LOCAL`, Fehlerantworten). Mac-Programm `k199_app.py` am Gerät geprüft: Anzeige, Verlauf, Statistik, Funktionswechsel per Knopf. Erstes Flashen danach schlug zweimal mit „Failed to get Device ID“ fehl (Kontakt), dritter Versuch ok.
- RB3 hat jetzt einen internen Pull-up, damit eine offene RX-Leitung im Ruhezustand bleibt.

## 2026-11-16 — Protokoll für das KLAR-Design erweitert

- **Anlass:** Designpaket „KLAR“ (Nutzer) setzt ein originales 199 mit GPIB voraus. Angepasste Vorgabe in `klar/CLAUDE.md` (Design-Dateien unverändert in `klar/design/`): GPIB/PyVISA gestrichen, serielles Protokoll, Modus-Zuordnung, Liste der Abweichungen vom Entwurf.
- **Firmware (`app_dmm.c`, `remote.c`):**
  - `SPEED FAST|LINE`: Integration ¼ Netzperiode (5 ms) bzw. eine Netzperiode über `adc_set_integration_period()`. Gemessen bei offenem Eingang ohne Filter: 9,2 Wandlungen/s (LINE), 20,6/s (FAST), 23,9/s (FAST, 60 Hz). Messung ist ratiometrisch (Signal/Referenz gleich lang integriert). Genauigkeit FAST gegen LINE geprüft (siehe unten).
  - `LINE 50|60`, `LOCK 0|1` (Tasten → „LOCKED“), `HOLD 0|1` (Anzeige steht, Flag 64).
  - `SCAN <liste>`: Kanäle reihum, erste Wandlung nach Umschalten verworfen, mit Filter nur fertige Mittelwerte. `R`-Zeilen haben jetzt die Kanalnummer als 8. Feld, `S`-Zeile 6 neue Felder.
  - **Bugfix Zeitstempel:** `portTICK_PERIOD_MS` ist bei 600 Hz Tick ganzzahlig 1 → `<ms>` lief 1,67× zu langsam. Jetzt `ticks * 1000 / configTICK_RATE_HZ`. (Gleiches gilt für alle `ms / portTICK_PERIOD_MS`-Wartezeiten in der App: sie dauern 1,67× länger als geschrieben – unkritisch, nicht geändert.)
- `tools/k199_app.py`: neue Felder (Kanal, Speed, Lock, Hold, Scan) in Parser, CSV und Simulator.
- Alle neuen Befehle am Gerät geprüft (inkl. Fehlerfall `SCAN 2,5,9` → `ERR,ARG`).
- **Prüfung FAST gegen LINE** (Riden an VOLTS HI/LO, fester Bereich, ohne Filter, je 2×40 Werte abwechselnd, Rohwerte):

  | Spannung | Bereich | LINE Mittel / σ | FAST Mittel / σ | Differenz |
  |---|---|---|---|---|
  | 0 V (aus) | 300 mV | −55,2 µV / 117 µV | −45,5 µV / 481 µV | +9,7 µV |
  | 0,1 V | 300 mV | 99,3699 mV / 370 µV | 99,3574 mV / 542 µV | −12,5 µV |
  | 1 V | 3 V | 1,0004688 V / 455 µV | 1,0004674 V / 670 µV | −1 ppm |
  | 2,5 V | 3 V | 2,5015851 V / 396 µV | 2,5015934 V / 567 µV | +3 ppm |
  | 25 V | 30 V | 25,00354 V / 85 mV | 25,00168 V / 134 mV | −75 ppm |

  Alle Differenzen liegen innerhalb der Unsicherheit der Mittelwerte (σ/√80). Die Streuung wird vom Riden dominiert (bei 25 V σ 85 mV), FAST rauscht nur ~1,4× mehr. **Ergebnis: Kalibrierung gilt auch im FAST-Modus, keine eigenen Konstanten nötig.** Die Streuung bei 25 V ist auffällig groß (Riden-Rauschen?) und für die Brummunterdrückung im FAST-Modus (keine ganze Netzperiode) noch nicht gesondert geprüft.
