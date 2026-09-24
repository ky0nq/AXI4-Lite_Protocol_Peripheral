#include "i2c.h"
#include "../../common/delay/delay.h"

void I2C_LCD_WriteFrame(I2C_TypeDef *I2Cx, uint8_t i2c_addr, uint16_t frame)
{
    // [22:16] = 7-bit slave address, [15:0] = LCD frame
    I2Cx->ADDR_DATA = (((uint32_t)i2c_addr & 0x7F) << 16) |
                      ((uint32_t)frame & 0xFFFF);
                      
    I2Cx->CTRL = 0x01;
    delay_us(3000);
}
