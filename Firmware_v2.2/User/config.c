

#include "stm32f10x_conf.h"

/*******************************************************************************
* Function Name  : RCC_Configuration 
* Description    :  RCC??(????8MHz??)
* Input            : ?
* Output         : ?
* Return         : ?
*******************************************************************************/
void RCC_Config(void)
{
  RCC_DeInit();
 
  RCC_HSEConfig(RCC_HSE_ON);   //RCC_HSE_ON——HSE????(ON)
 
 
  if(RCC_WaitForHSEStartUp() == SUCCESS)        //SUCCESS:HSE???????
  {

    RCC_HCLKConfig(RCC_SYSCLK_Div1);  //RCC_SYSCLK_Div1  AHB = 72MHz
 
    RCC_PCLK2Config(RCC_HCLK_Div2);   //RCC_HCLK_Div2—AAPB2 = HCLK / 2 = 36MHz
    
		RCC_PCLK1Config(RCC_HCLK_Div2);   //RCC_HCLK_Div2—AAPB1 = HCLK / 2 = 36MHz
 
    RCC_PLLConfig(RCC_PLLSource_HSE_Div1, RCC_PLLMul_9);     

    RCC_PLLCmd(ENABLE); 
 
    while(RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET)      
    {
    }
 
    RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK); 

    while(RCC_GetSYSCLKSource() != 0x08)        //0x08:PLL??????
    { 
    }
  }
}




void GPIO_Config(void)
{
	GPIO_InitTypeDef GPIO_Init_Value;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
	
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE);
	
	
//*************** led ********************
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_2;											//led
	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_2MHz;		
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOB,&GPIO_Init_Value);	
	
//*************** BLU Enable ********************
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_15;											//BLU Enable 
	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_2MHz;		
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOC,&GPIO_Init_Value);	
	
//*************** Output Power DAC ********************
	GPIO_Init_Value.GPIO_Pin = 0x07ff | GPIO_Pin_15;											//pin0 ~ pin10 & pin15
	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_50MHz;		
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOA,&GPIO_Init_Value);	
	
//*************** pg control ********************
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_14;												//PG_SCLK; PG_SDI
	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_50MHz;		
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOB,&GPIO_Init_Value);
	
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_15;													//PG_SDO;
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_IPD;
	GPIO_Init(GPIOB,&GPIO_Init_Value);	
	
	
//*************** Power EN ********************
//	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_0;													//en
//	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_2MHz;		
//	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
//	GPIO_Init(GPIOA,&GPIO_Init_Value);	
//	
//	GPIO_ResetBits(GPIOA, GPIO_Pin_0);
	
	
	
/**
 * 		See iic.c -> void I2C_Release_Bus(I2C_TypeDef* I2Cx);
 */
// //*************** I2C ****************//												
// 	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_10 | GPIO_Pin_11 | GPIO_Pin_6 |GPIO_Pin_7;							//I2C2, SCL, SDA
// 	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
// 	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AF_OD;
// 	GPIO_Init(GPIOB,&GPIO_Init_Value);

// 	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_2;							//I2C2, WP
// 	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_2MHz;
// 	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_OD;
// 	GPIO_Init(GPIOB,&GPIO_Init_Value);

	
//*************** SPI1 ****************
	GPIO_PinRemapConfig(GPIO_Remap_SPI1,ENABLE);
	
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_3 | GPIO_Pin_5;
	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_Init(GPIOB,&GPIO_Init_Value);
	
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_4;											//MISO Pull up in;
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_IPU;;
	GPIO_Init(GPIOB,&GPIO_Init_Value);
	
	GPIO_Init_Value.GPIO_Speed =  GPIO_Speed_50MHz;		
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_8 | GPIO_Pin_9;					//POWER_DAC_SYNC & OUTPUT_DAC_CS
	GPIO_Init(GPIOB,&GPIO_Init_Value);	
	

////*************** USART1 ****************
//	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_9;									//Tx
//	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
//	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AF_PP;
//	GPIO_Init(GPIOA,&GPIO_Init_Value);
//	
//	GPIO_Init_Value.GPIO_Pin = GPIO_Pin_10;									//Rx
//	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
//	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_IN_FLOATING;
//	GPIO_Init(GPIOA,&GPIO_Init_Value);
	
	
//*************** ADC1 ****************	
//	 GPIO_Init_Value.GPIO_Pin = GPIO_Pin_1;									//ADC1_1
//	 GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AIN;
//	 GPIO_Init(GPIOA,&GPIO_Init_Value);

	
}



//void USART1_Config(u32 bound)
//{
//	USART_InitTypeDef USART_Init_Value;
//	NVIC_InitTypeDef NVIC_Init_Value;
//	
//	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1, ENABLE);
//	
//	USART_Init_Value.USART_BaudRate = bound;
//	USART_Init_Value.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
//	USART_Init_Value.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
//	USART_Init_Value.USART_Parity = USART_Parity_No;
//	USART_Init_Value.USART_StopBits = USART_StopBits_1;
//	USART_Init_Value.USART_WordLength = USART_WordLength_8b;
//	USART_Init(USART1,&USART_Init_Value);
//	
//	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
//	NVIC_Init_Value.NVIC_IRQChannel = USART1_IRQn;
//	NVIC_Init_Value.NVIC_IRQChannelPreemptionPriority = 1;
//	NVIC_Init_Value.NVIC_IRQChannelSubPriority = 2;
//	NVIC_Init_Value.NVIC_IRQChannelCmd = ENABLE;
//	NVIC_Init(&NVIC_Init_Value);

////	USART_DMACmd(USART1,USART_DMAReq_Rx,ENABLE);
//	USART_ITConfig(USART1,USART_IT_RXNE,ENABLE);
//	USART_Cmd(USART1,ENABLE);
//}




void I2C_Config(I2C_TypeDef* I2Cx)
{
	GPIO_InitTypeDef GPIO_Init_Value;
	I2C_InitTypeDef I2C_Init_Value;
	
	if(I2Cx == I2C2)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C2,ENABLE);
		GPIO_Init_Value.GPIO_Pin = GPIO_Pin_10 | GPIO_Pin_11;	
	}
	else
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C1,ENABLE);
		GPIO_Init_Value.GPIO_Pin = GPIO_Pin_6 |GPIO_Pin_7;
		printf("I2C1 start.\r\n");
	}

	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AF_OD;
	GPIO_Init(GPIOB,&GPIO_Init_Value);
	
	I2C_DeInit(I2Cx);
	I2C_Init_Value.I2C_Ack = I2C_Ack_Enable;
	I2C_Init_Value.I2C_AcknowledgedAddress = I2C_AcknowledgedAddress_7bit;
	I2C_Init_Value.I2C_ClockSpeed = 300000;
	I2C_Init_Value.I2C_DutyCycle = I2C_DutyCycle_2;
	I2C_Init_Value.I2C_Mode = I2C_Mode_I2C;
	I2C_Init_Value.I2C_OwnAddress1 = 0xa0;
	I2C_Init(I2Cx,&I2C_Init_Value);
	I2C_Cmd(I2Cx,ENABLE);
}


void SPI_Config(SPI_TypeDef* SPIx)
{
	SPI_InitTypeDef SPI_Init_Value;
	if(SPIx == SPI2)
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2,ENABLE);
	else
		RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1,ENABLE);
	
	SPI_Init_Value.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_32;
	SPI_Init_Value.SPI_CPHA = SPI_CPHA_2Edge;
	SPI_Init_Value.SPI_CPOL = SPI_CPOL_Low;
	SPI_Init_Value.SPI_DataSize = SPI_DataSize_16b;
	SPI_Init_Value.SPI_Direction = SPI_Direction_2Lines_FullDuplex;
	SPI_Init_Value.SPI_FirstBit = SPI_FirstBit_MSB;
	SPI_Init_Value.SPI_Mode = SPI_Mode_Master;
	SPI_Init_Value.SPI_CRCPolynomial = 7;
	SPI_Init_Value.SPI_NSS = SPI_NSS_Soft;
	SPI_Init(SPIx,&SPI_Init_Value);
	
	SPI_NSSInternalSoftwareConfig(SPIx,SPI_NSSInternalSoft_Set);
	SPI_Cmd(SPIx,ENABLE);
}




void ADC_Config(void)
{
	ADC_InitTypeDef ADC_Init_Value;
	RCC_ADCCLKConfig(RCC_PCLK2_Div4);
 	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1,ENABLE);
	
	ADC_Init_Value.ADC_ContinuousConvMode = DISABLE;
	ADC_Init_Value.ADC_DataAlign = ADC_DataAlign_Right;
	ADC_Init_Value.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;
	ADC_Init_Value.ADC_Mode = ADC_Mode_Independent;
	ADC_Init_Value.ADC_NbrOfChannel = 1;
	ADC_Init_Value.ADC_ScanConvMode = DISABLE;
	ADC_Init(ADC1,&ADC_Init_Value);
	ADC_Cmd(ADC1,ENABLE);
	ADC_ResetCalibration(ADC1);
	while(ADC_GetResetCalibrationStatus(ADC1));
	ADC_StartCalibration(ADC1);
	while(ADC_GetCalibrationStatus(ADC1));
}
	
void TIM_Config(void)
{
	NVIC_InitTypeDef NVIC_Init_Value;
	TIM_TimeBaseInitTypeDef TIM_Init_Value;

	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3,ENABLE);
	
	TIM_Init_Value.TIM_ClockDivision = TIM_CKD_DIV1;
	TIM_Init_Value.TIM_CounterMode = TIM_CounterMode_Up;
	TIM_Init_Value.TIM_Period = 216;										//3us   ..MAX TIM_CNT
	TIM_Init_Value.TIM_Prescaler = 0;								//3us	..add n count, then TIM_CNT++;								
	TIM_TimeBaseInit(TIM3,&TIM_Init_Value);

//	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
	NVIC_Init_Value.NVIC_IRQChannelPreemptionPriority = 0;
	NVIC_Init_Value.NVIC_IRQChannelSubPriority = 0;
	NVIC_Init_Value.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init_Value.NVIC_IRQChannel = TIM3_IRQn;
	NVIC_Init(&NVIC_Init_Value);	
	
	TIM_ClearITPendingBit(TIM3, TIM_IT_Update);
	TIM_ITConfig(TIM3, TIM_IT_Update, ENABLE);
	TIM_SetCounter(TIM3,0);
}

void TIM_Setus(float period)
{
	TIM_TimeBaseInitTypeDef TIM_Init_Value;
	
	TIM_Init_Value.TIM_ClockDivision = TIM_CKD_DIV1;
	TIM_Init_Value.TIM_CounterMode = TIM_CounterMode_Up;
	TIM_Init_Value.TIM_Period = (uint16_t)(period*72+0.5);										//3us   ..MAX TIM_CNT
	TIM_Init_Value.TIM_Prescaler = 0;								//3us	..add n count, then TIM_CNT++;								
	TIM_TimeBaseInit(TIM3,&TIM_Init_Value);
	
	TIM_ClearITPendingBit(TIM3, TIM_IT_Update);
	TIM_ITConfig(TIM3, TIM_IT_Update, ENABLE);
	TIM_SetCounter(TIM3,0);
}













