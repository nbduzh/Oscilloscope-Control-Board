
#ifndef __CONFIG_H__
#define __CONFIG_H__

#include "stm32f10x.h"

//#define PERIPH_TO_MEMORY 0
//#define MEMORY_TO_PERIPH 1
//#define MEMORY_TO_MEMORY 2

void GPIO_Config(void);
void USART1_Config(u32 bound);
void I2C_Config(I2C_TypeDef* I2Cx);
void RCC_Config(void);
void SPI_Config(SPI_TypeDef* SPIx);
void TIM_Config(void);
void TIM_Setus(float period);
void EXTI_Config(FunctionalState NewState);
void ADC_Config(void);

//void DMA1_USART_Config(u8 mode,u8* memoryBufferAdd,USART_TypeDef* usartx,u32 buffersize);
//void DMA1_USART1_Receivedata(u16 count);
//void DMA1_USART1_Sentdata(u16 count);

#endif

