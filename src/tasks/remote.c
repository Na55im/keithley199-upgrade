/*
 * remote.c - serial remote control of the DMM application (UART3, P8/P9,
 * 115200 8N1). Included from app_dmm.c (no separate translation unit, the
 * MPLAB makefiles stay untouched).
 *
 * Line protocol, see insturctions/remote-protocol.md. Commands end with LF
 * (CR is ignored), are case-insensitive, one command per line.
 * Device -> host lines start with a tag:
 *   R,<ms>,<value>,<raw>,<func>,<range>,<flags>,<chan>   reading (STREAM 1 or READ?)
 *   S,...                                         state (after every change)
 *   OK / ERR,<text>                               command result
 *   other                                         query answer
 *
 * Nothing here touches the EEPROM. The RX ISR callback only fills a ring
 * buffer; all parsing happens in the measuring task (remote_poll()).
 */
#include <hal_uart.h>

#define REMOTE_UART     HAL_UART_PORT_3
#define REMOTE_RX_SIZE  256             /* power of two */
#define REMOTE_LINE     64

static volatile unsigned char rem_rx[REMOTE_RX_SIZE];
static volatile unsigned int rem_head, rem_tail;
static char rem_line[REMOTE_LINE];
static int rem_len, rem_overflow;
static int rem_stream;          /* push every reading */
static int rem_active;          /* a command was received: REM LED on */
static unsigned int rem_state_sum = 0xFFFFFFFFu;

static const char *const func_names[F_COUNT] = { "DCV", "ACV", "DCA", "ACA", "OHM2", "OHM4" };

/* reading flags */
#define RF_AUTO     1
#define RF_ZERO     2
#define RF_FILTER   4
#define RF_SETTLED  8
#define RF_OVERFLOW 16
#define RF_DB       32
#define RF_HOLD     64

static void rem_rx_cb(hal_uart_port port, uint8_t data, hal_uart_error error)
{
	(void)port;
	if (error != HAL_UART_ERR_NONE)
		return;
	unsigned int next = (rem_head + 1) & (REMOTE_RX_SIZE - 1);
	if (next != rem_tail) {
		rem_rx[rem_head] = data;
		rem_head = next;
	}
}

/* FRC trim (OSCTUN, 6-bit two's complement). Crystal X1 cannot oscillate on
 * this board (symbol/footprint pin mismatch, see develope-log 2026-11-17), so
 * the CPU runs on FRC+PLL; FRC_TUNE pulls it to 8 MHz. Measured against the
 * host clock with tools/clockcheck.py. */
#ifndef FRC_TUNE
#define FRC_TUNE 0
#endif
static int frc_tune = FRC_TUNE;

static void __attribute__((nomips16)) frc_set_tune(int v)
{
	unsigned int ist = hal_irq_disable();
	SYSKEY = 0;
	SYSKEY = 0xAA996655;
	SYSKEY = 0x556699AA;
	OSCTUN = (unsigned int)v & 0x3Fu;
	SYSKEY = 0x33333333;
	hal_irq_restore(ist);
	frc_tune = v;
}

/* UART3 is set up with the SFRs directly: the legacy plib UART/INT functions
 * are not linked into this build (address 0), calling them crashes. */
static void remote_init(void)
{
	frc_set_tune(FRC_TUNE);
	ANSELBCLR = (1u << 3) | (1u << 5);      /* RB3 = U3RX, RB5 = U3TX: digital */
	TRISBSET = (1u << 3);
	CNPUBSET = (1u << 3);                   /* pull-up: an open RX line stays idle */
	U3RXR = 8;                              /* U3RX <- RPB3 (IOLOCK is never set) */
	RPB5R = 1;                              /* RPB5 -> U3TX */
	hal_uart_register_data_received(REMOTE_UART, rem_rx_cb);
	U3MODE = 0;
	U3BRG = 173;                            /* 80 MHz / (4 * 174) = 114943 baud */
	U3STA = _U3STA_URXEN_MASK | _U3STA_UTXEN_MASK;
	U3MODE = _U3MODE_ON_MASK | _U3MODE_BRGH_MASK;
	IFS1CLR = _IFS1_U3RXIF_MASK | _IFS1_U3EIF_MASK;
	IEC1SET = _IEC1_U3RXIE_MASK;            /* priority 3: hal_sys_init() */
	for (const char *b = "K199 READY\n"; *b; b++) {    /* boot banner */
		while (U3STAbits.UTXBF)
			;
		U3TXREG = (unsigned char)*b;
	}
}

/* ---- output ------------------------------------------------------------- */
static void rem_putc(char c)
{
	while (U3STAbits.UTXBF)
		;
	U3TXREG = (unsigned char)c;
}
static void rem_puts(const char *s) { while (*s) rem_putc(*s++); }

static void rem_putu(unsigned long long u)
{
	char d[24]; int n = 0;
	do { d[n++] = (char)('0' + u % 10); u /= 10; } while (u);
	while (n) rem_putc(d[--n]);
}

static void rem_puti(long long i)
{
	if (i < 0) { rem_putc('-'); i = -i; }
	rem_putu((unsigned long long)i);
}

/* double as d.dddddddddE+ee (10 significant digits) */
static void rem_putd(double v)
{
	if (v != v) { rem_puts("NAN"); return; }
	if (v < 0) { rem_putc('-'); v = -v; }
	if (v < 1e-30) { rem_puts("0.000000000E+00"); return; }
	if (v > 1e30) { rem_puts("9.900000000E+37"); return; }
	int e = (int)floor(log10(v));
	unsigned long long m = (unsigned long long)llround(v * pow(10.0, 9 - e));
	if (m >= 10000000000ULL) { m /= 10; e++; }
	if (m < 1000000000ULL) { m *= 10; e--; }
	char d[12];
	for (int i = 9; i >= 0; i--) { d[i] = (char)('0' + m % 10); m /= 10; }
	rem_putc(d[0]); rem_putc('.');
	for (int i = 1; i < 10; i++) rem_putc(d[i]);
	rem_putc('E');
	if (e < 0) { rem_putc('-'); e = -e; } else rem_putc('+');
	rem_putc((char)('0' + e / 10)); rem_putc((char)('0' + e % 10));
}

static void rem_ok(void) { rem_puts("OK\n"); }
static void rem_err(const char *t) { rem_puts("ERR,"); rem_puts(t); rem_putc('\n'); }

static int rem_flags(void)
{
	return (st.autorange ? RF_AUTO : 0) | (st.zero ? RF_ZERO : 0) | (st.filter ? RF_FILTER : 0) |
	       ((st.db && fdef[st.func].ac) ? RF_DB : 0) | (st.hold ? RF_HOLD : 0);
}

/* S,<func>,<range idx>,<full scale>,<auto>,<filter>,<digits>,<zero>,<zero val>,<db>,<trig>,<chan>,<stream>,
 *   <FAST|LINE>,<50|60>,<integration us>,<lock>,<hold>,<scan mask> */
static void rem_send_state(void)
{
	rem_puts("S,"); rem_puts(func_names[st.func]);
	rem_putc(','); rem_puti(st.ri);
	rem_putc(','); rem_putd(adc_get_max(cur_range()));
	rem_putc(','); rem_puti(st.autorange);
	rem_putc(','); rem_puti(st.filter);
	rem_putc(','); rem_puti(st.digits - 1);        /* 4, 5, 6 = 4.5, 5.5, 6.5 digits */
	rem_putc(','); rem_puti(st.zero);
	rem_putc(','); rem_putd(st.zero ? st.zero_val : 0.0);
	rem_putc(','); rem_puti(st.db);
	rem_putc(','); rem_puts(st.one_shot ? "ONE" : "CONT");
	rem_putc(','); rem_puti(st.channel);
	rem_putc(','); rem_puti(rem_stream);
	rem_putc(','); rem_puts(st.fast ? "FAST" : "LINE");
	rem_putc(','); rem_puti(st.line60 ? 60 : 50);
	rem_putc(','); rem_puti(integration_us());
	rem_putc(','); rem_puti(st.lock);
	rem_putc(','); rem_puti(st.hold);
	rem_putc(','); rem_puti(st.scan_mask);
	rem_putc('\n');
}

/* Send the state whenever it changed (front panel keys, autorange, commands). */
static void remote_state_check(void)
{
	unsigned int sum = (unsigned)st.func | (unsigned)st.ri << 3 | (unsigned)st.autorange << 7 |
	                   (unsigned)st.filter << 8 | (unsigned)st.digits << 9 | (unsigned)st.zero << 13 |
	                   (unsigned)st.db << 14 | (unsigned)st.one_shot << 15 |
	                   (unsigned)(st.scan_mask ? 0 : st.channel) << 16 |   /* scan: channel is in every R line */
	                   (unsigned)rem_stream << 20 | (unsigned)st.fast << 21 | (unsigned)st.line60 << 22 |
	                   (unsigned)st.lock << 23 | (unsigned)st.hold << 24 | st.scan_mask << 25;
	if (st.zero)
		sum ^= (unsigned int)(long long)(st.zero_val * 1e7) * 2654435761u;
	if (sum != rem_state_sum) {
		rem_state_sum = sum;
		if (rem_active)
			rem_send_state();
	}
}

/* R,<ms since power on>,<value>,<raw>,<func>,<range idx>,<flags>,<scanner channel>
 * value = as displayed (filter, zero; volts/amps/ohms, not dB), raw = this
 * conversion before filter and zero. Overflow: value and raw are 9.9E+37. */
static void rem_send_reading(double value, double raw, int extra)
{
	/* portTICK_PERIOD_MS is 1 at 600 Hz (integer division): convert explicitly */
	rem_puts("R,"); rem_putu((unsigned long long)xTaskGetTickCount() * 1000u / configTICK_RATE_HZ);
	rem_putc(','); rem_putd(value);
	rem_putc(','); rem_putd(raw);
	rem_putc(','); rem_puts(func_names[st.func]);
	rem_putc(','); rem_puti(st.ri);
	rem_putc(','); rem_puti(rem_flags() | extra);
	rem_putc(','); rem_puti(st.channel);
	rem_putc('\n');
}

#define REMOTE_DEBUG 0            /* 1: D,... line with the UART3 state before every reading */
#if REMOTE_DEBUG
static void rem_puth(unsigned int v)
{
	for (int i = 28; i >= 0; i -= 4) rem_putc("0123456789ABCDEF"[(v >> i) & 15]);
}
static void rem_debug(void)
{
	rem_puts("D,PORTB="); rem_puth(PORTB);
	rem_puts(",TRISB="); rem_puth(TRISB);
	rem_puts(",ANSELB="); rem_puth(ANSELB);
	rem_puts(",U3STA="); rem_puth(U3STA);
	rem_puts(",U3MODE="); rem_puth(U3MODE);
	rem_puts(",U3RXR="); rem_puth(U3RXR);
	rem_puts(",IEC1="); rem_puth(IEC1);
	rem_puts(",IFS1="); rem_puth(IFS1);
	rem_puts(",IPC9="); rem_puth(IPC9);
	rem_puts(",CFGCON="); rem_puth(CFGCON);
	rem_puts(",head="); rem_putu(rem_head);
	rem_putc('\n');
}
#endif

/* called by the application for every finished conversion */
static void remote_reading(double value, double raw, int settled, int overflow)
{
#if REMOTE_DEBUG
	rem_debug();
#endif
	remote_state_check();
	if (!rem_stream)
		return;
	if (st.scan_mask && st.filter && !settled && !overflow)
		return;                 /* scan: only the finished reading of each channel */
	if (overflow)
		rem_send_reading(overflow < 0 ? -9.9e37 : 9.9e37, overflow < 0 ? -9.9e37 : 9.9e37, RF_OVERFLOW);
	else
		rem_send_reading(value, raw, settled ? RF_SETTLED : 0);
}

/* ---- command parser ----------------------------------------------------- */
static int rem_eq(const char *a, const char *b)
{
	while (*a && *b) {
		char x = *a++, y = *b++;
		if (x >= 'a' && x <= 'z') x = (char)(x - 32);
		if (x != y) return 0;
	}
	return *a == 0 && *b == 0;
}

static int rem_onoff(const char *a, int *v)
{
	if (rem_eq(a, "1") || rem_eq(a, "ON"))  { *v = 1; return 1; }
	if (rem_eq(a, "0") || rem_eq(a, "OFF")) { *v = 0; return 1; }
	return 0;
}

/* "1-4", "1,3,5", "2" -> channel bit mask (bits 1..8); 0 on error */
static unsigned int rem_chanlist(const char *a)
{
	unsigned int m = 0;
	while (*a) {
		if (*a < '1' || *a > '8') return 0;
		int lo = *a++ - '0', hi = lo;
		if (*a == '-') {
			a++;
			if (*a < '1' || *a > '8') return 0;
			hi = *a++ - '0';
		}
		if (hi < lo) return 0;
		for (int c = lo; c <= hi; c++) m |= 1u << c;
		if (*a == ',') a++;
		else if (*a) return 0;
	}
	return m;
}

static const struct { const char *name; lkey_t key; } rem_keys[] = {
	{ "VOLTS", K_VOLTS }, { "OHMS", K_OHMS }, { "AMPS", K_AMPS }, { "AC", K_AC },
	{ "ZERO", K_ZERO }, { "AUTO", K_AUTO }, { "DOWN", K_DOWN }, { "UP", K_UP },
	{ "SCANNER", K_SCANNER }, { "TRIGGER", K_TRIGGER }, { "NEXT", K_SHIFT }, { "LOCAL", K_LOCAL },
};

static void rem_exec(char *line)
{
	char *cmd = line, *arg;
	while (*cmd == ' ') cmd++;
	if (!*cmd) return;
	arg = cmd;
	while (*arg && *arg != ' ') arg++;
	if (*arg) { *arg++ = 0; while (*arg == ' ') arg++; }
	int v;

	if (!rem_active) { rem_active = 1; display_setmode(DISP_REM); }

	if (rem_eq(cmd, "*IDN?")) {
		rem_puts("KEITHLEY,199-UPGRADE,0," __DATE__ " " __TIME__ "\n");
	} else if (rem_eq(cmd, "*RST")) {
		st.recall = 0; st.storing = 0; st.shift = 0;
		st.autorange = 1; st.filter = 1; st.digits = 7; st.one_shot = 0; st.channel = 0;
		st.hold = 0; st.scan_mask = 0; st.scan_discard = 0;
		if (st.fast) { st.fast = 0; apply_integration(); }
		st.func = F_ACV;                /* force select_func to reset range, zero, dB */
		select_func(F_DCV);
		rem_ok();
	} else if (rem_eq(cmd, "STAT?")) {
		rem_send_state();
	} else if (rem_eq(cmd, "READ?")) {
		if (st.last_valid) rem_send_reading(st.zero ? st.last - st.zero_val : st.last, st.last, 0);
		else rem_err("NO READING");
	} else if (rem_eq(cmd, "STREAM")) {
		if (rem_onoff(arg, &v)) { rem_stream = v; rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "FUNC")) {
		for (v = 0; v < F_COUNT; v++)
			if (rem_eq(arg, func_names[v])) break;
		if (v < F_COUNT) { st.recall = 0; select_func((func_t)v); rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "RANG")) {
		int n = fdef[st.func].nranges;
		if (rem_eq(arg, "AUTO")) { st.autorange = 1; set_leds(); rem_ok(); }
		else if (rem_eq(arg, "UP"))   { st.autorange = 0; if (st.ri < n - 1) st.ri++; apply_config(); rem_ok(); }
		else if (rem_eq(arg, "DOWN")) { st.autorange = 0; if (st.ri > 0) st.ri--; apply_config(); rem_ok(); }
		else if (arg[0] >= '0' && arg[0] < '0' + n && !arg[1]) {
			st.autorange = 0; st.ri = arg[0] - '0'; apply_config(); rem_ok();
		} else rem_err("ARG");
	} else if (rem_eq(cmd, "RANG?")) {
		/* list of the full scale values of the active function */
		for (int i = 0; i < fdef[st.func].nranges; i++) {
			if (i) rem_putc(',');
			rem_putd(adc_get_max(fdef[st.func].ranges[i]));
		}
		rem_putc('\n');
	} else if (rem_eq(cmd, "FILT")) {
		if (rem_onoff(arg, &v)) { st.filter = v; filter_reset(); set_leds(); rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "DIG")) {
		if (arg[0] >= '4' && arg[0] <= '6' && !arg[1]) { st.digits = arg[0] - '0' + 1; rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "ZERO")) {
		if (!rem_onoff(arg, &v)) rem_err("ARG");
		else if (v && !st.last_valid) rem_err("NO READING");
		else { st.zero = v; st.zero_val = st.last; set_leds(); rem_ok(); }
	} else if (rem_eq(cmd, "DB")) {
		if (rem_onoff(arg, &v)) { st.db = v; rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "TRIG")) {
		if (rem_eq(arg, "CONT")) { st.one_shot = 0; rem_ok(); }
		else if (rem_eq(arg, "ONE")) { st.one_shot = 1; st.trig_pending = 0; rem_ok(); }
		else rem_err("ARG");
	} else if (rem_eq(cmd, "*TRG")) {
		st.trig_pending = 1;
		if (st.one_shot) filter_reset();
		rem_ok();
	} else if (rem_eq(cmd, "CHAN")) {
		if (arg[0] >= '0' && arg[0] <= '8' && !arg[1]) {
			st.scan_mask = 0; st.channel = arg[0] - '0'; filter_reset(); st.scan_discard = 1; rem_ok();
		} else rem_err("ARG");
	} else if (rem_eq(cmd, "SCAN")) {
		unsigned int m = rem_eq(arg, "0") || rem_eq(arg, "OFF") ? 0 : rem_chanlist(arg);
		if (!m && !(rem_eq(arg, "0") || rem_eq(arg, "OFF"))) rem_err("ARG");
		else {
			st.scan_mask = m;
			st.channel = 0;
			if (m) st.channel = scan_next();
			filter_reset(); st.scan_discard = 1;
			rem_ok();
		}
	} else if (rem_eq(cmd, "SPEED")) {
		if (rem_eq(arg, "FAST")) { st.fast = 1; apply_integration(); rem_ok(); }
		else if (rem_eq(arg, "LINE")) { st.fast = 0; apply_integration(); rem_ok(); }
		else rem_err("ARG");
	} else if (rem_eq(cmd, "LINE")) {
		if (rem_eq(arg, "50")) { st.line60 = 0; apply_integration(); rem_ok(); }
		else if (rem_eq(arg, "60")) { st.line60 = 1; apply_integration(); rem_ok(); }
		else rem_err("ARG");
	} else if (rem_eq(cmd, "OSCTUN?")) {
		rem_puti(frc_tune); rem_putc(','); rem_puti((OSCCON >> 12) & 7); rem_putc('\n');   /* trim, COSC */
	} else if (rem_eq(cmd, "OSCTUN")) {
		/* temporary FRC trim -32..31 for measuring; not stored */
		char *e = arg; int neg = (*e == '-'); if (neg) e++;
		int n = 0, ok = (*e >= '0' && *e <= '9');
		while (*e >= '0' && *e <= '9') n = n * 10 + (*e++ - '0');
		if (neg) n = -n;
		if (ok && !*e && n >= -32 && n <= 31) { frc_set_tune(n); rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "LOCK")) {
		if (rem_onoff(arg, &v)) { st.lock = v; rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "HOLD")) {
		if (rem_onoff(arg, &v)) { st.hold = v; rem_ok(); } else rem_err("ARG");
	} else if (rem_eq(cmd, "KEY")) {
		unsigned i;
		for (i = 0; i < sizeof(rem_keys) / sizeof(rem_keys[0]); i++)
			if (rem_eq(arg, rem_keys[i].name)) break;
		if (i < sizeof(rem_keys) / sizeof(rem_keys[0])) { rem_ok(); handle_key(rem_keys[i].key); }
		else rem_err("ARG");
	} else if (rem_eq(cmd, "LOCAL")) {
		rem_stream = 0; rem_active = 0; st.lock = 0; st.hold = 0; display_clearmode(DISP_REM);
		rem_ok();
		rem_state_sum = 0xFFFFFFFFu;
		return;
	} else {
		rem_err("CMD");
	}
	remote_state_check();
}

/* Called from the measuring task between conversions. */
static void remote_poll(void)
{
	if (U3STAbits.OERR)                     /* overrun stops the receiver until cleared */
		U3STACLR = _U3STA_OERR_MASK;
	while (rem_tail != rem_head) {
		char c = (char)rem_rx[rem_tail];
		rem_tail = (rem_tail + 1) & (REMOTE_RX_SIZE - 1);
		if (c == '\r')
			continue;
		if (c == '\n') {
			rem_line[rem_len] = 0;
			if (rem_overflow) rem_err("LINE");
			else rem_exec(rem_line);
			rem_len = 0; rem_overflow = 0;
		} else if (rem_len < REMOTE_LINE - 1) {
			rem_line[rem_len++] = c;
		} else {
			rem_overflow = 1;
		}
	}
	remote_state_check();
}
