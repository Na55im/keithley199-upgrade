/*
 * app_dmm.c - Keithley 199 front panel DMM application (bring-up version).
 *
 * Included from main.c (not a separate translation unit) so that the MPLAB
 * makefiles do not have to be touched.
 *
 * Functions: DCV, ACV, DCA, ACA, OHMS 2-wire / 4-wire
 * Range: autorange or manual (UP/DOWN), per function
 * SHIFT functions: STORE, RECALL, FILTER, dB, RESOLN, DMM SETUP (LED test),
 *                  TRIG SETUP (continuous / one-shot), SCAN SETUP (2/4 wire ohms)
 * ZERO: relative reading. SCANNER: steps the scanner channel byte.
 *
 * Only DCV is calibrated (cal_dcv.h). Nothing here reads or writes the
 * EEPROM (existing calibration data must never be overwritten).
 *
 * Keys arrive as raw codes KEY_RAW(bus, channel). key_map[] translates them;
 * unknown codes are shown as "KEY b.c" so the table can be filled in by
 * pressing every key once (camera loop).
 */

typedef enum { F_DCV, F_ACV, F_DCA, F_ACA, F_OHM2, F_OHM4, F_COUNT } func_t;

typedef enum {
	K_NONE, K_VOLTS, K_OHMS, K_AMPS, K_AC, K_ZERO, K_AUTO, K_DOWN, K_UP,
	K_SCANNER, K_TRIGGER, K_SHIFT, K_LOCAL
} lkey_t;

/* raw code -> logical key; filled in from the key learning run */
static const struct { int raw; lkey_t key; } key_map[] = {
	{ KEY_RAW(6, 1),  K_VOLTS   },
	{ KEY_RAW(10, 1), K_OHMS    },
	{ KEY_RAW(6, 2),  K_AMPS    },
	{ KEY_RAW(8, 1),  K_AC      },
	{ KEY_RAW(2, 3),  K_ZERO    },
	{ KEY_RAW(6, 3),  K_AUTO    },
	{ KEY_RAW(8, 3),  K_DOWN    },
	{ KEY_RAW(10, 3), K_UP      },
	{ KEY_RAW(4, 1),  K_SCANNER },
	{ KEY_RAW(8, 2),  K_TRIGGER },
	{ KEY_RAW(4, 2),  K_SHIFT   },   /* NEXT */
	{ KEY_RAW(10, 2), K_LOCAL   },
};

static const adc_range r_volts[] = { ADC_RANGE_300m, ADC_RANGE_3, ADC_RANGE_30, ADC_RANGE_300 };
static const adc_range r_amps[]  = { ADC_RANGE_30m, ADC_RANGE_3 };
static const adc_range r_ohms[]  = { ADC_RANGE_300, ADC_RANGE_3K, ADC_RANGE_30K, ADC_RANGE_300K, ADC_RANGE_3M };

static const struct {
	adc_input input;
	const adc_range *ranges;
	int nranges;
	disp_mode leds;
	int ac;
} fdef[F_COUNT] = {
	[F_DCV]  = { ADC_INPUT_VOLTAGE_DC,    r_volts, 4, DISP_VOLTS,           0 },
	[F_ACV]  = { ADC_INPUT_VOLTAGE_AC,    r_volts, 4, DISP_VOLTS | DISP_AC, 1 },
	[F_DCA]  = { ADC_INPUT_CURRENT_DC,    r_amps,  2, DISP_AMPS,            0 },
	[F_ACA]  = { ADC_INPUT_CURRENT_AC,    r_amps,  2, DISP_AMPS | DISP_AC,  1 },
	[F_OHM2] = { ADC_INPUT_RESISTANCE_2W, r_ohms,  5, DISP_OHMS,            0 },
	[F_OHM4] = { ADC_INPUT_RESISTANCE_4W, r_ohms,  5, DISP_OHMS,            0 },
};

#define STORE_N       100
#define ALL_MODE_LEDS (DISP_STO | DISP_RCL | DISP_FLTR | DISP_REM | DISP_VOLTS | \
                       DISP_OHMS | DISP_AMPS | DISP_AC | DISP_ZERO | DISP_AUTO)

static struct {
	func_t func;
	int ri;                 /* index into fdef[func].ranges */
	int autorange;
	int filter;             /* front panel filter (FLTR) */
	int digits;             /* 5 = 4.5, 6 = 5.5, 7 = 6.5 digits */
	int zero;               /* ZERO (relative) active */
	double zero_val;
	int db;                 /* dB for AC functions */
	int one_shot;           /* TRIG SETUP: one-shot trigger mode */
	int trig_pending;
	int shift;
	int channel;            /* scanner channel 0 (none) .. 8 */
	int storing;            /* STORE: number of readings still to store */
	int stored;
	double store_buf[STORE_N];
	int recall;             /* RECALL active */
	int recall_idx;
	int blink;
	double last;            /* last displayed value (base units) */
	int last_valid;
	int redraw;             /* a message overwrote the reading */
} st = {
	.func = F_DCV, .ri = 1, .autorange = 1, .filter = 1, .digits = 7,
};

static adc_range cur_range(void) { return fdef[st.func].ranges[st.ri]; }

static void set_leds(void)
{
	disp_mode m = fdef[st.func].leds;
	if (st.autorange) m |= DISP_AUTO;
	if (st.zero)      m |= DISP_ZERO;
	if (st.recall)    m |= DISP_RCL;
	if (st.stored == STORE_N && !st.storing) m |= DISP_STO;
	display_clearmode((disp_mode)(ALL_MODE_LEDS & ~(DISP_FLTR | DISP_STO)));
	if (!st.storing && st.stored != STORE_N)
		display_clearmode(DISP_STO);
	display_setmode(m);
	if (!st.filter)
		display_clearmode(DISP_FLTR);
}

static void apply_config(void)
{
	adc_set_input(fdef[st.func].input, cur_range());
	filter_reset();
	st.last_valid = 0;
	set_leds();
}

static void show_msg(const char *s, int ms)
{
	display_show(s);
	vTaskDelay(ms / portTICK_PERIOD_MS);
	st.redraw = 1;
}

/* display scale, unit and integer digits of a range */
static void range_fmt(func_t f, adc_range r, double *scale, const char **unit, int *intdig)
{
	switch (r) {
	case ADC_RANGE_30m:  *scale = 1e3;  *unit = "mA"; *intdig = 2; return;
	case ADC_RANGE_300m: *scale = 1e3;  *unit = "mV"; *intdig = 3; return;
	case ADC_RANGE_3:    *scale = 1.0;  *unit = (f == F_DCA || f == F_ACA) ? "A" : "V"; *intdig = 1; return;
	case ADC_RANGE_30:   *scale = 1.0;  *unit = "V";  *intdig = 2; return;
	case ADC_RANGE_300:  *scale = 1.0;  *unit = (f == F_OHM2 || f == F_OHM4) ? "o" : "V"; *intdig = 3; return;
	case ADC_RANGE_3K:   *scale = 1e-3; *unit = "Ko"; *intdig = 1; return;
	case ADC_RANGE_30K:  *scale = 1e-3; *unit = "Ko"; *intdig = 2; return;
	case ADC_RANGE_300K: *scale = 1e-3; *unit = "Ko"; *intdig = 3; return;
	case ADC_RANGE_3M:   *scale = 1e-6; *unit = "Mo"; *intdig = 1; return;
	case ADC_RANGE_30M:  *scale = 1e-6; *unit = "Mo"; *intdig = 2; return;
	default:             *scale = 1e-6; *unit = "Mo"; *intdig = 3; return;
	}
}

/* Right-aligned number with sign char and unit on the 9 glass positions.
 * decimals = digits - intdig, reduced until it fits. */
static void format_num(char *out, double v, char sign_pos, int intdig, int digits, const char *unit)
{
	int decimals = digits - intdig;
	int ulen = (int)strlen(unit);
	while (decimals > 0 && 1 + intdig + decimals + ulen > DISPLAY_DIGITS)
		decimals--;
	char d[24];
	int n = 0;
	long long scaled = llround(fabs(v) * pow(10.0, decimals));
	for (int i = 0; i < decimals; i++) { d[n++] = (char)('0' + scaled % 10); scaled /= 10; }
	if (decimals) d[n++] = '.';
	do { d[n++] = (char)('0' + scaled % 10); scaled /= 10; } while (scaled && n < 20);
	d[n++] = (v < 0 && llround(fabs(v) * pow(10.0, decimals)) != 0) ? '-' : sign_pos;
	int visible = n - (decimals ? 1 : 0) + ulen;
	int k = 0;
	for (int i = visible; i < DISPLAY_DIGITS; i++) out[k++] = ' ';
	while (n > 0) out[k++] = d[--n];
	for (const char *u = unit; *u; u++) out[k++] = *u;
	out[k] = 0;
}

static void show_value(double v)
{
	char buf[32];
	double scale; const char *unit; int intdig;
	func_t f = st.func;

	if (st.db && fdef[f].ac) {
		/* dB re 1 V (volts) or 1 mA (amps) */
		double ref = (f == F_ACA) ? 1e-3 : 1.0;
		if (fabs(v) < 1e-12) { display_show(" -INF dB"); return; }
		format_num(buf, 20.0 * log10(fabs(v) / ref), '+', 3, 6, "dB");
		display_show(buf);
		return;
	}
	range_fmt(f, cur_range(), &scale, &unit, &intdig);
	char sign = fdef[f].ac ? '~' : (f == F_OHM2 || f == F_OHM4) ? ' ' : '+';
	format_num(buf, v * scale, sign, intdig, st.digits, unit);
	display_show(buf);
}

static void do_recall_show(void)
{
	char buf[16];
	if (st.stored == 0) { display_show("NO DATA"); return; }
	if (st.recall_idx < 0) st.recall_idx = 0;
	if (st.recall_idx >= st.stored) st.recall_idx = st.stored - 1;
	/* briefly show the index, then the value */
	buf[0] = 'R'; buf[1] = ' ';
	int i = st.recall_idx + 1;
	buf[2] = (char)('0' + (i / 100) % 10); buf[3] = (char)('0' + (i / 10) % 10); buf[4] = (char)('0' + i % 10);
	buf[5] = 0;
	show_msg(buf, 600);
	show_value(st.store_buf[st.recall_idx]);
}

static void key_unknown(key_id k)
{
	char buf[12] = "KEY  . ";
	int bus = KEY_RAW_BUS(k), ch = KEY_RAW_CH(k);
	buf[4] = (char)('0' + bus / 10); buf[5] = (char)('0' + bus % 10);
	buf[6] = '.'; buf[7] = (char)('0' + ch); buf[8] = 0;
	show_msg(buf, 1500);
}

static lkey_t map_key(key_id k)
{
	for (unsigned i = 0; i < sizeof(key_map) / sizeof(key_map[0]); i++)
		if (key_map[i].raw == (int)k && key_map[i].key != K_NONE)
			return key_map[i].key;
	return K_NONE;
}

static void select_func(func_t f)
{
	if (st.func != f) {
		st.func = f;
		st.ri = (f == F_DCA || f == F_ACA) ? 0 : 1;
		st.zero = 0;
		st.db = 0;
	}
	apply_config();
}

static void handle_key(lkey_t k)
{
	int sh = st.shift;
	st.shift = 0;
	if (st.recall && !(k == K_UP || k == K_DOWN || (sh && k == K_OHMS))) {
		st.recall = 0;
		set_leds();
	}
	switch (k) {
	case K_SHIFT:
		st.shift = !sh;
		if (st.shift) show_msg("SHIFT", 300);
		return;
	case K_VOLTS:
		if (sh) {                       /* STORE */
			st.storing = STORE_N; st.stored = 0;
			show_msg("STORE 100", 800);
		} else
			select_func((st.func == F_ACA || st.func == F_ACV) ? F_ACV : F_DCV);
		break;
	case K_OHMS:
		if (sh) {                       /* RECALL */
			st.recall = !st.recall;
			st.recall_idx = 0;
			set_leds();
			if (st.recall) do_recall_show();
		} else
			select_func(st.func == F_OHM4 ? F_OHM4 : F_OHM2);
		break;
	case K_AMPS:
		if (sh) {                       /* FILTER */
			st.filter = !st.filter;
			filter_reset();
			show_msg(st.filter ? "FILTER ON" : "FILTER OF", 800);
			set_leds();
		} else
			select_func((st.func == F_ACV || st.func == F_ACA) ? F_ACA : F_DCA);
		break;
	case K_AC:
		if (sh) {                       /* dB */
			if (fdef[st.func].ac) { st.db = !st.db; show_msg(st.db ? "DB ON" : "DB OFF", 600); }
			else show_msg("NO FUNC", 800);
		} else {
			if (st.func == F_DCV) select_func(F_ACV);
			else if (st.func == F_ACV) select_func(F_DCV);
			else if (st.func == F_DCA) select_func(F_ACA);
			else if (st.func == F_ACA) select_func(F_DCA);
			else show_msg("NO FUNC", 800);
		}
		break;
	case K_ZERO:
		if (sh) {                       /* RESOLN 6.5 -> 4.5 -> 5.5 */
			st.digits = (st.digits == 7) ? 5 : st.digits + 1;
			show_msg(st.digits == 5 ? "4.5 DIGIT" : st.digits == 6 ? "5.5 DIGIT" : "6.5 DIGIT", 800);
		} else {
			st.zero = !st.zero && st.last_valid;
			st.zero_val = st.last;
			set_leds();
		}
		break;
	case K_AUTO:
		if (sh) {                       /* DMM SETUP: LED test */
			display_setmode((disp_mode)ALL_MODE_LEDS);
			show_msg("*********", 1500);
			set_leds();
		} else {
			st.autorange = !st.autorange;
			set_leds();
		}
		break;
	case K_DOWN:
		if (st.recall) { st.recall_idx--; do_recall_show(); return; }
		st.autorange = 0;
		if (st.ri > 0) st.ri--;
		apply_config();
		break;
	case K_UP:
		if (st.recall) { st.recall_idx++; do_recall_show(); return; }
		st.autorange = 0;
		if (st.ri < fdef[st.func].nranges - 1) st.ri++;
		apply_config();
		break;
	case K_SCANNER:
		if (sh) {                       /* SCAN SETUP: 2/4 wire ohms */
			if (st.func == F_OHM2) { select_func(F_OHM4); show_msg("4 WIRE", 800); }
			else if (st.func == F_OHM4) { select_func(F_OHM2); show_msg("2 WIRE", 800); }
			else show_msg("NO FUNC", 800);
		} else {
			char b[10] = "CHAN    ";
			st.channel = (st.channel + 1) % 9;
			b[6] = (char)('0' + st.channel);
			show_msg(b, 800);
			filter_reset();
		}
		break;
	case K_TRIGGER:
		if (sh) {                       /* TRIG SETUP */
			st.one_shot = !st.one_shot;
			show_msg(st.one_shot ? "ONE SHOT" : "CONTINUO", 800);
		} else {
			st.trig_pending = 1;
			if (st.one_shot) {
				filter_reset();             /* new filtered reading per trigger */
				display_show(" -------");   /* waiting for the reading */
			}
		}
		break;
	case K_LOCAL:
	default:
		break;
	}
}

static void poll_keys(TickType_t wait)
{
	key_id k = display_get_key(wait);
	while (k != KEY_NONE) {
		lkey_t lk = map_key(k);
		if (lk == K_NONE)
			key_unknown(k);
		else
			handle_key(lk);
		k = display_get_key(0);
	}
}

static adc_channel scanner_channel(void)
{
	return st.channel == 0 ? ADC_CHANNEL_0 : (adc_channel)(1u << (st.channel - 1));
}

/* Optional scripted run for the camera loop (APP_DEMO in main.c). */
#if APP_DEMO
static const struct { int after; lkey_t key; int shift; } demo[] = {
#if APP_DEMO == 2
	{ 25, K_DOWN,    0 },   /* manual 300 mV with 1 V in -> OVERFLO */
	{ 15, K_UP,      0 },   /* 3 V            */
	{ 15, K_UP,      0 },   /* 30 V           */
	{ 15, K_AUTO,    0 },   /* auto -> 3 V    */
	{ 15, K_AMPS,    1 },   /* FILTER OFF     */
	{ 15, K_TRIGGER, 1 },   /* ONE SHOT       */
	{ 60, K_TRIGGER, 0 },   /* trigger once   */
	{ 60, K_AMPS,    1 },   /* FILTER ON      */
	{ 20, K_TRIGGER, 0 },   /* trigger, waits for the filter */
	{200, K_TRIGGER, 1 },   /* CONTINUO       */
	{ 15, K_SCANNER, 0 },   /* CHAN 1         */
	{ 15, K_SCANNER, 0 },   /* CHAN 2         */
	{  1, K_SCANNER, 0 }, { 1, K_SCANNER, 0 }, { 1, K_SCANNER, 0 }, { 1, K_SCANNER, 0 },
	{  1, K_SCANNER, 0 }, { 1, K_SCANNER, 0 }, { 1, K_SCANNER, 0 },   /* back to CHAN 0 */
	{ 20, K_AUTO,    1 },   /* DMM SETUP: LED test */
	{200, K_OHMS,    0 },   /* OHMS 2W, Riden output off by then */
	{ 40, K_UP,      0 },   /* manual range up */
#else
	{ 25, K_ZERO,  0 },   /* DCV: zero on      */
	{ 15, K_ZERO,  0 },   /* zero off          */
	{ 10, K_ZERO,  1 },   /* RESOLN -> 4.5     */
	{ 10, K_ZERO,  1 },   /* RESOLN -> 5.5     */
	{ 10, K_ZERO,  1 },   /* RESOLN -> 6.5     */
	{ 10, K_AC,    0 },   /* ACV               */
	{ 25, K_AC,    1 },   /* dB on             */
	{ 10, K_AC,    1 },   /* dB off            */
	{  5, K_OHMS,  0 },   /* OHMS 2W           */
	{ 25, K_SCANNER, 1 }, /* OHMS 4W           */
	{ 20, K_AMPS,  0 },   /* DCA (from OHMS)   */
	{ 10, K_AC,    0 },   /* ACA               */
	{ 15, K_VOLTS, 1 },   /* STORE 100         */
	{  2, K_VOLTS, 0 },   /* DCV               */
	{120, K_OHMS,  1 },   /* RECALL            */
	{  2, K_UP,    0 },
	{  2, K_OHMS,  1 },   /* RECALL off        */
#endif
};
static int demo_i, demo_cnt;
#endif

static void app_run(void)
{
	char buf[32];
	(void)buf;
	display_show("ADC INIT");
	if (adc_init(ADC_INTEGRATION_50HZ, fdef[st.func].input, cur_range()) != ADC_ERROR_NONE) {
		display_show("ADC ERR");
		for (;;) vTaskDelay(1000);
	}
	apply_config();

	for (;;) {
		poll_keys(0);
#if APP_DEMO
		if (demo_i < (int)(sizeof(demo) / sizeof(demo[0])) && ++demo_cnt >= demo[demo_i].after) {
			demo_cnt = 0;
			st.shift = demo[demo_i].shift;
			handle_key(demo[demo_i].key);
			demo_i++;
		}
#endif
		if (st.recall) {
			poll_keys(50 / portTICK_PERIOD_MS);
			continue;
		}
		if (st.one_shot && !st.trig_pending) {
			if (st.redraw) {            /* hold the last reading */
				st.redraw = 0;
				if (st.last_valid) show_value(st.zero ? st.last - st.zero_val : st.last);
				else display_show(" -------");
			}
			poll_keys(50 / portTICK_PERIOD_MS);
			continue;
		}

		int flag = 0;
		double v = adc_read_value(scanner_channel(), &flag);
		if (st.func == F_DCV)
			v = cal_dcv_apply(cur_range(), v);

		if (st.autorange) {
			int ri = st.ri, n = fdef[st.func].nranges;
			if (flag && ri < n - 1)
				ri++;
			else if (!flag && ri > 0 &&
			         fabs(v) < AUTORANGE_DOWN * adc_get_max(fdef[st.func].ranges[ri - 1]))
				ri--;
			if (ri != st.ri) {
				st.ri = ri;
				apply_config();
				(void)adc_read_value(scanner_channel(), &flag);   /* settle */
				continue;
			}
		}

		if (flag) {
			filter_reset();
			st.last_valid = 0;
			display_clearmode(DISP_FLTR);
			display_show(flag == ADC_UNDERFLOW ? "-OVERFLO" : " OVERFLO");
			continue;
		}

		if (st.filter) {
			int settled;
			v = filter_apply(v, adc_get_max(cur_range()), &settled);
			st.blink = !st.blink;
			if (settled || st.blink) display_setmode(DISP_FLTR);
			else display_clearmode(DISP_FLTR);
			if (st.one_shot && !settled)
				continue;               /* one-shot: wait until the filter is full */
		}
		st.trig_pending = 0;

		st.last = v;
		st.last_valid = 1;
		if (st.zero)
			v -= st.zero_val;

		if (st.storing) {
			st.store_buf[st.stored++] = v;
			st.storing--;
			st.blink ? display_setmode(DISP_STO) : display_clearmode(DISP_STO);
			if (!st.storing) set_leds();
		}
		if (st.shift)
			display_show("SHIFT");
		else
			show_value(v);
	}
}
