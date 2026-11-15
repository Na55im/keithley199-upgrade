/* Hardware Interface to ADC
 * Keithley 199 Upgrade
 *
 * This file implements the ADC Low level control interface
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
 */

/* Integrating adc control
 * This file is responsible for generating the control timing for
 * the ADC.
 *
 * The tolerable jitter is around 500nS (minimal) we strive to reach
 * a jitter of about 50 nS. (actual value is about 20ps.)
 *
 * Output compare generates the strobe pulses. With this method we
 * can guarantee precise, hardware controlled, pulse generation. Precise
 * pulse duration of 20mS (16mS) is only for the integration (runup ramp)
 * important.
 *
 * The conversion sequence is fixed. It starts with the run up integration period
 * of 20mS, and after exactly 20ms (16ms) a stop command is sent, and the 
 * integration counter is read. 1 ms after, an start rundown command is sent, and
 * we wait for about 5-6ms that the rundown counter stops. 
 * No stop rundown is needed, as the counter automatically stops when no more 
 * pulses are comming from the hardware integration stage. 
 * Complete conversion sequence takes 26mS.
 * 
 * The default integration period is 20ms for 50Hz and 16ms for 60Hz. Other 
 * values are possible, playing with the pulse generation.
 *
 */

// #include <peripheral/outcompare.h> // Included via HardwareProfile.h
// #include <peripheral/timer.h> // Included via HardwareProfile.h
// #include <peripheral/pps.h> // Included via HardwareProfile.h
// #include <peripheral/ports.h> // Included via HardwareProfile.h
// #include <peripheral/spi.h> // Included via HardwareProfile.h
#include <stdint.h>
#include <assert.h>
#ifdef TEST
#include <os_test.h>
#else
#include <FreeRTOS.h>
#include <queue.h>
#include <task.h>
#endif


#include "HardwareProfile.h"
#include <hal_io.h>

#define KMM_DATA_INV 0u      /* 1 = send inverted bytes (opto inverts data) */
#define KMM_CKP      0u      /* 1 = SPI1 clock idle high */

/* SPI1 (KMM bus): SFR only — SpiChnOpen/SpiChnPutC may link at address 0. */
static void __attribute__((nomips16)) hal_adc_spi1_hw_open(unsigned int src_clk_div)
{
    if (src_clk_div < 2u)
        src_clk_div = 2u;
    if (src_clk_div > 1024u)
        src_clk_div = 1024u;

    SPI1CONbits.ON = 0;
    while (SPI1STATbits.SPIBUSY) {
    }
    SPI1STATCLR = _SPI1STAT_SPIROV_MASK;
    SPI1CON2 = 0;
    SPI1BRG = src_clk_div / 2u - 1u;
    SPI1CON = 0;
    SPI1CONSET = _SPI1CON_MSTEN_MASK | _SPI1CON_CKE_MASK | _SPI1CON_DISSDI_MASK
               | (KMM_CKP ? _SPI1CON_CKP_MASK : 0u);
    SPI1CONbits.ON = 1;
}

/* Timer2/OC clock for integration timing (not the CPU PB clock in HardwareProfile.h). */
#define ADC_OSC_COMPARE_FREQ 2500000ULL
/* KMM interface timing scale. The firmware that was used before ran on FRC
 * 8 MHz (crystal not running), i.e. all KMM timings were 10x longer than the
 * 80 MHz values below were written for. Optocouplers on the analog board
 * may need the slow timing. */
#define KMM_SLOW 1u          /* strobe low time, start wait, SPI1 clock divider */
/* Bring-up timing knobs (FreeRTOS ticks, 600 Hz -> 1.67 ms per tick). */
#define ADC_INT_SCALE    1u  /* integration period multiplier (1 = 20 ms @ 50 Hz) */
#define KMM_MUX_WAIT     1u  /* after each plain mux strobe */
#define KMM_INT_WAIT     1u  /* after start-integration strobe, before pause mux (< integration period!) */
#define KMM_SETTLE_WAIT  1u  /* after end of integration, before reading up count */
#define KMM_RUNDOWN_WAIT 2u  /* after rundown strobe, before reading down count */
#define ADC_STROBE_LOW_TIME (63 * KMM_SLOW) /**< strobe low time @ 2.5MHz OC/timer clock */
#define START_WAIT_TIME (120 * KMM_SLOW)  /**< wait time before first strobe is sended */
#define DOWN_RAMP_TIME  120 /**< wait time before down_ramp_strobe is sended */
/* variable used for the hardware (output compare) pulse generator.
 * it is set to one each time the output compare triggers, and let the oc knows
 * if actually only the start strobe was triggered or also the integration strobe
 * integration strobe is two strobe pulses with separation of exactly INTEGRATION
 * PERIOD ms */
static int pulsecounter = 0;
#ifdef TEST
unsigned int integration_period;
#else
static unsigned int integration_period;
#endif
static QueueHandle_t data_sended = NULL;


void (*hal_adc_int_hook)(void) = 0;
static void send_strobe_and_wait(unsigned int wait_time);
static void adc_send_mux(char channel, uint32_t mux);

static void hal_counter_init();
static void hal_counter_restart();
static uint32_t hal_counter_read();


/* It would be nice to remove the os dependencies from this file.
 */

void hal_adc_send_mux(uint8_t channel, uint32_t mux){
    /* send this mux configuration */
    adc_send_mux(channel, mux);
    send_strobe_and_wait(START_WAIT_TIME);
    /* wait a little bit before sending the next sequence */
    vTaskDelay(KMM_MUX_WAIT);
}


int hal_adc_integration_sequence (uint8_t channel, uint32_t int_mux, uint32_t pause_mux, uint32_t rund_mux){
    uint32_t up_counter, down_counter;
    /* reset counter integration counter  */
    hal_counter_restart();
    /* send the start integration sequence */
    adc_send_mux(channel,int_mux);
    send_strobe_and_wait(START_WAIT_TIME);
    /* wait a little bit before sending the next sequence */
    if (hal_adc_int_hook)
        hal_adc_int_hook();     /* bring-up: e.g. sample ACOUNT during integration */
    vTaskDelay(KMM_INT_WAIT);
    /* send the end integration sequence */
    adc_send_mux(channel, pause_mux);
    /* strobe is send automatically from the oc module. just wait for it! */
    char t;
    xQueueReceive(data_sended, &t, portMAX_DELAY);
    /* wait a little bit to receive all count pulses */
    vTaskDelay(KMM_SETTLE_WAIT);
    /* read up pulses */
    up_counter = hal_counter_read();
    /* reset counter */
    hal_counter_restart();
    /* send the start rundown count sequence */
    adc_send_mux(channel, rund_mux);
    send_strobe_and_wait(START_WAIT_TIME);
    /* wait until all adc pulses are received */
    vTaskDelay(KMM_RUNDOWN_WAIT);
    /* stop strobe from retrigger */
    T2CONbits.ON = 0; 
    /* read counter */
    down_counter = hal_counter_read();
    /* make final count calculations */
    uint32_t adc_counter = up_counter*128 + down_counter;
    return adc_counter;
}


/* OC3 (strobe, RG1) in 32-bit continuous-pulse mode on Timer2/3:
 * pin goes low at OC3RS (falling edge -> interrupt), high again at OC3R = 0.
 * SFR only - the PLIB OC/timer/int helpers are not used (see CLAUDE.md). */
static void __attribute__((nomips16)) oc3_setup(void)
{
    IEC0CLR = _IEC0_OC3IE_MASK;
    OC3CON = 0;
    IFS0CLR = _IFS0_OC3IF_MASK;
    OC3RS = integration_period - ADC_STROBE_LOW_TIME;
    OC3R = 0;
    OC3CON = _OC3CON_OC32_MASK | (5u << _OC3CON_OCM_POSITION); /* Timer2 source */
    OC3CONSET = _OC3CON_ON_MASK;
    IPC3CLR = _IPC3_OC3IP_MASK | _IPC3_OC3IS_MASK;
    IPC3SET = (3u << _IPC3_OC3IP_POSITION);
    IFS0CLR = _IFS0_OC3IF_MASK;
    IEC0SET = _IEC0_OC3IE_MASK;
}

void hal_adc_set_integration_period(uint32_t period){
    integration_period = period*ADC_OSC_COMPARE_FREQ/1000000ULL*ADC_INT_SCALE;
    PR2 = integration_period;
    oc3_setup();
}

static void send_strobe_and_wait(unsigned int wait_time){
    char t;
    /* start conunter and send down pulse after start_wait_time */
    TMR2 = integration_period - wait_time;
    pulsecounter = 0;
    T2CONbits.ON = 1;
    /* wait until strobe is high again */
    xQueueReceive(data_sended,&t,portMAX_DELAY);
}

/**@brief send a byte to the adc mux*/
static void __attribute__((nomips16)) hal_adc_sendbyte(char c);


/* Initializes adc and control structures. Output compare 3 is used to generate
 * the 20ms integration period, as timer interrupt have too much jitter. Timer
 * 23 (32bit) counts output compare pulses, 32 bit for better resolution. */
void hal_adc_init(unsigned int period){
    integration_period = period*ADC_OSC_COMPARE_FREQ/1000000ULL*ADC_INT_SCALE;
    /* Timer2/3 as 32-bit timer, PBCLK/32 = 2.5 MHz, off until a strobe is sent */
    T2CON = 0;
    T3CON = 0;
    T2CON = _T2CON_T32_MASK | (5u << _T2CON_TCKPS_POSITION);
    TMR2 = 0;
    PR2 = integration_period;
    oc3_setup();
    hal_gpio_pins_digital_out(IOPORT_G, BIT_1);
    RPG1R = 11;                 /* OC3 -> RG1 (KMM strobe) */
    if(!data_sended){
        data_sended = xQueueCreate(1, sizeof(char));
    }
    hal_counter_init();
    hal_adc_spi1_hw_open(80u * KMM_SLOW);
    RPF8R = 8;                  /* SDO1 -> RF8 (KMM data) */
    hal_gpio_pins_digital_out(KMM_CLK);
    hal_gpio_pins_digital_out(KMM_DATA);
    hal_gpio_pins_digital_out(KMM_STRB);
}

#ifdef TEST
void
#else
void __attribute__(( nomips16, interrupt(IPL3AUTO), vector(_OUTPUT_COMPARE_3_VECTOR)))
#endif
OC3_wrapper(void);

/* The strobe pin is setted/cleared in hardware, by using the output compare.
 * we use the interrupt in order to transmit the control bytes between strobe
 * activations.*/
void __attribute__((nomips16)) OC3_handler(void){
    portBASE_TYPE xHigerPriorityTaskWoken;
    xQueueSendFromISR(data_sended,&pulsecounter, &xHigerPriorityTaskWoken);
    pulsecounter++;
    if(pulsecounter>1){
        /* whait a little while before setting the strobe to one again. It is ne
         * cessary because the strobe optocoupler is slow. */
        for(pulsecounter = 0; pulsecounter < 250 * (int)KMM_SLOW; pulsecounter++);
        TMR2 = 0; // Set strobe high again.
        T2CONbits.ON = 0; // Disable timer to prevent retriggering.
    }
    IFS0CLR = _IFS0_OC3IF_MASK;
    // Switch to a waiting task.
    portEND_SWITCHING_ISR(xHigerPriorityTaskWoken);
}

static void __attribute__((nomips16)) hal_adc_sendbyte(char c)
{
    SPI1BUF = (uint32_t)(unsigned char)(KMM_DATA_INV ? ~c : c);
    while (SPI1STATbits.SPIBUSY) {
    }
}

static void adc_send_mux(char channel, uint32_t mux){
    hal_adc_sendbyte(channel);
    char val = (mux >> 24);
    hal_adc_sendbyte(val);
    val = (mux >> 16);
    hal_adc_sendbyte(val);
    val = (mux >> 8);
    hal_adc_sendbyte(val);
    val = (mux);
    hal_adc_sendbyte(val);
}

/* Timer4/5 as 32-bit counter clocked externally from T4CK <- RE3 (KMM count). */
static void hal_counter_init(){
    TRISESET = (1u << 3);
    CNPUESET = (1u << 3);       /* ACOUNT has no pull-up on the board (P18.6 -> RE3) */
    T4CKR = 6;                  /* RPE3 -> T4CK */
    T4CON = 0;
    T5CON = 0;
    TMR4 = 0;
    PR4 = 0xFFFFFFFF;
    T4CON = _T4CON_T32_MASK | _T4CON_TCS_MASK;
    T4CONSET = _T4CON_ON_MASK;
}


static void hal_counter_restart(){
    TMR4 = 0;
}

static uint32_t hal_counter_read(){
    return TMR4;
}