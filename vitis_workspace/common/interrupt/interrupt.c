#include "interrupt.h"
#include "../delay/delay.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"
#include "../../hal/uart/uart.h"
#include "../../hal/gpio/gpio.h"

XIntc IntrController;
extern uint8_t rx_data;

volatile uint8_t g_lcd_update_flag  = 0;
volatile uint8_t g_btn_left_flag    = 0;
volatile uint8_t g_btn_right_flag   = 0;

void TMR_ISR(void *CallbackRef)
{
    static uint8_t prev_left  = 0;
    static uint8_t prev_right = 0;
    static uint32_t lcd_cnt = 0;

    uint8_t cur_left  = GPIO_ReadPin(GPIOB, GPIO_PIN_6);
    uint8_t cur_right = GPIO_ReadPin(GPIOB, GPIO_PIN_7);

    if (!prev_left  && cur_left)
        g_btn_left_flag  = 1;
    if (!prev_right && cur_right)
        g_btn_right_flag = 1;

    prev_left  = cur_left;
    prev_right = cur_right;

    FND_Execute();
    incTick();

    // Set LCD update flag periodically instead of every tick
    if (++lcd_cnt >= 500) {
        lcd_cnt = 0;
        g_lcd_update_flag = 1;
    }
}

void UART_ISR(void *CallbackRef)
{
    if (UART_RxAvailable(UART0)) {
        rx_data = (uint8_t)(UART0->RDR);
    }
}

// Register and enable timer/UART interrupt handlers
int SetupInterruptsystem(void)
{
    int status;

    status = XIntc_Initialize(&IntrController, INTC_DEV_ID);
    if (status != XST_SUCCESS) return XST_FAILURE;

    status = XIntc_Connect(&IntrController, TMR_VEC_ID,
                           (XInterruptHandler)TMR_ISR, (void *)0);
    if (status != XST_SUCCESS) return XST_FAILURE;

    status = XIntc_Connect(&IntrController, UART_VEC_ID,
                           (XInterruptHandler)UART_ISR, (void *)0);
    if (status != XST_SUCCESS) return XST_FAILURE;

    status = XIntc_Start(&IntrController, XIN_REAL_MODE);
    if (status != XST_SUCCESS) return XST_FAILURE;

    XIntc_Enable(&IntrController, TMR_VEC_ID);
    XIntc_Enable(&IntrController, UART_VEC_ID);

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
        (Xil_ExceptionHandler)XIntc_InterruptHandler, &IntrController);
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}
