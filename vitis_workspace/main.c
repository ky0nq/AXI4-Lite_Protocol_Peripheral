#include "xil_printf.h"
#include "ap/stopwatch/stopwatch.h"
#include "ap/spi/spi.h"
#include "common/delay/delay.h"
#include "common/interrupt/interrupt.h"
#include "driver/button/button.h"
#include "driver/lcd/lcd.h"
#include "hal/timer/timer.h"
#include "hal/uart/uart.h"
#include "hal/i2c/i2c.h"

#include <stdio.h>

int main()
{
    xil_printf(" Stopwatch System ! \r\n");

    StopWatch_Init();
    SPI_Init(SPI0);
    //UART_StartInterrupt(UART0); // using Only I2C System 

    // Init LCD and show initial screen
    LCD_Init(I2C);
    LCD_Clear(I2C);
    LCD_SetCursor(I2C, 0, 0);
    LCD_Print(I2C, "Stopwatch");
    LCD_SetCursor(I2C, 1, 0);
    LCD_Print(I2C, "00:00:00.00     ");

    // Setup timer interrupt: 100MHz/100 = 1MHz, ARR=1000 -> 1ms tick
    SetupInterruptsystem();
    TMR_SetPSC(TMR0, 100 - 1);
    TMR_SetARR(TMR0, 1000 - 1);
    TMR_StartInterrupt(TMR0);
    TMR_StartTimer(TMR0);

    while (1)
    {
        Stopwatch_Execute();
        
        // Trigger SPI (EEPROM save/load) only when left button held/released
        if (Button_GetState(&hbtnLeft) == ACT_RELEASED) {
            SPI_Execute();
        }
    }

    return 0;
}

void UART_Print(UART_TypeDef_t *uart, const char *str)
{
    while (*str) {
        UART_Transmit(uart, (uint8_t)(*str));
        str++;
    }
}
