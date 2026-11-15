/*
 * hal_spi.c  –  Display digit-select: GPIO bit-bang on RG6 (CLK) / RC1 (DATA)
 *
 * Original Keithley 199 LA: 11 × 16-bit words FFDF … F7FE per frame.
 * On-chip SPI2 master was tried but produced wrong bit patterns on the bus
 * (mode/CKE vs shift-register input); bit-bang matches the captured originals.
 *
 * PIC32MX350F256L: RC1 = SDO2-capable RP; RPC1R cleared so GPIO drives DATA.
 * RG6 = SCK2 pad; RPG6R = 0 (native SCK2 not used — GPIO toggles CLK).
 */

#include <HardwareProfile.h>
#include <hal_io.h>
#include <hal_sys.h>
#include <hal_spi.h>

#define SPI_BIT_DELAY_LOOPS 24u

static const uint16_t digit_select[11] = {
	0xFFDF, 0xFBFF, 0x7FEF, 0xFDFF, 0xBFF7, 0xFEFF,
	0xDFFB, 0xFF7F, 0xEFFD, 0xFFBF, 0xF7FE,
};

static const uint8_t digit_bus_line[11] = {
	8, 6, 4, 2, 0, 9, 7, 5, 3, 1, 10
};

static void __attribute__((nomips16)) spi_bit_delay(volatile unsigned int loops)
{
	while (loops--) {
		__asm__ volatile("nop" ::: "memory");
	}
}

void __attribute__((nomips16)) hal_spi_init_16bit(void)
{
	PMD5CLR = _PMD5_SPI2MD_MASK;
	SPI2CONbits.ON = 0;

	ANSELGCLR = _ANSELG_ANSG6_MASK;
	ODCGCLR = _ODCG_ODCG6_MASK;
	hal_gpio_pins_digital_out(IOPORT_G, BIT_6);

	ANSELCCLR = (1u << 1);
	ODCCCLR = _ODCC_ODCC1_MASK;
	hal_gpio_pins_digital_out(IOPORT_C, BIT_1);

	{
		unsigned int ist = hal_irq_disable();
		SYSKEY = 0;
		SYSKEY = 0xAA996655;
		SYSKEY = 0x556699AA;
		CFGCONbits.IOLOCK = 0;
		RPG6Rbits.RPG6R = 0;
		RPC1Rbits.RPC1R = 0;
		/* Do NOT set IOLOCK here: with fuse IOL1WAY = ON the lock can never be
		 * released again, and hal_adc_init() still has to map SDO1 -> RF8,
		 * OC3 -> RG1 and T4CK <- RE3 afterwards (2026-11-15). */
		SYSKEY = 0x33333333;
		hal_irq_restore(ist);
	}

	LATGCLR = BIT_6;
	LATCSET = BIT_1;

	PMD5SET = _PMD5_SPI2MD_MASK;

	hal_spi_write_16bit(0xFFFF);
}

/*
 * MSB first, SPI mode 0 style: DATA stable, then CLK high, then CLK low.
 * IRQs off for the whole 16 bits so the LA never sees a "split" word.
 */
void __attribute__((nomips16)) hal_spi_write_16bit(uint16_t value)
{
	unsigned int ist = hal_irq_disable();
	int bit;

	for (bit = 15; bit >= 0; bit--) {
		if (value & (1u << bit))
			LATCSET = BIT_1;
		else
			LATCCLR = BIT_1;
		spi_bit_delay(8u);

		LATGSET = BIT_6;
		spi_bit_delay(SPI_BIT_DELAY_LOOPS);
		LATGCLR = BIT_6;
		spi_bit_delay(8u);
	}
	hal_irq_restore(ist);
}

uint8_t __attribute__((nomips16)) hal_digit_bus_line(int char_slot)
{
	if (char_slot < 0 || char_slot > 10)
		return 0;
	return digit_bus_line[char_slot];
}

void __attribute__((nomips16)) hal_display_select_digit(int bus_index)
{
	if (bus_index < 0 || bus_index > 10)
		return;
	hal_spi_write_16bit(digit_select[bus_index]);
}
