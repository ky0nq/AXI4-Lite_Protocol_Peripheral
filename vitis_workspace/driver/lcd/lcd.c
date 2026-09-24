#include "lcd.h"
#include "../../common/delay/delay.h"

void LCD_SendByte(I2C_TypeDef *I2Cx, uint8_t data, uint8_t rs)
{
    uint8_t  high_nibble = (data >> 4) & 0x0F;
    uint8_t  low_nibble  =  data       & 0x0F;
    uint8_t  ctrl_en, ctrl_no_en;
    uint16_t frame;

    if (rs) {
        // Data mode: RS=1, RW=0
        ctrl_en    = LCD_BACKLIGHT | LCD_ENABLE | LCD_RS;
        ctrl_no_en = LCD_BACKLIGHT | LCD_RS;
    } else {
        // Command mode: RS=0, RW=0
        ctrl_en    = LCD_BACKLIGHT | LCD_ENABLE;
        ctrl_no_en = LCD_BACKLIGHT;
    }

    // Build frame for the i2c_demo IP FSM
    // [15:12] = high nibble
    // [11:8]  = low nibble
    // [7:4]   = ctrl with EN=1
    // [3:0]   = ctrl with EN=0
    frame = ((uint16_t)high_nibble << 12) |
            ((uint16_t)low_nibble  <<  8) |
            ((uint16_t)ctrl_en     <<  4) |
            ((uint16_t)ctrl_no_en);

    I2C_LCD_WriteFrame(I2Cx, LCD_I2C_ADDR, frame);
}

// Send command byte (RS=0)
void LCD_Command(I2C_TypeDef *I2Cx, uint8_t cmd)
{
    LCD_SendByte(I2Cx, cmd, 0);
}

// Send data byte (RS=1)
void LCD_Data(I2C_TypeDef *I2Cx, uint8_t data)
{
    LCD_SendByte(I2Cx, data, 1);
}

void LCD_Clear(I2C_TypeDef *I2Cx)
{
    LCD_Command(I2Cx, 0x01);
    delay_ms(5);
}

void LCD_SetCursor(I2C_TypeDef *I2Cx, uint8_t row, uint8_t col)
{
    uint8_t addr = (row == 0) ? (0x80 + col) : (0xC0 + col);
    LCD_Command(I2Cx, addr);
}

void LCD_Print(I2C_TypeDef *I2Cx, const char *str)
{
    while (*str) {
        LCD_Data(I2Cx, (uint8_t)(*str));
        str++;
    }
}

void LCD_PrintSpaces(I2C_TypeDef *I2Cx, uint8_t count)
{
    uint8_t i;
    for (i = 0; i < count; i++) {
        LCD_Data(I2Cx, ' ');
    }
}

void LCD_Init(I2C_TypeDef *I2Cx)
{
    delay_ms(50);

    // HD44780 4-bit init sequence
    LCD_Command(I2Cx, 0x33);
    delay_ms(5);
    LCD_Command(I2Cx, 0x32);
    delay_ms(5);

    // Function set: 4-bit, 2-line, 5x8
    LCD_Command(I2Cx, 0x28);
    delay_ms(3);

    // Display ON, Cursor OFF, Blink OFF
    LCD_Command(I2Cx, 0x0C);
    delay_ms(3);

    // Entry mode: cursor increment, no shift
    LCD_Command(I2Cx, 0x06);
    delay_ms(3);

    LCD_Clear(I2Cx);
}
