#ifndef SRC_DRIVER_LCD_LCD_H_
#define SRC_DRIVER_LCD_LCD_H_

#include <stdint.h>
#include "../../hal/i2c/i2c.h"

#define LCD_I2C_ADDR    0x27

// PCF8574 port bit definitions
#define LCD_BACKLIGHT   0x08
#define LCD_ENABLE      0x04
#define LCD_RW          0x02
#define LCD_RS          0x01

void LCD_SendByte(I2C_TypeDef *I2Cx, uint8_t data, uint8_t rs);
void LCD_Command(I2C_TypeDef *I2Cx, uint8_t cmd);
void LCD_Data(I2C_TypeDef *I2Cx, uint8_t data);
void LCD_Init(I2C_TypeDef *I2Cx);
void LCD_Clear(I2C_TypeDef *I2Cx);
void LCD_SetCursor(I2C_TypeDef *I2Cx, uint8_t row, uint8_t col);
void LCD_Print(I2C_TypeDef *I2Cx, const char *str);
void LCD_PrintSpaces(I2C_TypeDef *I2Cx, uint8_t count);

#endif /* SRC_DRIVER_LCD_LCD_H_ */
