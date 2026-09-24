#include "uart.h"

void UART_StartInterrupt(UART_TypeDef_t *uart)
{
	uart->CR |= 1 << 0;
}

void UART_StopInterrupt(UART_TypeDef_t *uart)
{
	uart->CR &= ~(1 << 0);
}


void UART_Transmit(UART_TypeDef_t *uart, uint8_t data)
{
	while (!(uart->SR & (1<<0)));
	uart->TDR =(uint32_t)data;
}

uint8_t UART_Receive(UART_TypeDef_t *uart)
{
	while (!(uart->SR & (1<<1)));
	return (uint8_t)(uart->RDR);
}

uint8_t UART_RxAvailable(UART_TypeDef_t *uart)
{
	return uart->SR & (1<<1);
}
