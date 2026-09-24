#ifndef SRC_DRIVER_SPI_SPI_H_
#define SRC_DRIVER_SPI_SPI_H_

#include "../../hal/spi/spi.h"

#include <stdint.h>
#include "xparameters.h"

uint8_t SPI_Transfer(SPI_Typedef_t *spi, uint8_t data);

#endif /* SRC_DRIVER_SPI_SPI_H_ */
