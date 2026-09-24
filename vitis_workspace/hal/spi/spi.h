// spi.c_HAL

#ifndef SRC_HAL_SPI_SPI_H_
#define SRC_HAL_SPI_SPI_H_

#include <stdint.h>
#include "xparameters.h"

typedef struct {

	uint32_t SR;
	uint32_t TDR;
	uint32_t RDR;
	uint32_t CR;

}SPI_Typedef_t;

#define SPI_BASEADDR XPAR_SPI_MASTER_0_S00_AXI_BASEADDR
#define SPI0 ((SPI_Typedef_t *)SPI_BASEADDR)

void SPI_WriteTDR(SPI_Typedef_t *spi, uint8_t data);
uint32_t SPI_ReadSR(SPI_Typedef_t *spi);
uint8_t SPI_ReadRDR(SPI_Typedef_t *spi);
void SPI_SetMode(SPI_Typedef_t *spi, uint32_t mode);
void SPI_Start(SPI_Typedef_t *spi);
void SPI_Init(SPI_Typedef_t *spi);

#endif /* SRC_HAL_SPI_SPI_H_ */
