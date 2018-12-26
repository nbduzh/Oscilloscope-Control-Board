
#include "stm32f10x_conf.h"

//#define GAIN ((250+50)/50)
#define GAIN 1.0


double ADC_readBuffer[8];
unsigned const long Reg_WriteCmd = 0x1FF0002;
unsigned const long Reg_ReadCmd = 0x1FF8002;

/*****************************ADC ******************************/

u8 IS_ADC_Busy(void)
{
	return GPIO_ReadInputDataBit(GPIOB,GPIO_Pin_12);
}


/********* Communicate with Host ***************************/



void Set_OutputVoltage(uint16_t dat)
{
	GPIOA->BRR = 0x7ff;
//	Delay(1);
	GPIOA->BSRR = dat;
//	Delay(1);
	DAC_CS = 0;
//	Delay(2);
	DAC_CS = 1;
}

void Set_VOPValue(uint16_t dat)
{
	SPI_CS = 0;
	dat = dat << 2;
	SPI_I2S_SendData(SPI1, dat);
	while(SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_TXE) == RESET);
	Delay(100);
	SPI_CS = 1;
}




/********* DAC Control Power ****************************************/
uint32_t DAC_WriteCMD(I2C_TypeDef* I2Cx, u8 command, u16 data)
{ 
	u8 dacAddress = 0x73;
  /* Set the pointer to the Number of data to be written. This pointer will be used 
      by the DMA Transfer Completer interrupt Handler in order to reset the 
      variable to 0. User should check on this variable in order to know if the 
      DMA transfer has been complete or not. */ 
  
  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2Cx, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('h');
  }
  
  /*!< Send START condition */
  I2C_GenerateSTART(I2Cx, ENABLE);
  
  /*!< Test on EV5 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('i');
  }
  
  /*!< Send DAC address for write */
  I2C_Send7bitAddress(I2Cx, dacAddress << 1, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('j');
  }
  
  /*!< Send the Command of DAC */
  I2C_SendData(I2Cx, command << 4);

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;  
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('C');
  }  
  
  /*!< Send the MSB 8bit of the data */
  I2C_SendData(I2Cx, (uint8_t)(data >> 2));
	
  /*!< Test on EV8 and clear it */	
  slaveTimeout = FLAG_TIMEOUT;  
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('C');
  } 	
		
  /*!< Send the LSB 8bit of the data */
  I2C_SendData(I2Cx, (uint8_t)(data << 6));	
	
	slaveTimeout = FLAG_TIMEOUT; 
	while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
	{
		if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('K');
	}  
	I2C_GenerateSTOP(I2Cx,ENABLE);	

  return OK;
}



double ADC_ReadValue(u16 readCount)
{
	u32 sum = 0;
	u16 temp = readCount;
	while(temp--)
	{
		ADC_RegularChannelConfig(ADC1,ADC_Channel_1, 1, ADC_SampleTime_239Cycles5);
		ADC_SoftwareStartConvCmd(ADC1,ENABLE);
		while(!ADC_GetFlagStatus(ADC1,ADC_FLAG_EOC));
		sum += ADC_GetConversionValue(ADC1);
	}
	sum = (double)sum / readCount + 0.5;
	return sum / 4096.0 * 3.3 * GAIN;
}

uint8_t Split_Str(char* rawdata, char* split, char* data[])
{
	char* p;
	uint8_t i=0;
	p = strtok(rawdata, split);
	data[i++] = p;
	while(p!=NULL)
	{
		p = strtok(NULL, split);
		data[i++] = p;
	}
	return i-1;
}

////CMD is define write/read funtion,Addr is define register,DataIn is define register data
//void PG_WriteCMD(	unsigned char address, unsigned char data)  
//{
//	unsigned int i;
//	unsigned long cmd;
//	
//	cmd = Reg_WriteCmd;
//	
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SDI = 0;	
////	PG_SDO = 0;	
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	
//	for(i = 0; i < 25; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		//write bit			
//		if(((cmd) & 0x1000000) == 0x1000000)
//			PG_SDI = 1;
//		else
//			PG_SDI = 0;
//		cmd = cmd << 1;
//		Delay(10);
//	
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//	
//	for(i = 0; i < 8; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		//write bit			
//		if(((address) & 0x80) == 0x80)
//			PG_SDI = 1;
//		else
//			PG_SDI = 0;
//		address = address << 1;
//		Delay(10);
//			
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//	
//	for(i = 0; i < 8; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		//write bit			
//		if(((data) & 0x80) == 0x80)
//			PG_SDI = 1;
//		else
//			PG_SDI = 0;
//		
//		data = data << 1;
//		Delay(10);
//			
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//			
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SDI =0;
//  Delay(20);		

//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	
//	PG_SCLK = 1;
//	Delay(20);
//	PG_SDI = 1;
//	Delay(20);
//}


//uint16_t PG_ReadCMD(unsigned char address)  
//{
//	unsigned int i;
//	unsigned long cmd;
//	uint16_t status=0, ret=0;
//	
//	cmd = Reg_ReadCmd;
//	
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SDI = 0;	
////	PG_SDO = 0;	
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	
//	for(i = 0; i < 25; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		//write bit			
//		if(((cmd) & 0x1000000) == 0x1000000)
//			PG_SDI = 1;
//		else
//			PG_SDI = 0;
//		cmd = cmd << 1;
//		Delay(10);
//	
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//	
//	for(i = 0; i < 8; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		//write bit			
//		if(((address) & 0x80) == 0x80)
//			PG_SDI = 1;
//		else
//			PG_SDI = 0;
//		address = address << 1;
//		Delay(10);
//			
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//	
//	for(i = 0; i < 8; i++)
//	{		
//		PG_SCLK = 0;
//		Delay(10);
//		PG_SDI = 0;
//		Delay(10);
//		PG_SCLK = 1;
//		Delay(20);
//	} 
//			
//	PG_SCLK = 0;
//  Delay(20);		

//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	
//	for(i = 0; i < 9; i++)
//	{		
//		PG_SCLK = 1;
//		Delay(10);
//		//Read bit			
//		if(PG_SDO != 0)
//			status = (status<<1) | 0x01;
//		else
//			status <<= 1;
//		Delay(10);
//			
//		PG_SCLK = 0;
//		Delay(20);
//	} 	
//	
//	if(status != 0x1ff)
//		return 256;
//	
//	for(i = 0; i < 8; i++)
//	{		
//		PG_SCLK = 1;
//		Delay(10);
//		//Read bit			
//		if(PG_SDO != 0)
//			ret = (ret<<1) | 0x01;
//		else
//			ret <<= 1;
//		Delay(10);
//			
//		PG_SCLK = 0;
//		Delay(20);
//	} 

//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	PG_SCLK = 1;
//	Delay(10);
//	PG_SCLK = 0;
//	Delay(10);
//	
//	PG_SCLK = 1;
//	Delay(20);
//	PG_SDI = 1;
//	Delay(20);
//	
//	return ret;
//}


//CMD is define write/read funtion,Addr is define register,DataIn is define register data
void PG_WriteCMD(	unsigned char address, unsigned char data)  
{
	unsigned int i;
	unsigned long cmd;
	
	cmd = Reg_WriteCmd;
	
	PG_SCLK = 0;
	Delay(20);
	PG_SDI = 0;	
//	PG_SDO = 0;	
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	
	for(i = 0; i < 25; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		//write bit			
		if(((cmd) & 0x1000000) == 0x1000000)
			PG_SDI = 1;
		else
			PG_SDI = 0;
		cmd = cmd << 1;
		Delay(20);
	
		PG_SCLK = 1;
		Delay(40);
	} 
	
	for(i = 0; i < 8; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		//write bit			
		if(((address) & 0x80) == 0x80)
			PG_SDI = 1;
		else
			PG_SDI = 0;
		address = address << 1;
		Delay(20);
			
		PG_SCLK = 1;
		Delay(40);
	} 
	
	for(i = 0; i < 8; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		//write bit			
		if(((data) & 0x80) == 0x80)
			PG_SDI = 1;
		else
			PG_SDI = 0;
		
		data = data << 1;
		Delay(20);
			
		PG_SCLK = 1;
		Delay(40);
	} 
			
	PG_SCLK = 0;
	Delay(20);
	PG_SDI =0;
  Delay(40);		

	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	
	PG_SCLK = 1;
	Delay(40);
	PG_SDI = 1;
	Delay(40);
}


uint16_t PG_ReadCMD(unsigned char address)  
{
	unsigned int i;
	unsigned long cmd;
	uint16_t status=0, ret=0;
	
	cmd = Reg_ReadCmd;
	
	PG_SCLK = 0;
	Delay(20);
	PG_SDI = 0;	
//	PG_SDO = 0;	
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	
	for(i = 0; i < 25; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		//write bit			
		if(((cmd) & 0x1000000) == 0x1000000)
			PG_SDI = 1;
		else
			PG_SDI = 0;
		cmd = cmd << 1;
		Delay(20);
	
		PG_SCLK = 1;
		Delay(40);
	} 
	
	for(i = 0; i < 8; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		//write bit			
		if(((address) & 0x80) == 0x80)
			PG_SDI = 1;
		else
			PG_SDI = 0;
		address = address << 1;
		Delay(20);
			
		PG_SCLK = 1;
		Delay(40);
	} 
	
	for(i = 0; i < 8; i++)
	{		
		PG_SCLK = 0;
		Delay(20);
		PG_SDI = 0;
		Delay(20);
		PG_SCLK = 1;
		Delay(40);
	} 
			
	PG_SCLK = 0;
  Delay(40);		

	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	
	for(i = 0; i < 9; i++)
	{		
		PG_SCLK = 1;
		Delay(20);
		//Read bit			
		if(PG_SDO != 0)
			status = (status<<1) | 0x01;
		else
			status <<= 1;
		Delay(20);
			
		PG_SCLK = 0;
		Delay(40);
	} 	
	
	if(status != 0x1ff)
		return 256;
	
	for(i = 0; i < 8; i++)
	{		
		PG_SCLK = 1;
		Delay(20);
		//Read bit			
		if(PG_SDO != 0)
			ret = (ret<<1) | 0x01;
		else
			ret <<= 1;
		Delay(20);
			
		PG_SCLK = 0;
		Delay(40);
	} 

	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	PG_SCLK = 1;
	Delay(20);
	PG_SCLK = 0;
	Delay(20);
	
	PG_SCLK = 1;
	Delay(40);
	PG_SDI = 1;
	Delay(40);
	
	return ret;
}


void Enable_TIM(TIM_TypeDef* TIMx, uint16_t TIM_IT, uint32_t cnt)
{
	TIM_ClearITPendingBit(TIMx, TIM_IT);
	TIM_SetCounter(TIMx,cnt);
	TIM_Cmd(TIMx,ENABLE);
	TIM_ITConfig(TIMx, TIM_IT, ENABLE);
}



