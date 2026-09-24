#include "spi.h"

void SPI_WriteCmd(uint8_t addr, uint8_t wdata) {
	SPI_Transfer(SPI0, (0b0000101 << 1) | 1);
	SPI_Transfer(SPI0, addr & 0x03);
	SPI_Transfer(SPI0, wdata);
}

uint8_t SPI_ReadCmd(uint8_t addr) {
	SPI_Transfer(SPI0, (0b0000101 << 1) | 0);
	SPI_Transfer(SPI0, addr & 0x03);
	return SPI_Transfer(SPI0, 0x00);
}

void SPI_Execute(void) {
	uint8_t wr = GPIO_ReadPort(GPIOE) & 0x01;   // SW[0]
	    if (wr) {
	        // write
	        SPI_WriteCmd(0x00, stopwatchTimeData.ms);
	        SPI_WriteCmd(0x01, stopwatchTimeData.sec);
	        SPI_WriteCmd(0x02, stopwatchTimeData.min);
	        SPI_WriteCmd(0x03, stopwatchTimeData.hour);
	    } else {
	        // read
	        uint8_t r_msec = SPI_ReadCmd(0x00);
	        uint8_t r_sec  = SPI_ReadCmd(0x01);
	        uint8_t r_min  = SPI_ReadCmd(0x02);
	        uint8_t r_hour = SPI_ReadCmd(0x03);
	        xil_printf("%02d:%02d:%02d.%02d\r\n", r_hour, r_min, r_sec, r_msec);
	    }
}
