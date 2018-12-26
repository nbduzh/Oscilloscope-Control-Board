/**
  ******************************************************************************
  * @file    usart.c
  * $Author: wdluo $
  * $Revision: 67 $
  * $Date:: 2012-08-15 19:00:29 +0800 #$
  * @brief   ������غ�����
  ******************************************************************************
  * @attention
  *
  *<h3><center>&copy; Copyright 2009-2012, ViewTool</center>
  *<center><a href="http:\\www.viewtool.com">http://www.viewtool.com</a></center>
  *<center>All Rights Reserved</center></h3>
  * 
  ******************************************************************************
  */
/* Includes ------------------------------------------------------------------*/
#include "usart.h"

/** @addtogroup USART
  * @brief ����ģ��
  * @{
  */

//#ifdef __GNUC__
///* With GCC/RAISONANCE, small printf (option LD Linker->Libraries->Small printf
//     set to 'Yes') calls __io_putchar() */
//#define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
//#else
//#define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
//#endif /* __GNUC__ */

#define USART_REC_LEN  			200  	//????????? 200
#define EN_USART1_RX 			1		//??(1)/??(0)??1??

u8 USART_RX_BUF[USART_REC_LEN];     //????,??USART_REC_LEN???.
//????
//bit15,	??????
//bit14,	???0x0d
//bit13~0,	??????????
u16 USART_RX_STA=0;       //??????	  

//////////////////////////////////////////////////////////////////
//??????,??printf??,??????use MicroLIB	  
#if 1
#pragma import(__use_no_semihosting)             
//??????????                 
struct __FILE 
{ 
	int handle; 

}; 

FILE __stdout;       
//??_sys_exit()??????????    
_sys_exit(int x) 
{ 
	x = x; 
} 
//???fputc?? 
int fputc(int ch, FILE *f)
{      
	while((USART1->SR&0X40)==0);//????,??????   
    USART1->DR = (u8) ch;      
	return ch;
}
#endif 

/**
  * @brief  ����GPIOA,����1ʱ�� 
  * @param  None
  * @retval None
  * @note  ����ĳЩGPIO�ϵ�Ĭ�ϸ��ù��ܿ��Բ���������ʱ�ӣ�����õ����ù��ܵ���
           ӳ�䣬����Ҫ��������ʱ��
  */
void USART_RCC_Configuration(void)
{
//	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO,ENABLE);//������ʱ��
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA|RCC_APB2Periph_USART1,ENABLE);
}

/**
  * @brief  ���ô���1������������ŵ�ģʽ 
  * @param  None
  * @retval None
  */
void USART_GPIO_Configuration(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_PinRemapConfig(GPIO_Remap_USART1,ENABLE);

	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_6;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;

	GPIO_Init(GPIOB, &GPIO_InitStruct);

	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_7;
	
	GPIO_Init(GPIOB, &GPIO_InitStruct);
	
}

/**
  * @brief  ���ô���1����ʹ�ܴ���1
  * @param  None
  * @retval None
  */
void USART_Configuration(void)
{
	USART_InitTypeDef USART_InitStruct;
	NVIC_InitTypeDef NVIC_InitStructure;
	USART_GPIO_Configuration();
	USART_RCC_Configuration();
	
	  //Usart1 NVIC ??
  NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority=3 ;//?????3
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 3;		//????3
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;			//IRQ????
	NVIC_Init(&NVIC_InitStructure);	//??????????VIC???

	USART_InitStruct.USART_BaudRate = 115200;
	USART_InitStruct.USART_StopBits = USART_StopBits_1;
	USART_InitStruct.USART_WordLength = USART_WordLength_8b;
	USART_InitStruct.USART_Parity = USART_Parity_No;
	USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	
	USART_Init(USART1, &USART_InitStruct);
	USART_ITConfig(USART1,USART_IT_RXNE,ENABLE);//ʹ�ܽ����ж�
	USART_Cmd(USART1, ENABLE);//ʹ�ܴ���1

}




//PUTCHAR_PROTOTYPE
//{
//	/* Place your implementation of fputc here */
//	/* e.g. write a character to the USART */
//	USART_SendData(USART1,(u8)ch);

//	/* Loop until the end of transmission */
//	while (USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);

//	return ch;
//}



void USART1_IRQHandler(void)                	//??1??????
	{
	u8 Res;
#if SYSTEM_SUPPORT_OS 		//??SYSTEM_SUPPORT_OS??,?????OS.
	OSIntEnter();    
#endif
	if(USART_GetITStatus(USART1, USART_IT_RXNE) != RESET)  //????(?????????0x0d 0x0a??)
	{
		Res =USART_ReceiveData(USART1);	//????????
		
		if((USART_RX_STA&0x8000)==0)//?????
		{
			if(USART_RX_STA&0x4000)//????0x0d
				{
					if(Res!=0x0a){
						USART_RX_STA=0;//????,????
					}
					else{ USART_RX_STA|=0x8000;	//????? 
					}
				}
			else //????0X0D
			{	
				if(Res==0x0d)USART_RX_STA|=0x4000;
				else
				{
					USART_RX_BUF[USART_RX_STA&0X3FFF]=Res ;
					USART_RX_STA++;
					if(USART_RX_STA>(USART_REC_LEN-1)){
							USART_RX_STA=0;//??????,??????	 
					}
				}		 
			}
		}   		 
   } 
#if SYSTEM_SUPPORT_OS 	//??SYSTEM_SUPPORT_OS??,?????OS.
	OSIntExit();  											 
#endif
} 
/**
  * @}
  */

/*********************************END OF FILE**********************************/

