#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=mkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=elf
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=hex
DEBUGGABLE_SUFFIX=elf
FINAL_IMAGE=${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=-mafrlcsj
else
COMPARISON_BUILD=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=src/drivers/eeprom.c src/drivers/tmp275.c src/drivers/dispkyb.c src/drivers/usb_uart.c src/drivers/adc.c src/drivers/adcctrl.c src/eefs/crc32.c src/eefs/eefs.c src/FreeRTOS/portable/MemMang/heap_4.c src/FreeRTOS/portable/MPLAB/PIC32MX/port.c src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S src/FreeRTOS/timers.c src/FreeRTOS/tasks.c src/FreeRTOS/list.c src/FreeRTOS/event_groups.c src/FreeRTOS/croutine.c src/FreeRTOS/queue.c src/hal/fuses.c src/hal/exceptions.c src/hal/isrWrappers.S src/hal/hal_adc.c src/hal/hal_uart.c src/hal/hal_i2c.c src/hal/hal_spi.c src/hal/hal_timer.c src/hal/hal_io.c src/hal/hal_sys.c src/scpi-parser/libscpi/src/lexer.c src/scpi-parser/libscpi/src/error.c src/scpi-parser/libscpi/src/fifo.c src/scpi-parser/libscpi/src/ieee488.c src/scpi-parser/libscpi/src/minimal.c src/scpi-parser/libscpi/src/parser.c src/scpi-parser/libscpi/src/units.c src/scpi-parser/libscpi/src/utils.c src/sys/src/system.c src/sys/src/settings.c src/tasks/task_calibration.c src/tasks/task_multimeter.c src/tasks/main.c src/tasks/tskmgr.c src/tasks/task_scpi.c src/utils/fcvt-1.1/fcvt.c src/utils/src/diag.c src/utils/src/fitlinear.c src/utils/src/disfmt.c src/utils/src/util_ringbuff.c src/utils/src/strutils.c src/utils/src/utils_math.c

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/src/drivers/eeprom.o ${OBJECTDIR}/src/drivers/tmp275.o ${OBJECTDIR}/src/drivers/dispkyb.o ${OBJECTDIR}/src/drivers/usb_uart.o ${OBJECTDIR}/src/drivers/adc.o ${OBJECTDIR}/src/drivers/adcctrl.o ${OBJECTDIR}/src/eefs/crc32.o ${OBJECTDIR}/src/eefs/eefs.o ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o ${OBJECTDIR}/src/FreeRTOS/timers.o ${OBJECTDIR}/src/FreeRTOS/tasks.o ${OBJECTDIR}/src/FreeRTOS/list.o ${OBJECTDIR}/src/FreeRTOS/event_groups.o ${OBJECTDIR}/src/FreeRTOS/croutine.o ${OBJECTDIR}/src/FreeRTOS/queue.o ${OBJECTDIR}/src/hal/fuses.o ${OBJECTDIR}/src/hal/exceptions.o ${OBJECTDIR}/src/hal/isrWrappers.o ${OBJECTDIR}/src/hal/hal_adc.o ${OBJECTDIR}/src/hal/hal_uart.o ${OBJECTDIR}/src/hal/hal_i2c.o ${OBJECTDIR}/src/hal/hal_spi.o ${OBJECTDIR}/src/hal/hal_timer.o ${OBJECTDIR}/src/hal/hal_io.o ${OBJECTDIR}/src/hal/hal_sys.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o ${OBJECTDIR}/src/sys/src/system.o ${OBJECTDIR}/src/sys/src/settings.o ${OBJECTDIR}/src/tasks/task_calibration.o ${OBJECTDIR}/src/tasks/task_multimeter.o ${OBJECTDIR}/src/tasks/main.o ${OBJECTDIR}/src/tasks/tskmgr.o ${OBJECTDIR}/src/tasks/task_scpi.o ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o ${OBJECTDIR}/src/utils/src/diag.o ${OBJECTDIR}/src/utils/src/fitlinear.o ${OBJECTDIR}/src/utils/src/disfmt.o ${OBJECTDIR}/src/utils/src/util_ringbuff.o ${OBJECTDIR}/src/utils/src/strutils.o ${OBJECTDIR}/src/utils/src/utils_math.o
POSSIBLE_DEPFILES=${OBJECTDIR}/src/drivers/eeprom.o.d ${OBJECTDIR}/src/drivers/tmp275.o.d ${OBJECTDIR}/src/drivers/dispkyb.o.d ${OBJECTDIR}/src/drivers/usb_uart.o.d ${OBJECTDIR}/src/drivers/adc.o.d ${OBJECTDIR}/src/drivers/adcctrl.o.d ${OBJECTDIR}/src/eefs/crc32.o.d ${OBJECTDIR}/src/eefs/eefs.o.d ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o.d ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o.d ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d ${OBJECTDIR}/src/FreeRTOS/timers.o.d ${OBJECTDIR}/src/FreeRTOS/tasks.o.d ${OBJECTDIR}/src/FreeRTOS/list.o.d ${OBJECTDIR}/src/FreeRTOS/event_groups.o.d ${OBJECTDIR}/src/FreeRTOS/croutine.o.d ${OBJECTDIR}/src/FreeRTOS/queue.o.d ${OBJECTDIR}/src/hal/fuses.o.d ${OBJECTDIR}/src/hal/exceptions.o.d ${OBJECTDIR}/src/hal/isrWrappers.o.d ${OBJECTDIR}/src/hal/hal_adc.o.d ${OBJECTDIR}/src/hal/hal_uart.o.d ${OBJECTDIR}/src/hal/hal_i2c.o.d ${OBJECTDIR}/src/hal/hal_spi.o.d ${OBJECTDIR}/src/hal/hal_timer.o.d ${OBJECTDIR}/src/hal/hal_io.o.d ${OBJECTDIR}/src/hal/hal_sys.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o.d ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o.d ${OBJECTDIR}/src/sys/src/system.o.d ${OBJECTDIR}/src/sys/src/settings.o.d ${OBJECTDIR}/src/tasks/task_calibration.o.d ${OBJECTDIR}/src/tasks/task_multimeter.o.d ${OBJECTDIR}/src/tasks/main.o.d ${OBJECTDIR}/src/tasks/tskmgr.o.d ${OBJECTDIR}/src/tasks/task_scpi.o.d ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o.d ${OBJECTDIR}/src/utils/src/diag.o.d ${OBJECTDIR}/src/utils/src/fitlinear.o.d ${OBJECTDIR}/src/utils/src/disfmt.o.d ${OBJECTDIR}/src/utils/src/util_ringbuff.o.d ${OBJECTDIR}/src/utils/src/strutils.o.d ${OBJECTDIR}/src/utils/src/utils_math.o.d

# Object Files
OBJECTFILES=${OBJECTDIR}/src/drivers/eeprom.o ${OBJECTDIR}/src/drivers/tmp275.o ${OBJECTDIR}/src/drivers/dispkyb.o ${OBJECTDIR}/src/drivers/usb_uart.o ${OBJECTDIR}/src/drivers/adc.o ${OBJECTDIR}/src/drivers/adcctrl.o ${OBJECTDIR}/src/eefs/crc32.o ${OBJECTDIR}/src/eefs/eefs.o ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o ${OBJECTDIR}/src/FreeRTOS/timers.o ${OBJECTDIR}/src/FreeRTOS/tasks.o ${OBJECTDIR}/src/FreeRTOS/list.o ${OBJECTDIR}/src/FreeRTOS/event_groups.o ${OBJECTDIR}/src/FreeRTOS/croutine.o ${OBJECTDIR}/src/FreeRTOS/queue.o ${OBJECTDIR}/src/hal/fuses.o ${OBJECTDIR}/src/hal/exceptions.o ${OBJECTDIR}/src/hal/isrWrappers.o ${OBJECTDIR}/src/hal/hal_adc.o ${OBJECTDIR}/src/hal/hal_uart.o ${OBJECTDIR}/src/hal/hal_i2c.o ${OBJECTDIR}/src/hal/hal_spi.o ${OBJECTDIR}/src/hal/hal_timer.o ${OBJECTDIR}/src/hal/hal_io.o ${OBJECTDIR}/src/hal/hal_sys.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o ${OBJECTDIR}/src/sys/src/system.o ${OBJECTDIR}/src/sys/src/settings.o ${OBJECTDIR}/src/tasks/task_calibration.o ${OBJECTDIR}/src/tasks/task_multimeter.o ${OBJECTDIR}/src/tasks/main.o ${OBJECTDIR}/src/tasks/tskmgr.o ${OBJECTDIR}/src/tasks/task_scpi.o ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o ${OBJECTDIR}/src/utils/src/diag.o ${OBJECTDIR}/src/utils/src/fitlinear.o ${OBJECTDIR}/src/utils/src/disfmt.o ${OBJECTDIR}/src/utils/src/util_ringbuff.o ${OBJECTDIR}/src/utils/src/strutils.o ${OBJECTDIR}/src/utils/src/utils_math.o

# Source Files
SOURCEFILES=src/drivers/eeprom.c src/drivers/tmp275.c src/drivers/dispkyb.c src/drivers/usb_uart.c src/drivers/adc.c src/drivers/adcctrl.c src/eefs/crc32.c src/eefs/eefs.c src/FreeRTOS/portable/MemMang/heap_4.c src/FreeRTOS/portable/MPLAB/PIC32MX/port.c src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S src/FreeRTOS/timers.c src/FreeRTOS/tasks.c src/FreeRTOS/list.c src/FreeRTOS/event_groups.c src/FreeRTOS/croutine.c src/FreeRTOS/queue.c src/hal/fuses.c src/hal/exceptions.c src/hal/isrWrappers.S src/hal/hal_adc.c src/hal/hal_uart.c src/hal/hal_i2c.c src/hal/hal_spi.c src/hal/hal_timer.c src/hal/hal_io.c src/hal/hal_sys.c src/scpi-parser/libscpi/src/lexer.c src/scpi-parser/libscpi/src/error.c src/scpi-parser/libscpi/src/fifo.c src/scpi-parser/libscpi/src/ieee488.c src/scpi-parser/libscpi/src/minimal.c src/scpi-parser/libscpi/src/parser.c src/scpi-parser/libscpi/src/units.c src/scpi-parser/libscpi/src/utils.c src/sys/src/system.c src/sys/src/settings.c src/tasks/task_calibration.c src/tasks/task_multimeter.c src/tasks/main.c src/tasks/tskmgr.c src/tasks/task_scpi.c src/utils/fcvt-1.1/fcvt.c src/utils/src/diag.c src/utils/src/fitlinear.c src/utils/src/disfmt.c src/utils/src/util_ringbuff.c src/utils/src/strutils.c src/utils/src/utils_math.c



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

MP_PROCESSOR_OPTION=32MX350F256L
MP_LINKER_FILE_OPTION=
# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: assembleWithPreprocess
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o: src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S  .generated_files/flags/default/eb34d6cbe46549202195970968142868aecfee96 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.ok ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.err 
	${MP_CC} $(MP_EXTRA_AS_PRE)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1 -c -mprocessor=$(MP_PROCESSOR_OPTION) -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d"  -o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S  -DXPRJ_default=$(CND_CONF)    -Wa,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_AS_POST),-MD="${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.asm.d",--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--gdwarf-2,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1 -mdfp="${DFP_DIR}"
	@${FIXDEPS} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d" "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.asm.d" -t $(SILENT) -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/src/hal/isrWrappers.o: src/hal/isrWrappers.S  .generated_files/flags/default/4808d2c7095a1ef7ab5cced44cc7d695e70547d8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o.d 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o.ok ${OBJECTDIR}/src/hal/isrWrappers.o.err 
	${MP_CC} $(MP_EXTRA_AS_PRE)  -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1 -c -mprocessor=$(MP_PROCESSOR_OPTION) -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MMD -MF "${OBJECTDIR}/src/hal/isrWrappers.o.d"  -o ${OBJECTDIR}/src/hal/isrWrappers.o src/hal/isrWrappers.S  -DXPRJ_default=$(CND_CONF)    -Wa,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_AS_POST),-MD="${OBJECTDIR}/src/hal/isrWrappers.o.asm.d",--defsym=__ICD2RAM=1,--defsym=__MPLAB_DEBUG=1,--gdwarf-2,--defsym=__DEBUG=1,--defsym=__MPLAB_DEBUGGER_PK3=1 -mdfp="${DFP_DIR}"
	@${FIXDEPS} "${OBJECTDIR}/src/hal/isrWrappers.o.d" "${OBJECTDIR}/src/hal/isrWrappers.o.asm.d" -t $(SILENT) -rsi ${MP_CC_DIR}../ 
	
else
${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o: src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S  .generated_files/flags/default/57e55fbe3fec8575a503def935910f731a3c4906 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.ok ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.err 
	${MP_CC} $(MP_EXTRA_AS_PRE)  -c -mprocessor=$(MP_PROCESSOR_OPTION) -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d"  -o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.S  -DXPRJ_default=$(CND_CONF)    -Wa,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_AS_POST),-MD="${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.asm.d",--gdwarf-2 -mdfp="${DFP_DIR}"
	@${FIXDEPS} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.d" "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port_asm.o.asm.d" -t $(SILENT) -rsi ${MP_CC_DIR}../ 
	
${OBJECTDIR}/src/hal/isrWrappers.o: src/hal/isrWrappers.S  .generated_files/flags/default/462cdd5857407b490facdc85d88a1ed2a187593c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o.d 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o 
	@${RM} ${OBJECTDIR}/src/hal/isrWrappers.o.ok ${OBJECTDIR}/src/hal/isrWrappers.o.err 
	${MP_CC} $(MP_EXTRA_AS_PRE)  -c -mprocessor=$(MP_PROCESSOR_OPTION) -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MMD -MF "${OBJECTDIR}/src/hal/isrWrappers.o.d"  -o ${OBJECTDIR}/src/hal/isrWrappers.o src/hal/isrWrappers.S  -DXPRJ_default=$(CND_CONF)    -Wa,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_AS_POST),-MD="${OBJECTDIR}/src/hal/isrWrappers.o.asm.d",--gdwarf-2 -mdfp="${DFP_DIR}"
	@${FIXDEPS} "${OBJECTDIR}/src/hal/isrWrappers.o.d" "${OBJECTDIR}/src/hal/isrWrappers.o.asm.d" -t $(SILENT) -rsi ${MP_CC_DIR}../ 
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: compile
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/src/drivers/eeprom.o: src/drivers/eeprom.c  .generated_files/flags/default/69723dfdf3c7865cc3144617ff5330a059587da1 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/eeprom.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/eeprom.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/eeprom.o.d" -o ${OBJECTDIR}/src/drivers/eeprom.o src/drivers/eeprom.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/tmp275.o: src/drivers/tmp275.c  .generated_files/flags/default/26f8bd7f51e7fb72559e96160e264e370986707f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/tmp275.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/tmp275.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/tmp275.o.d" -o ${OBJECTDIR}/src/drivers/tmp275.o src/drivers/tmp275.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/dispkyb.o: src/drivers/dispkyb.c  .generated_files/flags/default/77f998584394d6c3304aeba6592125573375af1d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/dispkyb.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/dispkyb.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/dispkyb.o.d" -o ${OBJECTDIR}/src/drivers/dispkyb.o src/drivers/dispkyb.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/usb_uart.o: src/drivers/usb_uart.c  .generated_files/flags/default/459bd72eb3c21af7ba93d216e4b4668991b5868d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/usb_uart.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/usb_uart.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/usb_uart.o.d" -o ${OBJECTDIR}/src/drivers/usb_uart.o src/drivers/usb_uart.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/adc.o: src/drivers/adc.c  .generated_files/flags/default/8f7b301a3297ca2788b7a5690d7791767f418708 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/adc.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/adc.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/adc.o.d" -o ${OBJECTDIR}/src/drivers/adc.o src/drivers/adc.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/adcctrl.o: src/drivers/adcctrl.c  .generated_files/flags/default/f362d264dd4036901a448b3d4a54979b439861b3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/adcctrl.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/adcctrl.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/adcctrl.o.d" -o ${OBJECTDIR}/src/drivers/adcctrl.o src/drivers/adcctrl.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/eefs/crc32.o: src/eefs/crc32.c  .generated_files/flags/default/69c2a96d5b89999b9a3d89dc6f27efb51b76cec8 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/eefs" 
	@${RM} ${OBJECTDIR}/src/eefs/crc32.o.d 
	@${RM} ${OBJECTDIR}/src/eefs/crc32.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/eefs/crc32.o.d" -o ${OBJECTDIR}/src/eefs/crc32.o src/eefs/crc32.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/eefs/eefs.o: src/eefs/eefs.c  .generated_files/flags/default/613a11b407a3aff7c7171ad90430dea23bad81d5 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/eefs" 
	@${RM} ${OBJECTDIR}/src/eefs/eefs.o.d 
	@${RM} ${OBJECTDIR}/src/eefs/eefs.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/eefs/eefs.o.d" -o ${OBJECTDIR}/src/eefs/eefs.o src/eefs/eefs.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o: src/FreeRTOS/portable/MemMang/heap_4.c  .generated_files/flags/default/5e8fa456605fe56146c57b118f3433d35b062a77 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MemMang" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o.d" -o ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o src/FreeRTOS/portable/MemMang/heap_4.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o: src/FreeRTOS/portable/MPLAB/PIC32MX/port.c  .generated_files/flags/default/298e4944145b7c12563e6beccf4bee6f3ddd9751 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o.d" -o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o src/FreeRTOS/portable/MPLAB/PIC32MX/port.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/timers.o: src/FreeRTOS/timers.c  .generated_files/flags/default/ce0b73facb90a27e01e98c8b8bab75ee044ce3ad .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/timers.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/timers.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/timers.o.d" -o ${OBJECTDIR}/src/FreeRTOS/timers.o src/FreeRTOS/timers.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/tasks.o: src/FreeRTOS/tasks.c  .generated_files/flags/default/1dbffea0593ed85d2dbe38222160ddd3b72800f3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/tasks.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/tasks.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/tasks.o.d" -o ${OBJECTDIR}/src/FreeRTOS/tasks.o src/FreeRTOS/tasks.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/list.o: src/FreeRTOS/list.c  .generated_files/flags/default/55a1bcd031f85bf141a291228611783f817f8430 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/list.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/list.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/list.o.d" -o ${OBJECTDIR}/src/FreeRTOS/list.o src/FreeRTOS/list.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/event_groups.o: src/FreeRTOS/event_groups.c  .generated_files/flags/default/8cb4b384f28a15184b1987cabcf96e9a6f17d865 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/event_groups.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/event_groups.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/event_groups.o.d" -o ${OBJECTDIR}/src/FreeRTOS/event_groups.o src/FreeRTOS/event_groups.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/croutine.o: src/FreeRTOS/croutine.c  .generated_files/flags/default/67e636e67c8942d5045b7d36f4d46d97c512c378 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/croutine.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/croutine.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/croutine.o.d" -o ${OBJECTDIR}/src/FreeRTOS/croutine.o src/FreeRTOS/croutine.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/queue.o: src/FreeRTOS/queue.c  .generated_files/flags/default/68d3ebc44262eb477949dcad6adccf1a577a26af .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/queue.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/queue.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/queue.o.d" -o ${OBJECTDIR}/src/FreeRTOS/queue.o src/FreeRTOS/queue.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/fuses.o: src/hal/fuses.c  .generated_files/flags/default/de8e1036fd1f80187a8c4b826e9cee10dba405bf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/fuses.o.d 
	@${RM} ${OBJECTDIR}/src/hal/fuses.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/fuses.o.d" -o ${OBJECTDIR}/src/hal/fuses.o src/hal/fuses.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/exceptions.o: src/hal/exceptions.c  .generated_files/flags/default/eac991f268978318039de7e00727483acb712efe .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/exceptions.o.d 
	@${RM} ${OBJECTDIR}/src/hal/exceptions.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/exceptions.o.d" -o ${OBJECTDIR}/src/hal/exceptions.o src/hal/exceptions.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_adc.o: src/hal/hal_adc.c  .generated_files/flags/default/ffdfef557f6d4c2d839004af7a44c69c0434fe1a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_adc.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_adc.o.d" -o ${OBJECTDIR}/src/hal/hal_adc.o src/hal/hal_adc.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_uart.o: src/hal/hal_uart.c  .generated_files/flags/default/3f1330c18289f57d97384c4d3d03301c239a93cc .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_uart.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_uart.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_uart.o.d" -o ${OBJECTDIR}/src/hal/hal_uart.o src/hal/hal_uart.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_i2c.o: src/hal/hal_i2c.c  .generated_files/flags/default/a72d6e5063d74d80b13dcff4709ec73234bb1cef .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_i2c.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_i2c.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_i2c.o.d" -o ${OBJECTDIR}/src/hal/hal_i2c.o src/hal/hal_i2c.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_spi.o: src/hal/hal_spi.c  .generated_files/flags/default/cf7b30ae2dfe84011461118a16f4ba83e4cba0ce .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_spi.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_spi.o.d" -o ${OBJECTDIR}/src/hal/hal_spi.o src/hal/hal_spi.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_timer.o: src/hal/hal_timer.c  .generated_files/flags/default/a0d92f7e0a5083251b73534ed1784822ba43736d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_timer.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_timer.o.d" -o ${OBJECTDIR}/src/hal/hal_timer.o src/hal/hal_timer.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_io.o: src/hal/hal_io.c  .generated_files/flags/default/8650b60988274174d3a39731b7105761c8c75dce .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_io.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_io.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_io.o.d" -o ${OBJECTDIR}/src/hal/hal_io.o src/hal/hal_io.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_sys.o: src/hal/hal_sys.c  .generated_files/flags/default/d87372db2de909fa3acaab22abf6d42f82bedfaf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_sys.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_sys.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_sys.o.d" -o ${OBJECTDIR}/src/hal/hal_sys.o src/hal/hal_sys.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o: src/scpi-parser/libscpi/src/lexer.c  .generated_files/flags/default/ec768d162f3a0d2027d548e573a52b3944f2b1e9 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o src/scpi-parser/libscpi/src/lexer.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o: src/scpi-parser/libscpi/src/error.c  .generated_files/flags/default/38c4f6b3412d789bdbc57ed2ec9e0c38e7fd5b79 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o src/scpi-parser/libscpi/src/error.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o: src/scpi-parser/libscpi/src/fifo.c  .generated_files/flags/default/427a83bd82ef94ac66ca787adab1e4df9c923f09 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o src/scpi-parser/libscpi/src/fifo.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o: src/scpi-parser/libscpi/src/ieee488.c  .generated_files/flags/default/a825bbeb333e7a3d76775903f42cb6736f8d763c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o src/scpi-parser/libscpi/src/ieee488.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o: src/scpi-parser/libscpi/src/minimal.c  .generated_files/flags/default/ba084d9626f27cbce1717831e75b95d010cb8d56 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o src/scpi-parser/libscpi/src/minimal.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o: src/scpi-parser/libscpi/src/parser.c  .generated_files/flags/default/2e7ff594936d0284ec4afba78412ef14a8fee341 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o src/scpi-parser/libscpi/src/parser.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o: src/scpi-parser/libscpi/src/units.c  .generated_files/flags/default/772d1d0e254407040e48d7bd7da47f8e24bee3ae .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o src/scpi-parser/libscpi/src/units.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o: src/scpi-parser/libscpi/src/utils.c  .generated_files/flags/default/3b3350a4fb6056cc0b92c1610af0dd7d773d1416 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o src/scpi-parser/libscpi/src/utils.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/sys/src/system.o: src/sys/src/system.c  .generated_files/flags/default/1ae8b04b861282543b4b51c60032e636e96b9ae1 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/sys/src" 
	@${RM} ${OBJECTDIR}/src/sys/src/system.o.d 
	@${RM} ${OBJECTDIR}/src/sys/src/system.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/sys/src/system.o.d" -o ${OBJECTDIR}/src/sys/src/system.o src/sys/src/system.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/sys/src/settings.o: src/sys/src/settings.c  .generated_files/flags/default/e96f6f3a71c93a995bb3ccae8585f9f50e5f3dd4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/sys/src" 
	@${RM} ${OBJECTDIR}/src/sys/src/settings.o.d 
	@${RM} ${OBJECTDIR}/src/sys/src/settings.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/sys/src/settings.o.d" -o ${OBJECTDIR}/src/sys/src/settings.o src/sys/src/settings.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_calibration.o: src/tasks/task_calibration.c  .generated_files/flags/default/91ca1a6dcaaec62a9569737098f6dca619d02523 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_calibration.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_calibration.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_calibration.o.d" -o ${OBJECTDIR}/src/tasks/task_calibration.o src/tasks/task_calibration.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_multimeter.o: src/tasks/task_multimeter.c  .generated_files/flags/default/ae804ff9e7f4b6d4ef67733c3a375450f51b4c7f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_multimeter.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_multimeter.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_multimeter.o.d" -o ${OBJECTDIR}/src/tasks/task_multimeter.o src/tasks/task_multimeter.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/main.o: src/tasks/main.c  .generated_files/flags/default/45f210d24928849822dcf436edb6f4b05e43159a .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/main.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/main.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/main.o.d" -o ${OBJECTDIR}/src/tasks/main.o src/tasks/main.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/tskmgr.o: src/tasks/tskmgr.c  .generated_files/flags/default/c8e0ecbc7193911a9215e4ca490ad8302eb26e8c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/tskmgr.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/tskmgr.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/tskmgr.o.d" -o ${OBJECTDIR}/src/tasks/tskmgr.o src/tasks/tskmgr.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_scpi.o: src/tasks/task_scpi.c  .generated_files/flags/default/845801d676eaff1942981d8ab20d54edca2e33ca .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_scpi.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_scpi.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_scpi.o.d" -o ${OBJECTDIR}/src/tasks/task_scpi.o src/tasks/task_scpi.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o: src/utils/fcvt-1.1/fcvt.c  .generated_files/flags/default/a0ad9510c403b3b8bdc9a6378ec39161c3412d47 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/fcvt-1.1" 
	@${RM} ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o.d 
	@${RM} ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o.d" -o ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o src/utils/fcvt-1.1/fcvt.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/diag.o: src/utils/src/diag.c  .generated_files/flags/default/99c8514de8322f85e807b76e936402e569d71b38 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/diag.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/diag.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/diag.o.d" -o ${OBJECTDIR}/src/utils/src/diag.o src/utils/src/diag.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/fitlinear.o: src/utils/src/fitlinear.c  .generated_files/flags/default/772c1de48fcdab4fd1c6890deeadffd324107e27 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/fitlinear.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/fitlinear.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/fitlinear.o.d" -o ${OBJECTDIR}/src/utils/src/fitlinear.o src/utils/src/fitlinear.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/disfmt.o: src/utils/src/disfmt.c  .generated_files/flags/default/61483bbce39c15208308fa3d051ada9041e779cf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/disfmt.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/disfmt.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/disfmt.o.d" -o ${OBJECTDIR}/src/utils/src/disfmt.o src/utils/src/disfmt.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/util_ringbuff.o: src/utils/src/util_ringbuff.c  .generated_files/flags/default/4d1083644dcdefb5dfdec2500941628faac9021f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/util_ringbuff.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/util_ringbuff.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/util_ringbuff.o.d" -o ${OBJECTDIR}/src/utils/src/util_ringbuff.o src/utils/src/util_ringbuff.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/strutils.o: src/utils/src/strutils.c  .generated_files/flags/default/3d61c4a3c16297ea31b7772be6600d3d2bd67049 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/strutils.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/strutils.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/strutils.o.d" -o ${OBJECTDIR}/src/utils/src/strutils.o src/utils/src/strutils.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/utils_math.o: src/utils/src/utils_math.c  .generated_files/flags/default/f0d1862a07cb8434596b451a58f73e81590b6636 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/utils_math.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/utils_math.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE) -g -D__DEBUG -D__MPLAB_DEBUGGER_PK3=1  -fframe-base-loclist  -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/utils_math.o.d" -o ${OBJECTDIR}/src/utils/src/utils_math.o src/utils/src/utils_math.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
else
${OBJECTDIR}/src/drivers/eeprom.o: src/drivers/eeprom.c  .generated_files/flags/default/1d284bc7e8c9b1a2b1238fe2a3aeef988b28e15e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/eeprom.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/eeprom.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/eeprom.o.d" -o ${OBJECTDIR}/src/drivers/eeprom.o src/drivers/eeprom.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/tmp275.o: src/drivers/tmp275.c  .generated_files/flags/default/90f49334059dea0bcc8b9128436ef4758d5f0d9c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/tmp275.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/tmp275.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/tmp275.o.d" -o ${OBJECTDIR}/src/drivers/tmp275.o src/drivers/tmp275.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/dispkyb.o: src/drivers/dispkyb.c  .generated_files/flags/default/47239a7279215a20d115e3a2c6928a1aa29e2c03 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/dispkyb.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/dispkyb.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/dispkyb.o.d" -o ${OBJECTDIR}/src/drivers/dispkyb.o src/drivers/dispkyb.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/usb_uart.o: src/drivers/usb_uart.c  .generated_files/flags/default/807c469a3074f00d77b37383fc1f4d4280bbeaec .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/usb_uart.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/usb_uart.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/usb_uart.o.d" -o ${OBJECTDIR}/src/drivers/usb_uart.o src/drivers/usb_uart.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/adc.o: src/drivers/adc.c  .generated_files/flags/default/f1dd58a12847cd8b5459ab9c18eec38c70c49d49 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/adc.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/adc.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/adc.o.d" -o ${OBJECTDIR}/src/drivers/adc.o src/drivers/adc.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/drivers/adcctrl.o: src/drivers/adcctrl.c  .generated_files/flags/default/bad4ac6c9de361050b704eb7330079e1837c989 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/drivers" 
	@${RM} ${OBJECTDIR}/src/drivers/adcctrl.o.d 
	@${RM} ${OBJECTDIR}/src/drivers/adcctrl.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/drivers/adcctrl.o.d" -o ${OBJECTDIR}/src/drivers/adcctrl.o src/drivers/adcctrl.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/eefs/crc32.o: src/eefs/crc32.c  .generated_files/flags/default/9af76f07634d92fff83a2c3453daed793b377608 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/eefs" 
	@${RM} ${OBJECTDIR}/src/eefs/crc32.o.d 
	@${RM} ${OBJECTDIR}/src/eefs/crc32.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/eefs/crc32.o.d" -o ${OBJECTDIR}/src/eefs/crc32.o src/eefs/crc32.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/eefs/eefs.o: src/eefs/eefs.c  .generated_files/flags/default/7bc94938702a4cdfe93e025648c34b372d8f8722 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/eefs" 
	@${RM} ${OBJECTDIR}/src/eefs/eefs.o.d 
	@${RM} ${OBJECTDIR}/src/eefs/eefs.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/eefs/eefs.o.d" -o ${OBJECTDIR}/src/eefs/eefs.o src/eefs/eefs.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o: src/FreeRTOS/portable/MemMang/heap_4.c  .generated_files/flags/default/3945e82c6fc03329392772ed0cdda7afb864fd70 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MemMang" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o.d" -o ${OBJECTDIR}/src/FreeRTOS/portable/MemMang/heap_4.o src/FreeRTOS/portable/MemMang/heap_4.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o: src/FreeRTOS/portable/MPLAB/PIC32MX/port.c  .generated_files/flags/default/2cb91cef9a98b52624acdaebe2b39cebe44fde3b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o.d" -o ${OBJECTDIR}/src/FreeRTOS/portable/MPLAB/PIC32MX/port.o src/FreeRTOS/portable/MPLAB/PIC32MX/port.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/timers.o: src/FreeRTOS/timers.c  .generated_files/flags/default/ac62ffc59d9179512688b31937e41a8d88c4c386 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/timers.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/timers.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/timers.o.d" -o ${OBJECTDIR}/src/FreeRTOS/timers.o src/FreeRTOS/timers.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/tasks.o: src/FreeRTOS/tasks.c  .generated_files/flags/default/1f8b5983a6ea094d5c894f98667573ec05816935 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/tasks.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/tasks.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/tasks.o.d" -o ${OBJECTDIR}/src/FreeRTOS/tasks.o src/FreeRTOS/tasks.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/list.o: src/FreeRTOS/list.c  .generated_files/flags/default/9606983f2901fe87c6de264d45aef54e9f714028 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/list.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/list.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/list.o.d" -o ${OBJECTDIR}/src/FreeRTOS/list.o src/FreeRTOS/list.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/event_groups.o: src/FreeRTOS/event_groups.c  .generated_files/flags/default/498f63730ea73a5864641c63076efec136755f68 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/event_groups.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/event_groups.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/event_groups.o.d" -o ${OBJECTDIR}/src/FreeRTOS/event_groups.o src/FreeRTOS/event_groups.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/croutine.o: src/FreeRTOS/croutine.c  .generated_files/flags/default/a979b1cc0c79cbaef0c368d9884ca1a0c3dd1734 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/croutine.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/croutine.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/croutine.o.d" -o ${OBJECTDIR}/src/FreeRTOS/croutine.o src/FreeRTOS/croutine.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/FreeRTOS/queue.o: src/FreeRTOS/queue.c  .generated_files/flags/default/9dba3856faf88a59d1812458bbf040f5a6358a10 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/FreeRTOS" 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/queue.o.d 
	@${RM} ${OBJECTDIR}/src/FreeRTOS/queue.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/FreeRTOS/queue.o.d" -o ${OBJECTDIR}/src/FreeRTOS/queue.o src/FreeRTOS/queue.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/fuses.o: src/hal/fuses.c  .generated_files/flags/default/2524334224957a80e81c715d5910efdce5090a3b .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/fuses.o.d 
	@${RM} ${OBJECTDIR}/src/hal/fuses.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/fuses.o.d" -o ${OBJECTDIR}/src/hal/fuses.o src/hal/fuses.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/exceptions.o: src/hal/exceptions.c  .generated_files/flags/default/6b49342fcabb6d7c06ec45d591db2f7c47c65ba2 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/exceptions.o.d 
	@${RM} ${OBJECTDIR}/src/hal/exceptions.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/exceptions.o.d" -o ${OBJECTDIR}/src/hal/exceptions.o src/hal/exceptions.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_adc.o: src/hal/hal_adc.c  .generated_files/flags/default/22774388ea7c5be925f96e10fe10325098e50378 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_adc.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_adc.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_adc.o.d" -o ${OBJECTDIR}/src/hal/hal_adc.o src/hal/hal_adc.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_uart.o: src/hal/hal_uart.c  .generated_files/flags/default/ca4ba5eea32972080ced5933716dbd524537b381 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_uart.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_uart.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_uart.o.d" -o ${OBJECTDIR}/src/hal/hal_uart.o src/hal/hal_uart.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_i2c.o: src/hal/hal_i2c.c  .generated_files/flags/default/270666666e20d39fa29ac99d6038b9c41ea20214 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_i2c.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_i2c.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_i2c.o.d" -o ${OBJECTDIR}/src/hal/hal_i2c.o src/hal/hal_i2c.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_spi.o: src/hal/hal_spi.c  .generated_files/flags/default/487d8b1eabcb3babc06369017ebc6aad14f5bdbf .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_spi.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_spi.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_spi.o.d" -o ${OBJECTDIR}/src/hal/hal_spi.o src/hal/hal_spi.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_timer.o: src/hal/hal_timer.c  .generated_files/flags/default/9314a56b0f11789aa0c09d15f95812dfd7b6edcd .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_timer.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_timer.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_timer.o.d" -o ${OBJECTDIR}/src/hal/hal_timer.o src/hal/hal_timer.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_io.o: src/hal/hal_io.c  .generated_files/flags/default/f69bb9a5f9b757420a5bfdea341a6244395ee973 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_io.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_io.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_io.o.d" -o ${OBJECTDIR}/src/hal/hal_io.o src/hal/hal_io.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/hal/hal_sys.o: src/hal/hal_sys.c  .generated_files/flags/default/d9668a0d145734d41648dc02b20daefb81d6ae98 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/hal" 
	@${RM} ${OBJECTDIR}/src/hal/hal_sys.o.d 
	@${RM} ${OBJECTDIR}/src/hal/hal_sys.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/hal/hal_sys.o.d" -o ${OBJECTDIR}/src/hal/hal_sys.o src/hal/hal_sys.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o: src/scpi-parser/libscpi/src/lexer.c  .generated_files/flags/default/2a350d948530c36777d291ae7fa8a978d94ea747 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/lexer.o src/scpi-parser/libscpi/src/lexer.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o: src/scpi-parser/libscpi/src/error.c  .generated_files/flags/default/329aca10c45fa718c3f46e598aa4e16e8a8ad497 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/error.o src/scpi-parser/libscpi/src/error.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o: src/scpi-parser/libscpi/src/fifo.c  .generated_files/flags/default/b40174a8b6ed8e883b4a853e6d49c52e2769c4a4 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/fifo.o src/scpi-parser/libscpi/src/fifo.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o: src/scpi-parser/libscpi/src/ieee488.c  .generated_files/flags/default/ac44acefc52ea84488e06741f117b2b33f41c8b6 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/ieee488.o src/scpi-parser/libscpi/src/ieee488.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o: src/scpi-parser/libscpi/src/minimal.c  .generated_files/flags/default/17ed6e10dca3fe44cd0bc146bf4ce15bae9b1aed .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/minimal.o src/scpi-parser/libscpi/src/minimal.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o: src/scpi-parser/libscpi/src/parser.c  .generated_files/flags/default/8cb075225184ec6d2935f9014298746c4eb0264 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/parser.o src/scpi-parser/libscpi/src/parser.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o: src/scpi-parser/libscpi/src/units.c  .generated_files/flags/default/f7b16abe8cbbbb026017166ce9897ec4aa4aab1f .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/units.o src/scpi-parser/libscpi/src/units.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o: src/scpi-parser/libscpi/src/utils.c  .generated_files/flags/default/54710607ce399686603e3f36f102064102ba1715 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/scpi-parser/libscpi/src" 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o.d 
	@${RM} ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o.d" -o ${OBJECTDIR}/src/scpi-parser/libscpi/src/utils.o src/scpi-parser/libscpi/src/utils.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/sys/src/system.o: src/sys/src/system.c  .generated_files/flags/default/b533738848e78a53a59f07bd601d3f411895b3d3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/sys/src" 
	@${RM} ${OBJECTDIR}/src/sys/src/system.o.d 
	@${RM} ${OBJECTDIR}/src/sys/src/system.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/sys/src/system.o.d" -o ${OBJECTDIR}/src/sys/src/system.o src/sys/src/system.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/sys/src/settings.o: src/sys/src/settings.c  .generated_files/flags/default/c33547366d73151a250baac779eb9e3caffea648 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/sys/src" 
	@${RM} ${OBJECTDIR}/src/sys/src/settings.o.d 
	@${RM} ${OBJECTDIR}/src/sys/src/settings.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/sys/src/settings.o.d" -o ${OBJECTDIR}/src/sys/src/settings.o src/sys/src/settings.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_calibration.o: src/tasks/task_calibration.c  .generated_files/flags/default/32b8610e8f78cefdcdf0c63a1071593b5b6ca82d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_calibration.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_calibration.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_calibration.o.d" -o ${OBJECTDIR}/src/tasks/task_calibration.o src/tasks/task_calibration.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_multimeter.o: src/tasks/task_multimeter.c  .generated_files/flags/default/707559b6a13a29d0f53c8c3d2997c08703a37cb3 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_multimeter.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_multimeter.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_multimeter.o.d" -o ${OBJECTDIR}/src/tasks/task_multimeter.o src/tasks/task_multimeter.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/main.o: src/tasks/main.c  .generated_files/flags/default/89288dc1a208f7acb6afdb8bb421e8b0f8c74c8e .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/main.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/main.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/main.o.d" -o ${OBJECTDIR}/src/tasks/main.o src/tasks/main.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/tskmgr.o: src/tasks/tskmgr.c  .generated_files/flags/default/a4e2d8094660ee7f1cfcd067e3210e4df6c4d878 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/tskmgr.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/tskmgr.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/tskmgr.o.d" -o ${OBJECTDIR}/src/tasks/tskmgr.o src/tasks/tskmgr.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/tasks/task_scpi.o: src/tasks/task_scpi.c  .generated_files/flags/default/9cc7534404c729b82cce0109d190a9e641e63a32 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/tasks" 
	@${RM} ${OBJECTDIR}/src/tasks/task_scpi.o.d 
	@${RM} ${OBJECTDIR}/src/tasks/task_scpi.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/tasks/task_scpi.o.d" -o ${OBJECTDIR}/src/tasks/task_scpi.o src/tasks/task_scpi.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o: src/utils/fcvt-1.1/fcvt.c  .generated_files/flags/default/ed39e10bc74e50d06883b227f3bd56bd5469243c .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/fcvt-1.1" 
	@${RM} ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o.d 
	@${RM} ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o.d" -o ${OBJECTDIR}/src/utils/fcvt-1.1/fcvt.o src/utils/fcvt-1.1/fcvt.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/diag.o: src/utils/src/diag.c  .generated_files/flags/default/9b7245e8ddd1c88c52e7e3c957a14626cfe44008 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/diag.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/diag.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/diag.o.d" -o ${OBJECTDIR}/src/utils/src/diag.o src/utils/src/diag.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/fitlinear.o: src/utils/src/fitlinear.c  .generated_files/flags/default/648c822a2e11575aa4152dd1e9996bd1be1793d9 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/fitlinear.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/fitlinear.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/fitlinear.o.d" -o ${OBJECTDIR}/src/utils/src/fitlinear.o src/utils/src/fitlinear.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/disfmt.o: src/utils/src/disfmt.c  .generated_files/flags/default/da0221b79ba4aa3acbd9b74cbf21e36870557834 .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/disfmt.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/disfmt.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/disfmt.o.d" -o ${OBJECTDIR}/src/utils/src/disfmt.o src/utils/src/disfmt.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/util_ringbuff.o: src/utils/src/util_ringbuff.c  .generated_files/flags/default/772e43cc669a4bdc5f61e84ee46f454d2ee0a7dc .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/util_ringbuff.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/util_ringbuff.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/util_ringbuff.o.d" -o ${OBJECTDIR}/src/utils/src/util_ringbuff.o src/utils/src/util_ringbuff.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/strutils.o: src/utils/src/strutils.c  .generated_files/flags/default/d0a67766eb0e95c409ac2577aca917e91af213fb .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/strutils.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/strutils.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/strutils.o.d" -o ${OBJECTDIR}/src/utils/src/strutils.o src/utils/src/strutils.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
${OBJECTDIR}/src/utils/src/utils_math.o: src/utils/src/utils_math.c  .generated_files/flags/default/d3b38410037a8cece15ed9fd9c802dd5b343218d .generated_files/flags/default/da39a3ee5e6b4b0d3255bfef95601890afd80709
	@${MKDIR} "${OBJECTDIR}/src/utils/src" 
	@${RM} ${OBJECTDIR}/src/utils/src/utils_math.o.d 
	@${RM} ${OBJECTDIR}/src/utils/src/utils_math.o 
	${MP_CC}  $(MP_EXTRA_CC_PRE)  -g -x c -c -mprocessor=$(MP_PROCESSOR_OPTION)  -fno-common -DNDEBUG -I"src/hal" -I"src/FreeRTOS/include" -I"src/FreeRTOS/portable/MPLAB/PIC32MX" -I"src/sys/include" -I"src/eefs" -I"src/libscpi/inc" -I"src/dmm" -I"src/utils/include" -I"src/drivers" -I"src/scpi-parser/libscpi/inc" -I"/Applications/microchip/xc32/v4.60/pic32-libs/include" -I"third_party/pic32mx-legacy-plib/include" -Wall -MP -MMD -MF "${OBJECTDIR}/src/utils/src/utils_math.o.d" -o ${OBJECTDIR}/src/utils/src/utils_math.o src/utils/src/utils_math.c    -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wno-packed-bitfield-compat -mdfp="${DFP_DIR}"  
	
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: compileCPP
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
else
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE) -g -mdebugger -D__MPLAB_DEBUGGER_PK3=1 -mprocessor=$(MP_PROCESSOR_OPTION) -mips16 -o ${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX} ${OBJECTFILES_QUOTED_IF_SPACED} "third_party/pic32mx-legacy-plib/lib/libmchp_peripheral_32MX350F256L.a"          -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)   -mreserve=data@0x0:0x1FC -mreserve=boot@0x1FC02000:0x1FC02FEF -mreserve=boot@0x1FC02000:0x1FC0275F  -Wl,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_LD_POST)$(MP_LINKER_FILE_OPTION),--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,-D=__DEBUG_D,--defsym=__MPLAB_DEBUGGER_PK3=1,--defsym=_min_heap_size=2000,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-L"third_party/pic32mx-legacy-plib/lib",-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--memorysummary,${DISTDIR}/memoryfile.xml -mdfp="${DFP_DIR}"
	
else
${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	@${MKDIR} ${DISTDIR} 
	${MP_CC} $(MP_EXTRA_LD_PRE)  -mprocessor=$(MP_PROCESSOR_OPTION) -mips16 -o ${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} ${OBJECTFILES_QUOTED_IF_SPACED} "third_party/pic32mx-legacy-plib/lib/libmchp_peripheral_32MX350F256L.a"          -DXPRJ_default=$(CND_CONF)    $(COMPARISON_BUILD)  -Wl,--defsym=__MPLAB_BUILD=1$(MP_EXTRA_LD_POST)$(MP_LINKER_FILE_OPTION),--defsym=_min_heap_size=2000,--gc-sections,--no-code-in-dinit,--no-dinit-in-serial-mem,-L"third_party/pic32mx-legacy-plib/lib",-Map="${DISTDIR}/${PROJECTNAME}.${IMAGE_TYPE}.map",--memorysummary,${DISTDIR}/memoryfile.xml -mdfp="${DFP_DIR}"
	${MP_CC_DIR}/xc32-bin2hex ${DISTDIR}/keithley_199-master.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX} 
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(shell "${PATH_TO_IDE_BIN}"mplabwildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
