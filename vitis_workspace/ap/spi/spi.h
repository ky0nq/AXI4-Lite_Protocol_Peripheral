#ifndef SRC_AP_SPI_SPI_H_
#define SRC_AP_SPI_SPI_H_

#include "../stopwatch/stopwatch.h"
#include "../../driver/spi/spi.h"
#include "../../hal/gpio/gpio.h"

#include <stdint.h>
#include "xparameters.h"

void SPI_WriteCmd(uint8_t addr, uint8_t wdata);
uint8_t SPI_ReadCmd(uint8_t addr);
void SPI_Execute(void);

#endif /* SRC_AP_SPI_SPI_H_ */
