/*
 * hal_io.c
 *
 * Copyright (c) 2015, Diego F. Asanza. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 *
 * Created on January 23, 2015, 8:47 PM
 */

#include <HardwareProfile.h>
#include <hal_io.h>

/*
 * Direct SFR GPIO (no legacy PLIB PORT*). PLIB symbols have been observed at
 * VMA 0 when the peripheral archive is not resolved — calls then jump to zero.
 */
static void __attribute__((nomips16)) hal_io_displayport_init(void);
static void __attribute__((nomips16)) hal_io_keyboard_init(void);

void __attribute__((nomips16)) hal_gpio_pins_digital_out(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A:
        ANSELACLR = mask;
        ODCACLR = mask;
        TRISACLR = mask;
        break;
    case IOPORT_B:
        ANSELBCLR = mask;
        ODCBCLR = mask;
        TRISBCLR = mask;
        break;
    case IOPORT_C:
        ANSELCCLR = mask;
        ODCCCLR = mask;
        TRISCCLR = mask;
        break;
    case IOPORT_D:
        ANSELDCLR = mask;
        ODCDCLR = mask;
        TRISDCLR = mask;
        break;
    case IOPORT_E:
        ANSELECLR = mask;
        ODCECLR = mask;
        TRISECLR = mask;
        break;
    case IOPORT_F:
        ANSELFCLR = mask;
        ODCFCLR = mask;
        TRISFCLR = mask;
        break;
    case IOPORT_G:
        ANSELGCLR = mask;
        ODCGCLR = mask;
        TRISGCLR = mask;
        break;
    default:
        break;
    }
}

static void __attribute__((nomips16)) hal_sfr_port_digital_in(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A:
        ANSELACLR = mask;
        ODCACLR = mask;
        TRISASET = mask;
        break;
    case IOPORT_B:
        ANSELBCLR = mask;
        ODCBCLR = mask;
        TRISBSET = mask;
        break;
    case IOPORT_C:
        ANSELCCLR = mask;
        ODCCCLR = mask;
        TRISCSET = mask;
        break;
    case IOPORT_D:
        ANSELDCLR = mask;
        ODCDCLR = mask;
        TRISDSET = mask;
        break;
    case IOPORT_E:
        ANSELECLR = mask;
        ODCECLR = mask;
        TRISESET = mask;
        break;
    case IOPORT_F:
        ANSELFCLR = mask;
        ODCFCLR = mask;
        TRISFSET = mask;
        break;
    case IOPORT_G:
        ANSELGCLR = mask;
        ODCGCLR = mask;
        TRISGSET = mask;
        break;
    default:
        break;
    }
}

static void __attribute__((nomips16)) hal_sfr_port_set_bits(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A: LATASET = mask; break;
    case IOPORT_B: LATBSET = mask; break;
    case IOPORT_C: LATCSET = mask; break;
    case IOPORT_D: LATDSET = mask; break;
    case IOPORT_E: LATESET = mask; break;
    case IOPORT_F: LATFSET = mask; break;
    case IOPORT_G: LATGSET = mask; break;
    default: break;
    }
}

static void __attribute__((nomips16)) hal_sfr_port_clear_bits(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A: LATACLR = mask; break;
    case IOPORT_B: LATBCLR = mask; break;
    case IOPORT_C: LATCCLR = mask; break;
    case IOPORT_D: LATDCLR = mask; break;
    case IOPORT_E: LATECLR = mask; break;
    case IOPORT_F: LATFCLR = mask; break;
    case IOPORT_G: LATGCLR = mask; break;
    default: break;
    }
}

static void __attribute__((nomips16)) hal_sfr_port_toggle_bits(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A: LATAINV = mask; break;
    case IOPORT_B: LATBINV = mask; break;
    case IOPORT_C: LATCINV = mask; break;
    case IOPORT_D: LATDINV = mask; break;
    case IOPORT_E: LATEINV = mask; break;
    case IOPORT_F: LATFINV = mask; break;
    case IOPORT_G: LATGINV = mask; break;
    default: break;
    }
}

static unsigned int __attribute__((nomips16)) hal_sfr_port_read_bits(IoPortId port, unsigned int mask)
{
    switch (port) {
    case IOPORT_A: return PORTA & mask;
    case IOPORT_B: return PORTB & mask;
    case IOPORT_C: return PORTC & mask;
    case IOPORT_D: return PORTD & mask;
    case IOPORT_E: return PORTE & mask;
    case IOPORT_F: return PORTF & mask;
    case IOPORT_G: return PORTG & mask;
    default: return 0;
    }
}

/* 14 segment display individual segments
 * aaaaaaaaaaa
 * f i  g   hb
 * f  i g  h b
 * f   ig h  b
 * f    ih   b
 * ennnnnjjjjj
 * e   ml k  c
 * e  m l  k c
 * e m  l   kc   
 * ddddddddddd   dp
 */
static uint16_t segments[] = {
    seg_a,
    seg_b,
    seg_c,
    seg_d,
    seg_e,
    seg_f,
    seg_g,
    seg_h,
    seg_j,
    seg_k,
    seg_l,
    seg_m,
    seg_n,
    seg_i,
    seg_dp
};

uint16_t hal_io_get_segment(int segment){
    return segments[segment];
}

void __attribute__((nomips16)) hal_io_init(void){
    hal_gpio_pins_digital_out(BRD_GREEN_LED);
    hal_sfr_port_set_bits(BRD_GREEN_LED);
    hal_gpio_pins_digital_out(BRD_AUX_LED);
    hal_sfr_port_set_bits(BRD_AUX_LED);
    hal_gpio_pins_digital_out(BRD_RED_LED);
    hal_sfr_port_set_bits(BRD_RED_LED);
    hal_gpio_pins_digital_out(DEBUG_PIN_0);
    hal_sfr_port_clear_bits(DEBUG_PIN_0);
    hal_gpio_pins_digital_out(BUZZER);
    hal_sfr_port_clear_bits(BUZZER);
    hal_io_displayport_init();
    hal_io_keyboard_init();
}

static void __attribute__((nomips16)) hal_io_displayport_init(void){
    /* initializes keyboard (keyboard is scanned with display digits */
    hal_gpio_pins_digital_out(DISPLAY_PORT, 0xFFFF);
}

static void __attribute__((nomips16)) hal_io_keyboard_init(void){
    hal_sfr_port_digital_in(HAL_KYB_S0);
    hal_sfr_port_digital_in(HAL_KYB_S1);
    hal_sfr_port_digital_in(HAL_KYB_S2);
}

void __attribute__((nomips16)) hal_io_displayport_write(uint16_t segments){
    hal_sfr_port_clear_bits(DISPLAY_PORT, 0xFFFF);
    hal_sfr_port_set_bits(DISPLAY_PORT, segments);
}

int __attribute__((nomips16)) hal_io_keyboard_get_channel(void){
    if (!hal_sfr_port_read_bits(HAL_KYB_S0))
        return 1;
    if (!hal_sfr_port_read_bits(HAL_KYB_S1))
        return 2;
    if (!hal_sfr_port_read_bits(HAL_KYB_S2))
        return 3;
    return 0;
}

/* bits from 2^15 to 2^0. 2^0 is not connected and should be always 0.
 * n dp d l h i j k m g a f c e b x
 * aaaaaaaaaaa
 * f i  g   hb
 * f  i g  h b
 * f   ig h  b
 * f    ih   b
 * ennnnnjjjjj
 * e   ml k  c
 * e  m l  k c
 * e m  l   kc
 * ddddddddddd
 */
static uint16_t chartable[] = {
    0x823E, 0x326A, 0x2034, 0x306A, 0xA034, 0x8034, 0x223C,
    0x821E, 0x3060, 0x200E, 0x8914, 0x2014, 0x0C1E, 0x051E,
    0x203E, 0x8236, 0x213E, 0x8336, 0xA238, 0x1060, 0x201E,
    0x0894, 0x019E, 0x0D80, 0xA21A, 0x28A0, 0x203E, 0x1040,
    0xA226, 0x222A, 0x821A, 0xA238, 0xA23C, 0x002A, 0xA23E,
    0xA23A, 0x9240, 0x8200, 0x8E20, 0x920C, 0x8232, 0x0000,
    0x4000, 0xA20E, 0x1222, 0xA200, 0x9FC1, 0x0518, 0x0886
};

uint16_t hal_io_displayport_map_char_to_segments(char c){
    /* TODO: Check c inside allowed range */
    switch(c){
        case 'm': return chartable[39];
        case '+': return chartable[36];
        case '-': return chartable[37];
        case 'o': return chartable[38]; // OHms (omega)
        case 'g': return chartable[40]; // degrees 
        case ' ': return chartable[41];
        case '.': return chartable[42];
        case 'd': return chartable[43];
        case '?': return chartable[44];
        case '=': return chartable[45];
        case '*': return chartable[46];
        case '~': return chartable[47]; // Ac Symbol
        case '#': return chartable[48]; // inverted AC Symbol
    }
    if(c <= 0x39){
        return chartable[c - 22];
    }
    return chartable[c - 0x41];
}

void __attribute__((nomips16)) hal_io_toggle_led(IO_LED led){
    switch(led){
        case SYSERR_LED: hal_sfr_port_toggle_bits(BRD_RED_LED); break;
        case SYSOK_LED: hal_sfr_port_toggle_bits(BRD_GREEN_LED); break;
        case AUX_LED: hal_sfr_port_toggle_bits(BRD_AUX_LED); break;
    }
}

void __attribute__((nomips16)) hal_io_set_led(IO_LED led){
    switch(led){
        case SYSERR_LED: hal_sfr_port_clear_bits(BRD_RED_LED); break;
        case SYSOK_LED: hal_sfr_port_clear_bits(BRD_GREEN_LED); break;
        case AUX_LED: hal_sfr_port_clear_bits(BRD_AUX_LED); break;
    }
}

void __attribute__((nomips16)) hal_io_clear_led(IO_LED led){
    switch(led){
        case SYSERR_LED: hal_sfr_port_set_bits(BRD_RED_LED); break;
        case SYSOK_LED: hal_sfr_port_set_bits(BRD_GREEN_LED); break;
        case AUX_LED: hal_sfr_port_set_bits(BRD_AUX_LED); break;
    }
}

void __attribute__((nomips16)) hal_io_set_debugpin(){
    hal_sfr_port_set_bits(DEBUG_PIN_0);
}
void __attribute__((nomips16)) hal_io_clear_debugpin(){
    hal_sfr_port_clear_bits(DEBUG_PIN_0);
}

void __attribute__((nomips16)) hal_io_toggle_debugpin(){
    hal_sfr_port_toggle_bits(DEBUG_PIN_0);
}
