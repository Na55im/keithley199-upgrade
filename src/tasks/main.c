/*
 * Display bring-up: FreeRTOS + display_kyb → "HELLO" on segment display.
 *
 * The Core Timer ISR (CT_wrapper, vector 0) multiplexes all 11 digit
 * positions at ~90 Hz frame rate (1 ms per digit slot).
 */
#include <FreeRTOS.h>
#include <task.h>
#include <dispkyb.h>
#include <hal_sys.h>

static void display_app_task(void *pvParameters)
{
	(void)pvParameters;

	display_kyb_init();

	display_clear();
	display_puts("0123456789");

	for (;;) {
		vTaskDelay((TickType_t)(1000 / portTICK_PERIOD_MS));
	}
}

int main(void)
{
	hal_sys_init();

	if (xTaskCreate(display_app_task, "DISP", (unsigned short)768, NULL,
			(tskIDLE_PRIORITY + 2), NULL) != pdPASS) {
		while (1) {
		}
	}

	vTaskStartScheduler();

	while (1) {
	}
}

void vAssertCalled(const char *fileName, unsigned long lineNo)
{
	(void)fileName;
	(void)lineNo;
	while (1)
		;
}

void vApplicationIdleHook(void) {}

void vApplicationStackOverflowHook(void *pxTask, signed char *pcTaskName)
{
	(void)pxTask;
	(void)pcTaskName;
	while (1)
		;
}

void vApplicationMallocFailedHook(void)
{
	while (1)
		;
}
