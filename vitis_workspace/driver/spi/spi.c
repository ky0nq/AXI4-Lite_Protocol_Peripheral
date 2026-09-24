#include "spi.h"
#include "xil_exception.h"

uint8_t SPI_Transfer(SPI_Typedef_t *spi, uint8_t data) {
	SPI_WriteTDR(spi, data);        // tdr write
    SPI_Start(spi);                 // start
    while(SPI_ReadSR(spi) & 0x01);  // busy
    return SPI_ReadRDR(spi);        // read
}
