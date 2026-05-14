/*
 * hal_spi.h  –  Display digit-select via 16-bit shift register
 */
#ifndef HAL_SPI_H
#define	HAL_SPI_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdint.h>

    void hal_spi_init_16bit(void);
    void hal_spi_write_16bit(uint16_t value);
    /** Shift-register bus index 0..10 (see hal_digit_bus_line). */
    void hal_display_select_digit(int bus_index);
    /**
     * Map character slot 0=left .. 9=right (AZ0..AZ9) to shift-register bus.
     * HW order can differ from left-to-right order on the glass.
     */
    uint8_t hal_digit_bus_line(int char_slot) __attribute__((nomips16));

#ifdef	__cplusplus
}
#endif

#endif	/* HAL_SPI_H */
