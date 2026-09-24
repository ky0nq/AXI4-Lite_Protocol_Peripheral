#ifndef SRC_DRIVER_I2C_I2C_H_
#define SRC_DRIVER_I2C_I2C_H_

#include <stdint.h>
#include "xparameters.h"

#define I2C_MASTER_BASE_ADDR XPAR_I2C_0_S00_AXI_BASEADDR
#define I2C ((I2C_TypeDef *)I2C_MASTER_BASE_ADDR)

#define LCD_SLAVE_ADDR 0x27

typedef struct
{
    volatile uint32_t CTRL;       // 0x00
    volatile uint32_t ADDR_DATA;  // 0x04
    volatile uint32_t RXDATA;     // 0x08
    volatile uint32_t STATUS;     // 0x0C
} I2C_TypeDef;

void I2C_LCD_WriteFrame(I2C_TypeDef *I2Cx, uint8_t i2c_addr, uint16_t frame);

#endif
