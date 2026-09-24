#include "button.h"

hbutton hbtnRunStop, hbtnClear;
hbutton hbtnLeft, hbtnRight;

void Button_SetInit(hbutton *hbtn, GPIO_TypeDef *GPIOx, uint32_t gpio_pin)
{
	hbtn->GPIOx = GPIOx;
	hbtn->gpio_pin = gpio_pin;
	hbtn->prevState = RELEASED;
	hbtn->lastChangeTime = 0;
}

void Button_Init()
{
	uint32_t btnPort = GPIO_GetCR(GPIOB);
	btnPort &= ~ (1 << 4 | 1 << 5 | 1 << 6 | 1 << 7);
	GPIO_SetMode(GPIOB, btnPort);
	Button_SetInit(&hbtnRunStop, GPIOB, GPIO_PIN_4);
	Button_SetInit(&hbtnClear, GPIOB, GPIO_PIN_5);
	Button_SetInit(&hbtnLeft, GPIOB, GPIO_PIN_6);
	Button_SetInit(&hbtnRight, GPIOB, GPIO_PIN_7);
}

button_status_e Button_GetState(hbutton *hbtn)
{
	button_state_e curState = GPIO_ReadPin(hbtn->GPIOx, hbtn->gpio_pin) ? PUSHED : RELEASED;
	uint32_t curTime = millis();

	if (curTime - hbtn->lastChangeTime < 5)
	{
		return NO_ACT;
	}

	// Rising edge: RELEASED -> PUSHED
	if (hbtn->prevState == RELEASED && curState == PUSHED)
	{
		hbtn->prevState = curState;
		hbtn->lastChangeTime = curTime;
		return ACT_PUSHED;
	}
	// Falling edge: PUSHED -> RELEASED
	else if (hbtn->prevState == PUSHED && curState == RELEASED)
	{
		hbtn->prevState = curState;
		hbtn->lastChangeTime = curTime;
		return ACT_RELEASED;
	}

	return NO_ACT;
}
