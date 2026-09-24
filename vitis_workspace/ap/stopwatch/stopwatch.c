#include "stopwatch.h"
#include <stdio.h>
#include "../../common/interrupt/interrupt.h"
#include "../../hal/i2c/i2c.h"
#include "../../hal/uart/uart.h"

stopwatch_e stopwatchState;
uint32_t stopwatchLed;
uint32_t stopwatchStateLed;
uint32_t counter;
stopwatch_t stopwatchTimeData;

uint8_t rx_data;

void StopWatch_Init()
{
    LED_Init();
    FND_Init();
    Button_Init();
    GPIO_SetMode(GPIOE, 0x00);

    stopwatchState = STOP;
    stopwatchLed = 0x01;
    stopwatchStateLed = 0;
    rx_data = 0;

    stopwatchTimeData.hour = 0;
    stopwatchTimeData.min = 0;
    stopwatchTimeData.sec = 0;
    stopwatchTimeData.ms = 0;
}

void Stopwatch_Execute()
{
    Stopwatch_ControlState();
    Stopwatch_DispWatch();
    Stopwatch_RunTime();

    // Update LCD only when flagged
    if(g_lcd_update_flag) 
    {
        g_lcd_update_flag = 0;

        Stopwatch_LCD_Update();
    }
}

void Stopwatch_DispWatch()
{
    if (stopwatchTimeData.ms < 50) {
        FND_SetDP(FND_DIGIT_2, FND_DP_ON);
    }
    else {
        FND_SetDP(FND_DIGIT_2, FND_DP_OFF);
    }

    FND_SetNum((stopwatchTimeData.min * 100) + stopwatchTimeData.sec);
    Stopwatch_ControlLed();
}

// Stopwatch FSM: STOP -> RUN -> STOP, or STOP -> CLEAR -> STOP
void Stopwatch_ControlState()
{
    switch(stopwatchState) {
    case STOP:
        if (Button_GetState(&hbtnRunStop) == ACT_PUSHED) {
            stopwatchState = RUN;
        }
        else if (Button_GetState(&hbtnClear) == ACT_PUSHED) {
            stopwatchState = CLEAR;
        }
        break;

    case RUN:
        if (Button_GetState(&hbtnRunStop) == ACT_PUSHED) {
            stopwatchState = STOP;
        }
        break;

    case CLEAR:
        stopwatchState = STOP;
        Stopwatch_Cleartime();
        break;

    default:
        stopwatchState = STOP;
        break;
    }

}

void Stopwatch_RunTime()
{
    static uint32_t prevTime = 0;
    uint32_t curTime = millis();

    if (curTime - prevTime < 10) return;
    prevTime = curTime;

    if (stopwatchState == RUN) {
        counter++;
        Stopwatch_Inctime();
    }
}

void Stopwatch_Cleartime()
{
    stopwatchTimeData.hour = 0;
    stopwatchTimeData.min = 0;
    stopwatchTimeData.sec = 0;
    stopwatchTimeData.ms = 0;
}

// Carry-based time increment: ms -> sec -> min -> hour
void Stopwatch_Inctime()
{
    if (stopwatchTimeData.ms == 99) {
        stopwatchTimeData.ms = 0;
    }
    else {
        stopwatchTimeData.ms++;
        return;
    }

    if (stopwatchTimeData.sec == 59) {
        stopwatchTimeData.sec = 0;
    }
    else {
        stopwatchTimeData.sec++;
        return;
    }

    if (stopwatchTimeData.min == 59) {
        stopwatchTimeData.min = 0;
    }
    else {
        stopwatchTimeData.min++;
        return;
    }

    if (stopwatchTimeData.hour == 23) {
        stopwatchTimeData.hour = 0;
    }
    else {
        stopwatchTimeData.hour++;
        return;
    }
}

void Stopwatch_RunLed()
{
    static uint32_t prevTime = 0;
    uint32_t curTime = millis();

    if (curTime - prevTime < 100) return;
    prevTime = curTime;

    stopwatchLed = (stopwatchLed << 1) | (stopwatchLed >> 7);
    LED_WritePort8(LED_LOW_GPIO, stopwatchLed);
}

void Stopwatch_ClearLed()
{
    stopwatchLed = 0x01;
    LED_WritePort8(LED_LOW_GPIO, stopwatchLed);
}

// Dispatch LED behavior based on Stopwatch state
void Stopwatch_ControlLed()
{
    switch(stopwatchState) {
    case STOP:
        break;
    case RUN:
        Stopwatch_RunLed();
        break;
    case CLEAR:
        Stopwatch_ClearLed();
        break;
    default:
        stopwatchState = STOP;
        break;
    }
}

// Format time string and write to I2C LCD
void Stopwatch_LCD_Update(void)
{
    char lcd_buf[16];

    snprintf(lcd_buf, sizeof(lcd_buf), "%02d:%02d:%02d.%02d",
             stopwatchTimeData.hour,
             stopwatchTimeData.min,
             stopwatchTimeData.sec,
             stopwatchTimeData.ms);

    LCD_SetCursor(I2C, 1, 0);
    LCD_Print(I2C, lcd_buf);
}

