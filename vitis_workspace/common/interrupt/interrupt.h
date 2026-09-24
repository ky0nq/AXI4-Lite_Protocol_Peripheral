
#ifndef SRC_COMMON_INTERRUPT_INTERRUPT_H_
#define SRC_COMMON_INTERRUPT_INTERRUPT_H_

#include "xparameters.h"
#include "xintc.h"
#include "xil_exception.h"
#include <stdint.h>

#define INTC_DEV_ID   XPAR_INTC_0_DEVICE_ID
#define TMR_VEC_ID    XPAR_INTC_0_TIMER_0_VEC_ID
#define UART_VEC_ID   XPAR_INTC_0_UART_0_VEC_ID

extern volatile uint8_t g_lcd_update_flag;
extern volatile uint8_t g_btn_left_flag;
extern volatile uint8_t g_btn_right_flag;

void TMR_ISR(void *CallbackRef);
void UART_ISR(void *CallbackRef);
int  SetupInterruptsystem(void);

#endif
