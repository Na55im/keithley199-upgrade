/*
 * DC-volts calibration constants, stored in PIC flash as part of the firmware.
 *
 * Deliberately NOT stored in the I2C EEPROM / calibration area used by
 * calibration_restore()/settings_*: existing calibration data there must not
 * be overwritten (user requirement, 2026-11-15). Nothing in the current
 * firmware touches that EEPROM.
 *
 * Model per range (fit of displayed value y against reference x):
 *     y = gain * x + offset   ->   x = (y - offset) / gain
 * Reference: Keithley 2700 (6.5 digits, SLOW, filter on) read by camera,
 * RD6018P as source, 11 points over the whole range (300 V range: 0..30 V).
 * Previous Riden-only calibration: see develope-log.md.
 */
#ifndef CAL_DCV_H
#define CAL_DCV_H

#include <adcdefs.h>

typedef struct {
    adc_range range;
    double gain;
    double offset;      /* volts */
    int decimals;       /* display decimals in display unit (6.5 digits, 300 mV: 5.5 in mV) */
    double disp_scale;  /* volts -> display unit */
    const char *unit;
} cal_dcv_t;

static const cal_dcv_t cal_dcv_table[] = {
    /* range           gain        offset      dec  scale unit */
    { ADC_RANGE_300m,  0.9757958,  5.6e-6,     3, 1e3, "mV" },  /* 2026-11-15 vs Keithley 2700, 0..0.3 V, resid <= 19 uV */
    { ADC_RANGE_3,     0.9794453,  24.8e-6,    6, 1.0, "V" },   /* 2026-11-15 vs Keithley 2700, 0..3.0 V, resid <= 17 uV */
    { ADC_RANGE_30,    0.9794307,  -84.3e-6,   5, 1.0, "V" },   /* 2026-11-15 vs Keithley 2700, 0..30 V, resid <= 0.24 mV (2700 10 V/100 V range step ~40 ppm) */
    { ADC_RANGE_300,   1.0746249,  -385.6e-6,  4, 1.0, "V" },   /* 2026-11-15 vs Keithley 2700, only 0..30 V, resid <= 0.55 mV */
};

static inline const cal_dcv_t *cal_dcv_find(adc_range r)
{
    for (unsigned i = 0; i < sizeof(cal_dcv_table) / sizeof(cal_dcv_table[0]); i++)
        if (cal_dcv_table[i].range == r)
            return &cal_dcv_table[i];
    return 0;
}

static inline double cal_dcv_apply(adc_range r, double y)
{
    const cal_dcv_t *c = cal_dcv_find(r);
    return c ? (y - c->offset) / c->gain : y;
}

static inline int cal_dcv_decimals(adc_range r)
{
    const cal_dcv_t *c = cal_dcv_find(r);
    return c ? c->decimals : 5;
}

static inline double cal_dcv_scale(adc_range r)
{
    const cal_dcv_t *c = cal_dcv_find(r);
    return c ? c->disp_scale : 1.0;
}

static inline const char *cal_dcv_unit(adc_range r)
{
    const cal_dcv_t *c = cal_dcv_find(r);
    return c ? c->unit : "V";
}

#endif
