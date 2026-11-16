/*
 * DC-amps calibration constants, stored in PIC flash as part of the firmware
 * (same reasoning as cal_dcv.h: the existing EEPROM calibration data must
 * never be overwritten).
 *
 * Model per range (fit of the uncalibrated reading y against reference x):
 *     y = gain * x + offset   ->   x = (y - offset) / gain
 * Reference: Keithley 2700 in series with the 199, RD6018P in CC mode,
 * read by camera (tools/cal_amps.py).
 */
#ifndef CAL_DCA_H
#define CAL_DCA_H

#include <adcdefs.h>

typedef struct {
    adc_range range;
    double gain;
    double offset;      /* amps */
} cal_dca_t;

static const cal_dca_t cal_dca_table[] = {
    /* range           gain        offset */
    { ADC_RANGE_30m,   0.9852014,  -17.28e-6 }, /* 2026-11-16 vs Keithley 2700, 0..29 mA (Riden CV), resid <= 2.5 uA */
    { ADC_RANGE_3,     0.9753406,  -1002.95e-6 }, /* 2026-11-16 vs Keithley 2700, 0..2.8 A, resid <= 0.41 mA (2700 3 A range: 10 uA resolution) */
};

static inline double cal_dca_apply(adc_range r, double y)
{
    for (unsigned i = 0; i < sizeof(cal_dca_table) / sizeof(cal_dca_table[0]); i++)
        if (cal_dca_table[i].range == r)
            return (y - cal_dca_table[i].offset) / cal_dca_table[i].gain;
    return y;
}

#endif
