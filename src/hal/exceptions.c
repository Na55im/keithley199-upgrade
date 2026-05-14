/**
 * @file exceptions.c
 * @brief Exception handling routines
 * This file reimplements the PIC32 _general_exception_handler.
 * The default _general_exception_handler provided by
 * microchip libraries is just a while loop. This handler turns on the
 * SYSERR LED with raw SFR writes (no PLIB), saves Cause/Status for the
 * debugger, then stops.
 * @author Diego F. Asanza
 */

#include <xc.h>
#include <stdint.h>

/*
 * Do not call PLIB (PORTSetBits/PORTClearBits) from here: those may be mips16
 * linked and/or assume hal_io_init() ran. Minimal firmware never calls
 * hal_io_init(); RC4 must be configured here before touching LATC.
 */
enum {
	EXCEP_IRQ = 0,
	EXCEP_AdEL = 4,
	EXCEP_AdES,
	EXCEP_IBE,
	EXCEP_DBE,
	EXCEP_Sys,
	EXCEP_Bp,
	EXCEP_RI,
	EXCEP_CpU,
	EXCEP_Overflow,
	EXCEP_Trap,
	EXCEP_IS1 = 16,
	EXCEP_CEU,
	EXCEP_C2E
};

volatile unsigned _excep_code;
volatile uint32_t g_last_excep_cause;
volatile uint32_t g_last_excep_status;
/** COP0: PC der faulting instruction (meist synchron zu ExcCode). */
volatile uint32_t g_last_excep_epc;
/** COP0: bei AdEL/AdES/IBE/DBE die problematische Adresse. */
volatile uint32_t g_last_excep_badvaddr;

static uint32_t cop0_read_epc(void)
{
	uint32_t v;
	__asm__ volatile("mfc0 %0, $14" : "=r"(v));
	return v;
}

static uint32_t cop0_read_badvaddr(void)
{
	uint32_t v;
	__asm__ volatile("mfc0 %0, $8" : "=r"(v));
	return v;
}

/** SYSERR LED = BRD_RED_LED = RC4, active low (same as hal_io). */
static void __attribute__((nomips16)) exception_show_syserr_led(void)
{
	/* Pin digital + push-pull (wie PORTSetPinsDigitalOut auf IOPORT_C BIT_4). */
	ANSELCCLR = _PORTC_RC4_MASK;
	ODCCCLR = _ODCC_ODCC4_MASK;
	TRISCCLR = _TRISC_TRISC4_MASK;
	LATCCLR = _LATC_LATC4_MASK;
}

/**
 * general exception handler for mips architecture
 * @param ulCause cause of the exception.
 * @param ulStatus status register
 */
void __attribute__((nomips16, optimize("O0")))
_general_exception_handler(unsigned long ulCause, unsigned long ulStatus)
{
	/*
	 * ulCause/ulStatus kommen vom Bootstrap-Kontext; EPC/BadVAddr noch aus COP0
	 * lesen (zeigt die echte Absturzadresse — oft wichtiger als diese Zeilen).
	 */
	g_last_excep_epc = cop0_read_epc();
	g_last_excep_badvaddr = cop0_read_badvaddr();
	g_last_excep_cause = ulCause;
	g_last_excep_status = ulStatus;
	_excep_code = (unsigned)((ulCause & 0x0000007CUL) >> 2);

	exception_show_syserr_led();

	for (;;) {
	}
}
