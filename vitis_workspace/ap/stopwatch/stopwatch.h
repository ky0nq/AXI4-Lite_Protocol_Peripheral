#ifndef SRC_AP_STOPWATCH_H_
#define SRC_AP_STOPWATCH_H_

#include "../../driver/button/button.h"
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"
#include "../../driver/lcd/lcd.h"
#include "../../hal/i2c/i2c.h"
#include "../../hal/uart/uart.h"

typedef struct {
    uint8_t hour;
    uint8_t min;
    uint8_t sec;
    uint8_t ms;
} stopwatch_t;

extern stopwatch_t stopwatchTimeData;

typedef enum {
    STOP = 0,
    RUN,
    CLEAR
} stopwatch_e;

void StopWatch_Init();
void Stopwatch_Execute();
void Stopwatch_RunTime();
void Stopwatch_ControlState();
void Stopwatch_ControlLed();
void Stopwatch_DispWatch();
void Stopwatch_Inctime();
void Stopwatch_Cleartime();
void Stopwatch_LCD_Update(void);
void Stopwatch_PrintTime(void);

#endif /* SRC_AP_STOPWATCH_H_ */
