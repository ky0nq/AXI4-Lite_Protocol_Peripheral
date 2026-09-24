#include "spi.h"

void SPI_WriteTDR(SPI_Typedef_t *spi, uint8_t data) {
	spi -> TDR = data;
}

uint32_t SPI_ReadSR(SPI_Typedef_t *spi) {
	return spi -> SR;
}

uint8_t SPI_ReadRDR(SPI_Typedef_t *spi) {
	return spi -> RDR;
}

void SPI_Init(SPI_Typedef_t *spi)
{
    spi->CR = (49 << 3);
}

void SPI_Start(SPI_Typedef_t *spi)
{
    spi->CR = (49 << 3) | 0x01;
}
