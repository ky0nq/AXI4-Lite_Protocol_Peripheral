#ifndef SRC_COMMON_DELAY_DELAY_H_
#define SRC_COMMON_DELAY_DELAY_H_

#include "sleep.h"
#include <stdint.h>

uint32_t millis(); 	// arduino language
void incTick(); 	// stm32 language
void delay_sec(uint32_t seconds);
void delay_ms(uint32_t msec);
void delay_us(uint32_t usec);

#endif /* SRC_COMMON_DELAY_DELAY_H_ */
