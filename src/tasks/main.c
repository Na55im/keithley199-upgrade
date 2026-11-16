/*
 * Keithley 199 firmware: FreeRTOS + display_kyb + ADC, DMM application in
 * app_dmm.c (included below).
 *
 * The Core Timer ISR (CT_wrapper, vector 0) multiplexes the display,
 * OC3 (vector 14) generates the ADC strobe / integration timing.
 * tskmgr.c (settings/EEPROM/SCPI) is deliberately not started: the existing
 * calibration data in the EEPROM must never be overwritten.
 */
#include <FreeRTOS.h>
#include <task.h>
#include <dispkyb.h>
#include <hal_sys.h>
#include <adc.h>
#include <math.h>
#include <string.h>
#include <xc.h>

#define AUTORANGE_DOWN  0.9           /* go down below 90 % of the lower range's full scale */

#include "cal_dcv.h"

/* Front panel filter as in the original 199 (manual 2.6.3): running average
 * of the last FILTER_N conversions; a reading outside the window around the
 * average restarts the average (fast response to steps). FLTR LED blinks
 * until the average is filled, then stays on. */
#define FILTER_ENABLED    1
#define FILTER_N          100     /* 6.5 digits: 30 (original 199) left the 7th digit jumping by 3..12 uV */
#define FILTER_WINDOW     1e-3      /* fraction of range full scale */
#define DISPLAY_DIGITS  9           /* visible digit positions on the glass */
#define KMM_PIN_TEST 0          /* 1 = static P18 pin test instead of measuring */
#define MEAS_DEBUG_COUNTS 0         /* show raw ADC counts A..D after each value */

extern volatile int adc_last_counts[4];

/* "A" + count right-aligned in 8 digits (low 8 digits, '-' if negative). */
static void show_count(char tag, int count)
{
	char out[12];
	unsigned int u = (unsigned int)(count < 0 ? -count : count);
	out[0] = tag;
	for (int i = 8; i >= 1; i--) {
		out[i] = (char)('0' + u % 10);
		u /= 10;
	}
	out[9] = 0;
	for (int i = 1; i < 8 && out[i] == '0'; i++)
		out[i] = ' ';
	if (count < 0)
		out[1] = '-';
	display_clear();
	display_puts(out);
	vTaskDelay((1500 / portTICK_PERIOD_MS));
}

/* ---- Software logic analyser on ACOUNT (RE3) ---------------------------
 * Samples PORTE.3 in a tight loop with interrupts off and collects edge /
 * pulse-width statistics. Widths are in samples; the sample rate follows
 * from the core timer (40 MHz) ticks spent. */
typedef struct {
	unsigned int samples, ticks, high, rises;
	unsigned int min_hi, max_hi, min_lo, max_lo;
} la_stats_t;

static void __attribute__((nomips16, noinline)) la_sample(la_stats_t *st, unsigned int n)
{
	unsigned int ie, t0, t1, cur, run = 0, i;
	unsigned int prev = (PORTE >> 3) & 1u;

	st->samples = n; st->high = 0; st->rises = 0;
	st->min_hi = st->min_lo = 0xFFFFFFFFu; st->max_hi = st->max_lo = 0;
	__asm__ volatile("di %0" : "=r"(ie));
	__asm__ volatile("mfc0 %0, $9" : "=r"(t0));
	for (i = 0; i < n; i++) {
		cur = (PORTE >> 3) & 1u;
		st->high += cur;
		if (cur != prev) {
			/* close the finished run (ignore the first, truncated one) */
			if (st->rises || i > run) {
				if (prev) {
					if (run < st->min_hi) st->min_hi = run;
					if (run > st->max_hi) st->max_hi = run;
				} else {
					if (run < st->min_lo) st->min_lo = run;
					if (run > st->max_lo) st->max_lo = run;
				}
			}
			if (cur) st->rises++;
			run = 0;
			prev = cur;
		}
		run++;
	}
	__asm__ volatile("mfc0 %0, $9" : "=r"(t1));
	if (ie & 1u) __asm__ volatile("ei");
	st->ticks = t1 - t0;
}

extern void (*hal_adc_int_hook)(void);
static la_stats_t la_int;          /* captured during the first integration */
static volatile int la_armed;

static void la_int_hook(void)
{
	if (la_armed) {
		la_sample(&la_int, 100000u);   /* ~10 ms right after start strobe */
		la_armed = 0;
	}
}

static void show_la_stats(const la_stats_t *p)
{
	la_stats_t st = *p;
	/* k = sample rate in kHz: samples / (ticks / 40e6) / 1000 */
	unsigned int khz = (unsigned int)((unsigned long long)st.samples * 40000ULL / st.ticks);
	show_count('T', (int)khz);                                  /* sample rate kHz */
	show_count('H', (int)(st.high / (st.samples / 1000u)));     /* high time in 1/1000 */
	show_count('E', (int)st.rises);                             /* rising edges in window */
	show_count('P', st.min_hi == 0xFFFFFFFFu ? -1 : (int)st.min_hi); /* min high width */
	show_count('Q', st.min_lo == 0xFFFFFFFFu ? -1 : (int)st.min_lo); /* min low width */
	show_count('X', (int)st.max_hi);                            /* max high width */
}

static void show_la(void)
{
	show_la_stats(&la_int);
}

#if KMM_PIN_TEST
void hal_adc_init(unsigned int period);

static void bb_delay(void) { for (volatile int d = 0; d < 400; d++) ; }

/* spi: SDO1 drives RF8 via PPS (else GPIO). oc: OC3 drives RG1 via PPS (else GPIO). */
static void kmm_route(int spi, int oc)
{
	TRISFCLR = (1u << 8) | (1u << 6);
	TRISGCLR = (1u << 1);
	LATGSET = (1u << 1);                       /* GPIO strobe idle high */
	if (spi) { RPF8R = 8; SPI1CONbits.ON = 1; }
	else     { SPI1CONbits.ON = 0; RPF8R = 0; LATFCLR = (1u << 6); }
	RPG1R = oc ? 11 : 0;
}

static void kmm_send(unsigned int cfg, int spi)
{
	unsigned char b[5] = { 0, (unsigned char)(cfg >> 24), (unsigned char)(cfg >> 16),
	                       (unsigned char)(cfg >> 8), (unsigned char)cfg };
	for (int i = 0; i < 5; i++) {
		if (spi) {
			SPI1BUF = b[i];
			while (SPI1STATbits.SPIBUSY) ;
			(void)SPI1BUF;
		} else {
			for (int k = 7; k >= 0; k--) {
				if (b[i] & (1u << k)) LATFSET = (1u << 8); else LATFCLR = (1u << 8);
				bb_delay();
				LATFSET = (1u << 6); bb_delay();
				LATFCLR = (1u << 6); bb_delay();
			}
		}
	}
}

static void kmm_strobe(int oc)
{
	vTaskDelay(2);
	if (oc) {
		/* one OC3 pulse: start Timer2/3 shortly before OC3RS, let it run one period */
		TMR2 = OC3RS - 200u;
		T2CONSET = _T2CON_ON_MASK;
		vTaskDelay(30);                    /* > 1 integration period (20 ms) */
		T2CONCLR = _T2CON_ON_MASK;
	} else {
		LATGCLR = (1u << 1); vTaskDelay(2); LATGSET = (1u << 1);
	}
}
#endif

static double filt_buf[FILTER_N];
static int filt_count, filt_idx;

static void filter_reset(void)
{
	filt_count = 0;
	filt_idx = 0;
}

/* Returns the filtered value; *settled = 1 once FILTER_N readings are averaged. */
static double filter_apply(double v, double full_scale, int *settled)
{
	if (filt_count) {
		double sum = 0;
		for (int i = 0; i < filt_count; i++)
			sum += filt_buf[i];
		if (fabs(v - sum / filt_count) > FILTER_WINDOW * full_scale)
			filter_reset();
	}
	filt_buf[filt_idx] = v;
	filt_idx = (filt_idx + 1) % FILTER_N;
	if (filt_count < FILTER_N)
		filt_count++;
	double sum = 0;
	for (int i = 0; i < filt_count; i++)
		sum += filt_buf[i];
	*settled = (filt_count == FILTER_N);
	return sum / filt_count;
}

#define APP_DEMO 0                  /* 1 = scripted key sequence for the camera loop */
#include "app_dmm.c"

static void measure_task(void *pvParameters)
{
	(void)pvParameters;
	display_kyb_init();

	/* Bring-up: show active oscillator (OSCCON.COSC) and whether the
	 * primary oscillator failed (CF). 3 = POSC+PLL expected (80 MHz). */
	{
		char osc[12] = "OSC   C  ";
		osc[4] = (char)('0' + ((OSCCON >> 12) & 7));
		osc[8] = (char)('0' + ((OSCCON >> 3) & 1));
		display_clear();
		display_puts(osc);
		vTaskDelay(3000 / portTICK_PERIOD_MS);
	}

#if KMM_PIN_TEST
	/* Static KMM command tests. RF8 = ADATA (P18.4), RF6 = ACLOCK (P18.5),
	 * RG1 = ~ASTROBE (P18.7), RE3 = ACOUNT.
	 * A: bit-bang data + GPIO strobe (known good)
	 * E: hardware SPI1 (SDO1 via PPS) + GPIO strobe
	 * F: bit-bang data + OC3 strobe (PPS)
	 * Each: send "start integration", sample ACOUNT 50 ms, show rising edges,
	 * then send "stop" by bit-bang + GPIO strobe. */
	hal_adc_init(20000u);                       /* SPI1, OC3, Timer2/3, counter, PPS */
	for (;;) {
		for (int t = 0; t < 3; t++) {
			int spi = (t == 1), oc = (t == 2);
			kmm_route(spi, oc);
			kmm_send(0x01FFE29Du, spi);
			kmm_strobe(oc);
			vTaskDelay(5);
			la_stats_t st;
			la_sample(&st, 500000u);
			show_count("AEF"[t], (int)st.rises);
			kmm_route(0, 0);
			kmm_send(0x01FFE29Cu, 0);
			kmm_strobe(0);
			vTaskDelay(5);
		}
	}
#endif

	app_run();
}

int main(void)
{
	hal_sys_init();

	if (xTaskCreate(measure_task, "MEAS", (unsigned short)2048, NULL,
			(tskIDLE_PRIORITY + 2), NULL) != pdPASS) {
		while (1) {
		}
	}

	vTaskStartScheduler();

	while (1) {
	}
}

void vAssertCalled(const char *fileName, unsigned long lineNo)
{
	(void)fileName;
	(void)lineNo;
	while (1)
		;
}

void vApplicationIdleHook(void) {}

void vApplicationStackOverflowHook(void *pxTask, signed char *pcTaskName)
{
	(void)pxTask;
	(void)pcTaskName;
	while (1)
		;
}

void vApplicationMallocFailedHook(void)
{
	while (1)
		;
}
