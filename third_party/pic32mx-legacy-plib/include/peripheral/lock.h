/********************************************************************
 * FileName:		lock.h
 * Dependencies:
 * Processor:		PIC32
 * Hardware:		N/A
 * Assembler:		N/A
 * Linker:		    N/A
 * Company:		    Microchip Technology Inc.
 *
 * Software License Agreement:
 * The software supplied herewith by Microchip Technology Incorporated
 * (the “Company”) for its PICmicro® Microcontroller is intended and
 * supplied to you, the Company’s customer, for use solely and
 * exclusively on Microchip PICmicro Microcontroller products. The
 * software is owned by the Company and/or its supplier, and is
 * protected under applicable copyright laws. All rights are reserved.
 * Any use in violation of the foregoing restrictions may subject the
 * user to criminal sanctions under applicable laws, as well as to
 * civil liability for the breach of the terms and conditions of this
 * license.
 *
 * THIS SOFTWARE IS PROVIDED IN AN “AS IS” CONDITION. NO WARRANTIES,
 * WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
 * TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
 * IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
 * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 *
 * $Id: CoreTimer.h,v 1.2 2006/11/03 15:07:21 C12923 Exp $
 * $Name:  $
 ********************************************************************/

#ifndef _LOCK_H_
#define _LOCK_H_

#include <xc.h>
#include <peripheral/int.h>

/*
 * PIC32MX350F256L defines _DMAC but this project never uses DMA.
 * DmaSuspend() spins on DMACONbits.SUSPEND which never clears if
 * the DMA controller was never initialised — hanging every caller
 * of mSYSTEMUnlock (OSCSetPBDIV, SYSTEMConfigPerformance, etc.).
 * Force the non-DMA path for all three macros.
 */
#ifdef _DMAC
#undef _DMAC
#endif

/* Not including <peripheral/dma.h> any more — not needed. */

/*********************************************************************
  Function:        void mSYSTEMUnlock(intStat, dmaSusp)
  Note:            dmaSusp accepted but unused (non-DMA path).
 ********************************************************************/
#define	mSYSTEMUnlock(intStat, dmaSusp)	do{intStat=INTDisableInterrupts(); \
					SYSKEY = 0, SYSKEY = 0xAA996655, SYSKEY = 0x556699AA;}while(0)

/*********************************************************************
  Function:        void mSYSTEMLock(intStat, dmaSusp)
 ********************************************************************/
#define mSYSTEMLock(intStat, dmaSusp)	do{SYSKEY = 0x33333333; INTRestoreInterrupts(intStat);}while(0)

/*********************************************************************
  Function:        void mSysUnlockOpLock(op)
 ********************************************************************/
#define	mSysUnlockOpLock(op)	do{int intStat; intStat=INTDisableInterrupts(); \
			SYSKEY = 0, SYSKEY = 0xAA996655, SYSKEY = 0x556699AA; \
			(op); \
			SYSKEY = 0x33333333; \
			INTRestoreInterrupts(intStat);}while(0)





#endif	// _LOCK_H_
