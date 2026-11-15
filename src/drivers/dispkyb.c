#include <hal.h>
#include <hal_timer.h>
#include <FreeRTOS.h>
#include <queue.h>
#include <assert.h>
#include <stdint.h>
#include <string.h>
#include "task.h"
#include "hal_io.h"
#include "hal_spi.h"
#include "dispkyb.h"

#define EVENT_QUEUE_LENGTH 1
QueueHandle_t event_queue;

#define KYB_REPETITION_PERIOD_MS 60

key_id display_wait_for_key()
{
    key_id key;
    xQueueReceive(event_queue, &key, portMAX_DELAY);
    return key;
}

static void timer_handler(void);

#define NUMBER_OF_SEGMENTS   15

static uint16_t screen[NUMBER_OF_CHARACTERS];
static bool self_test = false;

static int highlighted_digit = 0;

/*
 * Timer fires once per full frame at ~90 Hz.
 * Inside one ISR call we clock through ALL 11 digit positions,
 * holding each digit for ~1 ms  (total ISR ≈ 11 ms).
 */
/* One digit slot per core-timer interrupt: the ISR only shifts the select word
 * and returns, the digit stays lit until the next interrupt. 11 slots x 1 ms
 * = ~90 Hz frame rate. (Scanning the whole frame with busy-wait dwell inside
 * one ISR every 100 us starved FreeRTOS: tick ~10x too slow, OC3/ADC ISR
 * delayed by up to a frame.) */
#define SLOT_PERIOD_US    1000u
#define FRAME_PERIOD_US   (SLOT_PERIOD_US * NUMBER_OF_CHARACTERS)
#define KEY_HOLDOF_PERIOD 500             /* ms */
#define KEY_REPEAT_PERIOD 100             /* ms */


void display_kyb_init(void)
{
    hal_io_init();
    hal_spi_init_16bit();
    event_queue = xQueueCreate(EVENT_QUEUE_LENGTH, sizeof(key_id));
    hal_timer_init((int)SLOT_PERIOD_US, timer_handler);
}

void display_evt_clear(void){
    char item;
    while(xQueueReceive(event_queue, &item, 0)==pdTRUE);
    BaseType_t val = xQueueReset(event_queue);
    val = val;
    assert(val == pdPASS);
}

void display_highlight(int digit)
{
    highlighted_digit = digit;
}

static void __attribute__((nomips16)) display_set(unsigned int segments, int char_slot)
{
	int bus = (int)hal_digit_bus_line(char_slot);

	hal_io_displayport_write(0);
	hal_display_select_digit(bus);
	hal_io_displayport_write(segments);
}

void display_setmode(disp_mode mode)
{
    screen[NUMBER_OF_CHARACTERS - 1] |= mode;
}

void display_clearmode(disp_mode mode)
{
    screen[NUMBER_OF_CHARACTERS - 1] &= ~mode;
}

void display_puts(char* c)
{
    int i = 0, position = 0;
    while (c[i] != 0) {
        if (c[i] == '.')
            display_putc(c[i], position);
        else
            display_putc(c[i], position++);
        i++;
        if (position > (NUMBER_OF_CHARACTERS - 2)) break;
    }
}

void display_adc_indicator(bool set_value)
{
    uint16_t adci = hal_io_displayport_map_char_to_segments('.');
    if (set_value)
        screen[NUMBER_OF_CHARACTERS - 2] |= adci;
    else
        screen[NUMBER_OF_CHARACTERS - 2] &= ~adci;
}

void hal_disp_adci_toggle()
{
    uint16_t adci = hal_io_displayport_map_char_to_segments('.');
    if (screen[NUMBER_OF_CHARACTERS - 2] & adci)
        screen[NUMBER_OF_CHARACTERS - 2] &= ~adci;
    else
        screen[NUMBER_OF_CHARACTERS - 2] |= adci;
}

void display_clear()
{
    uint16_t adci = hal_io_displayport_map_char_to_segments('.');
    adci &= screen[NUMBER_OF_CHARACTERS - 2];
    char dmode = screen[NUMBER_OF_CHARACTERS - 1];
    memset(screen, 0, sizeof(uint16_t) * NUMBER_OF_CHARACTERS);
    screen[NUMBER_OF_CHARACTERS - 1] |= dmode;
    screen[NUMBER_OF_CHARACTERS - 2] |= adci;
}

void display_segment_snake_step(unsigned int step)
{
    static const uint8_t seg_snake_order[15] = {
        10, 2, 14, 0, 1, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13
    };
    const int max_digits = NUMBER_OF_CHARACTERS - 1;

    display_clear();
    int n = (int)step + 1;
    if (n > max_digits)
        n = max_digits;
    for (int d = 0; d < n; d++) {
        int oi = (int)step - d;
        while (oi < 0)
            oi += 15;
        oi %= 15;
        uint8_t seg_idx = seg_snake_order[oi];
        screen[d] = hal_io_get_segment((int)seg_idx);
    }
}

void display_putc(char c, int pos)
{
    uint16_t adci = hal_io_displayport_map_char_to_segments('.');
    adci &= screen[NUMBER_OF_CHARACTERS - 2];
    if (self_test) return;
    if (pos < 0 || pos >= (NUMBER_OF_CHARACTERS - 1)) return;
    if (c == '.')
        screen[pos - 1] |= hal_io_displayport_map_char_to_segments(c);
    else
        screen[pos] = hal_io_displayport_map_char_to_segments(c);
    screen[NUMBER_OF_CHARACTERS - 2] |= adci;
}

void display_test()
{
    self_test = true;
    while (self_test);
}

#define TEST_MAX_DELAY 5000
#define HIGHLIGHT_TIME 1
static int test_segment = 0, test_delay = TEST_MAX_DELAY;
static key_id key_pressed = KEY_NONE;
static key_id last_key_pressed = KEY_NONE;
static int hl_time = 0;

/*
 * Scan ALL digit positions in one call (one full 90 Hz frame).
 * For each digit: write segments → advance digit select → hold ~1 ms.
 * Keyboard matrix is read per-digit since the select line is shared.
 */
static unsigned int scan_pos = 0;
static key_id frame_key = KEY_NONE;

/* Light one digit slot. Returns true when a full frame has been scanned. */
static bool __attribute__((nomips16)) hal_disp_scan_step(void)
{
    unsigned int pos = scan_pos;
    unsigned int bus = hal_digit_bus_line((int)pos);

    if (pos == 0)
        frame_key = KEY_NONE;

    if (highlighted_digit == (int)pos) {
        if (hl_time > HIGHLIGHT_TIME) {
            hl_time = 0;
        } else {
            hl_time++;
        }
    }

    display_set(screen[pos], (int)pos);

    /* Keyboard scan for the currently selected digit (hardware bus index) */
    if (hal_io_keyboard_get_channel() == 1) {
        switch (bus) {
            case 1: frame_key = KEY_1; break;
            case 2: frame_key = KEY_3; break;
            case 3: frame_key = KEY_0; break;
            case 4: frame_key = KEY_8; break;
        }
    }
    if (hal_io_keyboard_get_channel() == 2) {
        switch (bus) {
            case 1: frame_key = KEY_UP; break;
            case 2: frame_key = KEY_9;  break;
            case 3: frame_key = KEY_2;  break;
            case 4: frame_key = KEY_DOWN; break;
        }
    }
    if (hal_io_keyboard_get_channel() == 3) {
        switch (bus) {
            case 1: frame_key = KEY_7;   break;
            case 2: frame_key = KEY_6;   break;
            case 3: frame_key = KEY_5;   break;
            case 4: frame_key = KEY_CAL; break;
            case 5: frame_key = KEY_4;   break;
        }
    }

    scan_pos = (pos + 1u) % NUMBER_OF_CHARACTERS;
    return scan_pos == 0u;
}

/* End of frame: key evaluation and self-test (once per frame). */
static key_id __attribute__((nomips16)) hal_disp_scan(void)
{
    key_pressed = frame_key;

    /* Original: after F7FE the next frame starts with FFDF — no extra 0xFFFF word.
     * Do not blank PORTD here while F7FE is still latched (that weakly lights LEDs). */

    if (key_pressed != KEY_NONE)
        last_key_pressed = key_pressed;
    else
        last_key_pressed = KEY_NONE;

    if (self_test == false)
        return last_key_pressed;

    /* ---- self-test mode (walks individual segments) ---- */
    int i = 0;
    screen[NUMBER_OF_CHARACTERS - 1] = 0xFFFF;
    if (test_delay >= TEST_MAX_DELAY) {
        if (test_segment < NUMBER_OF_SEGMENTS) {
            for (i = 0; i < NUMBER_OF_CHARACTERS - 1; i++)
                screen[i] = hal_io_get_segment(test_segment);
            test_segment++;
        } else {
            for (i = 0; i < NUMBER_OF_CHARACTERS; i++)
                screen[i] = 0;
            screen[test_segment++ - NUMBER_OF_SEGMENTS] = 0xFFFF;
            if (test_segment - NUMBER_OF_SEGMENTS > NUMBER_OF_CHARACTERS) {
                self_test = false;
                test_segment = 0;
                test_delay = TEST_MAX_DELAY;
                return KEY_NONE;
            }
        }
        test_delay = 0;
    } else {
        test_delay++;
    }
    return KEY_NONE;
}

static key_id last_key_interrupt = KEY_NONE;
static int holdoff_counter = 0;
static int rept_counter = 0;

void timer_handler(void)
{
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;
    if (!hal_disp_scan_step())
        return;
    key_id key = hal_disp_scan();
    if (key != last_key_interrupt) {
        xQueueSendToBackFromISR(event_queue, &key, &xHigherPriorityTaskWoken);
        last_key_interrupt = key;
        holdoff_counter = 0;
        rept_counter = 0;
    } else {
        if (key != KEY_NONE) {
            holdoff_counter++;
            if (holdoff_counter > KEY_HOLDOF_PERIOD * 1000 / (int)FRAME_PERIOD_US) {
                holdoff_counter--;
                if (rept_counter++ > KEY_REPEAT_PERIOD * 1000 / (int)FRAME_PERIOD_US) {
                    xQueueSendToBackFromISR(event_queue, &key, &xHigherPriorityTaskWoken);
                    rept_counter = 0;
                }
            }
        }
    }
    portEND_SWITCHING_ISR(xHigherPriorityTaskWoken);
}
