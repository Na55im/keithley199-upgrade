/*
 * hal_timer.c
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
 * Created on January 23, 2015, 8:30 PM
 */

#include <HardwareProfile.h>
#include <hal_timer.h>

static int period;
static hal_timer_callback callback;

/* Same semantics as PLIB OpenCoreTimer / UpdateCoreTimer (see open_core_timer_lib.o). */
static void __attribute__((nomips16)) hal_core_timer_open(unsigned int period_ticks)
{
    __asm__ volatile("mtc0 $0, $9" ::: "memory");
    __asm__ volatile("mtc0 %0, $11" : : "r"(period_ticks) : "memory");
}

static void __attribute__((nomips16)) hal_core_timer_update(unsigned int delta)
{
    unsigned count;
    __asm__ volatile("mfc0 %0, $9" : "=r"(count));
    unsigned next = count + delta;
    __asm__ volatile("mtc0 %0, $11" : : "r"(next) : "memory");
}

void __attribute__((nomips16)) hal_timer_init(int period_us, hal_timer_callback callback_fn)
{
    callback = callback_fn;
    period = period_us * 40;
    mConfigIntCoreTimer(CT_INT_ON | CT_INT_PRIOR_3 | CT_INT_SUB_PRIOR_0);
    hal_core_timer_open((unsigned int)period);
}

void __attribute__((nomips16)) CT_handler(void)
{
    IFS0CLR = _IFS0_CTIF_MASK;
    if (callback) {
        callback();
    }
    hal_core_timer_update((unsigned int)period);
}
