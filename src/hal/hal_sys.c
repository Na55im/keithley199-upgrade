#include <xc.h>
#include <hal_sys.h>
#include "HardwareProfile.h"
#include <diag.h>

/*
 * All functions in this file are nomips16: they use CP0 instructions
 * (di, ei, mfc0, mtc0) which only exist in the MIPS32 ISA.
 *
 * NO calls to PLIB library functions (INTDisableInterrupts,
 * INTConfigureSystem, INTSetVectorPriority, PowerSaveIdle, etc.)
 * — those symbols live in libmchp_peripheral_32MX350F256L.a which
 * was not being linked into the final ELF (all at address 0x00000000).
 */

static inline unsigned int __attribute__((nomips16, always_inline))
disable_interrupts(void)
{
    unsigned int st;
    __asm__ volatile("di %0" : "=r"(st));
    return st;
}

static inline void __attribute__((nomips16, always_inline))
restore_interrupts(unsigned int st)
{
    if (st & 1)
        __asm__ volatile("ei");
    else
        __asm__ volatile("di");
}

static void __attribute__((nomips16)) sys_config_performance(void)
{
    unsigned int st = disable_interrupts();

    /* Flash wait states: 80 MHz / 30 MHz → 2 WS.  Prefetch all. */
    CHECON = (CHECON & ~(_CHECON_PFMWS_MASK | _CHECON_PREFEN_MASK))
           | (2u << _CHECON_PFMWS_POSITION)
           | (3u << _CHECON_PREFEN_POSITION);

    BMXCONCLR = _BMXCON_BMXWSDRM_MASK;

    /* KSEG0 cacheable (Config.K0 = 3). */
    {
        unsigned long cfg;
        __asm__ volatile("mfc0 %0, $16" : "=r"(cfg));
        cfg = (cfg & ~7UL) | 3UL;
        __asm__ volatile("mtc0 %0, $16" : : "r"(cfg));
    }

    restore_interrupts(st);
}

unsigned int __attribute__((nomips16)) hal_irq_disable(void)
{
    return disable_interrupts();
}

void __attribute__((nomips16)) hal_irq_restore(unsigned int st)
{
    restore_interrupts(st);
}

void __attribute__((nomips16)) hal_sys_init(void)
{
    sys_config_performance();

    /* UART3 priority 3 (IPC9: U3IP bits [20:18]). */
    IPC9CLR = _IPC9_U3IP_MASK;
    IPC9SET = (3u << _IPC9_U3IP_POSITION);

    /* UART5 priority 3 (IPC10: U5IP bits [4:2]). */
    IPC10CLR = _IPC10_U5IP_MASK;
    IPC10SET = (3u << _IPC10_U5IP_POSITION);

    /* Multi-vector interrupt mode. */
    INTCONSET = _INTCON_MVEC_MASK;

    /* Disable all interrupts (clear Status.IE via di). */
    __asm__ volatile("di");
}

void __attribute__((nomips16)) hal_sys_idle(void)
{
    __asm__ volatile("wait");
}

void __attribute__((nomips16)) _DefaultInterrupt(void)
{
    DIAG("WARN: Default Interrupt\n");
}
