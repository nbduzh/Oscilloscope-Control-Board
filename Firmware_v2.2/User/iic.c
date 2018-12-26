

/* Includes ------------------------------------------------------------------*/
#include "stm32f10x_conf.h"


//__IO uint16_t  slaveAddress = 0xd4;   
__IO uint32_t  slaveTimeout = LONG_TIMEOUT;   
__IO uint16_t* slaveDataReadPointer;   
__IO uint8_t*  slaveDataWritePointer;  
__IO uint8_t   slaveDataNum;


void I2C2_WP(FunctionalState status)
{
  if(status == DISABLE)
    GPIO_ResetBits(GPIOB,GPIO_Pin_2);
  else
    GPIO_SetBits(GPIOB,GPIO_Pin_2);
}

void I2C_Release_Bus(I2C_TypeDef* I2Cx)
{
	u16 pin, wp;
	GPIO_InitTypeDef GPIO_Init_Value;
	if(I2Cx == I2C2)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C2,DISABLE);
		pin = GPIO_Pin_10 | GPIO_Pin_11;	
    wp = GPIO_Pin_2;
	}
	else
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C1,DISABLE);
		pin = GPIO_Pin_6 |GPIO_Pin_7;
    wp = GPIO_Pin_2;
	}
	GPIO_Init_Value.GPIO_Pin = pin;
	GPIO_Init_Value.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init_Value.GPIO_Mode = GPIO_Mode_AF_OD;
	GPIO_Init(GPIOB,&GPIO_Init_Value);

  GPIO_Init_Value.GPIO_Pin = wp;              //I2C2, WP
  GPIO_Init_Value.GPIO_Speed = GPIO_Speed_2MHz;
  GPIO_Init_Value.GPIO_Mode = GPIO_Mode_Out_OD;
  GPIO_Init(GPIOB,&GPIO_Init_Value);
	
	GPIO_SetBits(GPIOB, pin | wp);
}


uint16_t I2C_ReadEEPROMCheckSum (u16 address, u32 NumKByteToRead)
{ 
	u32 sum = 0;
	address = 0xa0 + (address << 1);
	NumKByteToRead = NumKByteToRead * 1024 / 8;								//Converter Kbit to BYTE
  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('a');
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('b');
  }

  I2C_Send7bitAddress(I2C2, address, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('c');
  } 

#ifdef SINGLE_BYTE_ADDRESS  
  
  /*!< Send the EEPROM's internal address to read from: Only one byte address */
  I2C_SendData(I2C2, 0x00);  

#elif defined (DOUBLE_BYTE_ADDRESS)

  /*!< Send the EEPROM's internal address to read from: MSB of the address first */
  I2C_SendData(I2C2, 0x00);    

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('B');
  }

  /*!< Send the EEPROM's internal address to read from: LSB of the address */
  I2C_SendData(I2C2, 0x00);    
  
#endif /*!< SINGLE_BYTE_ADDRESS */

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BTF) == RESET)
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('d');
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('e');
  } 
  
  I2C_Send7bitAddress(I2C2, address, I2C_Direction_Receiver);  
  
  while(NumKByteToRead)							
  {   
    if(NumKByteToRead == 1)
		{
			I2C_AcknowledgeConfig(I2C2, DISABLE);   
			I2C_GenerateSTOP(I2C2, ENABLE);
    }
		
		 /* Wait for the byte to be received */
		slaveTimeout = FLAG_TIMEOUT;
    while(!I2C_CheckEvent(I2C2,I2C_EVENT_MASTER_BYTE_RECEIVED))
    {
      if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('g');
    }
		sum = sum + I2C_ReceiveData(I2C2);
		I2C_AcknowledgeConfig(I2C2, ENABLE);  			
		NumKByteToRead--;   
		/*!< Re-Enable Acknowledgement to be ready for another reception */

	}
	return (u16)sum;
}







/**
  * @brief  Reads a block of data from the EEPROM.
  * @param  pBuffer : pointer to the buffer that receives the data read from 
  *         the EEPROM.
  * @param  ReadAddr : EEPROM's internal address to start reading from.
  * @param  NumByteToRead : pointer to the variable holding number of bytes to 
  *         be read from the EEPROM.
  * 
  *        @note The variable pointed by NumByteToRead is reset to 0 when all the 
  *              data are read from the EEPROM. Application should monitor this 
  *              variable in order know when the transfer is complete.
  * 
  * @note When number of data to be read is higher than 1, this function just 
  *       configures the communication and enable the DMA channel to transfer data.
  *       Meanwhile, the user application may perform other tasks.
  *       When number of data to be read is 1, then the DMA is not used. The byte
  *       is read in polling mode.
  * 
  * @retval OK (0) if operation is correctly performed, else return value 
  *         different from OK (0) or the timeout user callback.
  */
uint32_t I2C_ReadEEPROM(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t ReadAddr, uint16_t NumByteToRead)
{ 
  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('a');
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('b');
  }
  
  I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('c');
  } 

#ifdef SINGLE_BYTE_ADDRESS  
  
  /*!< Send the EEPROM's internal address to read from: Only one byte address */
  I2C_SendData(I2C2, ReadAddr);  

#elif defined (DOUBLE_BYTE_ADDRESS)

  /*!< Send the EEPROM's internal address to read from: MSB of the address first */
  I2C_SendData(I2C2, (uint8_t)((ReadAddr & 0xFF00) >> 8));    

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('B');
  }

  /*!< Send the EEPROM's internal address to read from: LSB of the address */
  I2C_SendData(I2C2, (uint8_t)(ReadAddr & 0x00FF));    
  
#endif /*!< SINGLE_BYTE_ADDRESS */

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BTF) == RESET)
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('d');
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('e');
  } 
  
  I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Receiver);  
  
  while(NumByteToRead)							
  {   
    if(NumByteToRead == 1)
		{
			I2C_AcknowledgeConfig(I2C2, DISABLE);   
			I2C_GenerateSTOP(I2C2, ENABLE);
    }
		
		 /* Wait for the byte to be received */
		slaveTimeout = FLAG_TIMEOUT;
    while(!I2C_CheckEvent(I2C2,I2C_EVENT_MASTER_BYTE_RECEIVED))
    {
      if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('g');
    }
		*pBuffer = I2C_ReceiveData(I2C2);
		I2C_AcknowledgeConfig(I2C2, ENABLE);  			
		pBuffer++;
		NumByteToRead--;   
		/*!< Re-Enable Acknowledgement to be ready for another reception */

	}
	return OK;
}


int16_t I2C_ReadByteData(uint16_t slaveAddress, uint16_t ReadAddr)
{ 
  uint8_t data = 0;
  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  }
  
  I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  } 

  
  /*!< Send the EEPROM's internal address to read from: Only one byte address */
  I2C_SendData(I2C2, ReadAddr);  

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BTF) == RESET)
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  }
  
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  } 
  
  I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Receiver);  

   /* Wait for the byte to be received */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2,I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  }    
  I2C_AcknowledgeConfig(I2C2, DISABLE);
  I2C_GenerateSTOP(I2C2, ENABLE);

  while(!I2C_CheckEvent(I2C2,I2C_EVENT_MASTER_BYTE_RECEIVED))
  {
    if((slaveTimeout--) == 0){
      TIMEOUT_UserCallback('a');
      return -1;
    }
  }  

  data = I2C_ReceiveData(I2C2);
  return data;
}





/**
  * @brief  Writes more than one byte to the EEPROM with a single WRITE cycle.
  *
  * @note   The number of bytes (combined to write start address) must not 
  *         cross the EEPROM page boundary. This function can only write into
  *         the boundaries of an EEPROM page.
  *         This function doesn't check on boundaries condition (in this driver 
  *         the function WriteBuffer() which calls I2C_WritePage() is 
  *         responsible of checking on Page boundaries).
  * 
  * @param  pBuffer : pointer to the buffer containing the data to be written to 
  *         the EEPROM.
  * @param  WriteAddr : EEPROM's internal address to write to.
  * @param  NumByteToWrite : pointer to the variable holding number of bytes to 
  *         be written into the EEPROM. 
  * 
  *        @note The variable pointed by NumByteToWrite is reset to 0 when all the 
  *              data are written to the EEPROM. Application should monitor this 
  *              variable in order know when the transfer is complete.
  * 
  * @note This function just configure the communication and enable the DMA 
  *       channel to transfer data. Meanwhile, the user application may perform 
  *       other tasks in parallel.
  * 
  * @retval OK (0) if operation is correctly performed, else return value 
  *         different from OK (0) or the timeout user callback.
  */
uint32_t I2C_WritePage(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t WriteAddr, uint8_t NumByteToWrite)
{ 
  /* Set the pointer to the Number of data to be written. This pointer will be used 
      by the DMA Transfer Completer interrupt Handler in order to reset the 
      variable to 0. User should check on this variable in order to know if the 
      DMA transfer has been complete or not. */ 
  
  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('h');
  }
  
  /*!< Send START condition */
  I2C_GenerateSTART(I2C2, ENABLE);
  
  /*!< Test on EV5 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('i');
  }
  
  /*!< Send EEPROM address for write */
  slaveTimeout = FLAG_TIMEOUT;
  I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('j');
  }

#ifdef SINGLE_BYTE_ADDRESS
  
  /*!< Send the EEPROM's internal address to write to : only one byte Address */
  I2C_SendData(I2C2, WriteAddr);
  
#elif defined(DOUBLE_BYTE_ADDRESS)
  
  /*!< Send the EEPROM's internal address to write to : MSB of the address first */
  I2C_SendData(I2C2, (uint8_t)((WriteAddr & 0xFF00) >> 8));

  /*!< Test on EV8 and clear it */
  slaveTimeout = FLAG_TIMEOUT;  
  while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('C');
  }  
  
  /*!< Send the EEPROM's internal address to write to : LSB of the address */
  I2C_SendData(I2C2, (uint8_t)(WriteAddr & 0x00FF));
  
#endif /*!< SINGLE_BYTE_ADDRESS */  
	
	
  while(NumByteToWrite)
	{
		/*!< Test on EV8 and clear it */
		slaveTimeout = FLAG_TIMEOUT; 
		while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
		{
			if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('k');
		}  
		I2C_SendData(I2C2, *pBuffer);
		pBuffer++;
		NumByteToWrite--;
		if(!NumByteToWrite)
		{
			slaveTimeout = FLAG_TIMEOUT; 
			while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
			{
				if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('K');
			}  
			I2C_GenerateSTOP(I2C2,ENABLE);
		}
	}
  return OK;
}

/**
  * @brief  Writes buffer of data to the I2C2 EEPROM.
  * @param  pBuffer : pointer to the buffer  containing the data to be written 
  *         to the EEPROM.
  * @param  WriteAddr : EEPROM's internal address to write to.
  * @param  NumByteToWrite : number of bytes to write to the EEPROM.
  * @retval None
  */
void WriteBuffer(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t WriteAddr, uint16_t NumByteToWrite)
{
  uint8_t NumOfPage = 0, NumOfSingle = 0, count = 0;
  uint16_t Addr = 0;

  Addr = WriteAddr % PAGESIZE;
  count = PAGESIZE - Addr;
  NumOfPage =  NumByteToWrite / PAGESIZE;
  NumOfSingle = NumByteToWrite % PAGESIZE;
 
  /*!< If WriteAddr is PAGESIZE aligned  */
  if(Addr == 0) 
  {
    /*!< If NumByteToWrite < PAGESIZE */
    if(NumOfPage == 0) 
    {
      /* Store the number of data to be written */
      slaveDataNum = NumOfSingle;
      /* Start writing data */
      I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
      /* Wait transfer through DMA to be complete */
      slaveTimeout = LONG_TIMEOUT;
      while (slaveDataNum > 0)
      {
        if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('l'); return;};
      }
      WaitEepromStandbyState(slaveAddress);
    }
    /*!< If NumByteToWrite > PAGESIZE */
    else  
    {
      while(NumOfPage--)
      {
        /* Store the number of data to be written */
        slaveDataNum = PAGESIZE;        
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum); 
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('m'); return;};
        }      
        WaitEepromStandbyState(slaveAddress);
        WriteAddr +=  PAGESIZE;
        pBuffer += PAGESIZE;
      }

      if(NumOfSingle!=0)
      {
        /* Store the number of data to be written */
        slaveDataNum = NumOfSingle;          
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('n'); return;};
        }    
        WaitEepromStandbyState(slaveAddress);
      }
    }
  }
  /*!< If WriteAddr is not PAGESIZE aligned  */
  else 
  {
    /*!< If NumByteToWrite < PAGESIZE */
    if(NumOfPage== 0) 
    {
      /*!< If the number of data to be written is more than the remaining space 
      in the current page: */
      if (NumByteToWrite > count)
      {
        /* Store the number of data to be written */
        slaveDataNum = count;        
        /*!< Write the data conained in same page */
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('o'); return;};
        }          
        WaitEepromStandbyState(slaveAddress);      
        
        /* Store the number of data to be written */
        slaveDataNum = (NumByteToWrite - count);          
        /*!< Write the remaining data in the following page */
        I2C_WritePage((uint8_t*)(pBuffer + count), slaveAddress, (WriteAddr + count), (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('p'); return;};
        }     
        WaitEepromStandbyState(slaveAddress);        
      }      
      else      
      {
        /* Store the number of data to be written */
        slaveDataNum = NumOfSingle;         
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('q'); return;};
        }          
        WaitEepromStandbyState(slaveAddress);        
      }     
    }
    /*!< If NumByteToWrite > PAGESIZE */
    else
    {
      NumByteToWrite -= count;
      NumOfPage =  NumByteToWrite / PAGESIZE;
      NumOfSingle = NumByteToWrite % PAGESIZE;
      
      if(count != 0)
      {  
        /* Store the number of data to be written */
        slaveDataNum = count;         
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('r'); return;};
        }     
        WaitEepromStandbyState(slaveAddress);
        WriteAddr += count;
        pBuffer += count;
      } 
      
      while(NumOfPage--)
      {
        /* Store the number of data to be written */
        slaveDataNum = PAGESIZE;          
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum);
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('s'); return;};
        }        
        WaitEepromStandbyState(slaveAddress);
        WriteAddr +=  PAGESIZE;
        pBuffer += PAGESIZE;  
      }
      if(NumOfSingle != 0)
      {
        /* Store the number of data to be written */
        slaveDataNum = NumOfSingle;           
        I2C_WritePage(pBuffer, slaveAddress, WriteAddr, (uint8_t)slaveDataNum); 
        /* Wait transfer through DMA to be complete */
        slaveTimeout = LONG_TIMEOUT;
        while (slaveDataNum > 0)
        {
          if((slaveTimeout--) == 0) {TIMEOUT_UserCallback('!'); return;};
        }         
        WaitEepromStandbyState(slaveAddress);
      }
    }
  }  
}

/**
  * @brief  Wait for EEPROM Standby state.
  * 
  * @note  This function allows to wait and check that EEPROM has finished the 
  *        last Write operation. It is mostly used after Write operation: after 
  *        receiving the buffer to be written, the EEPROM may need additional 
  *        time to actually perform the write operation. During this time, it 
  *        doesn't answer to I2C1 packets addressed to it. Once the write operation 
  *        is complete the EEPROM responds to its address.
  *        
  * @note  It is not necessary to call this function after WriteBuffer() 
  *        function (WriteBuffer() already calls this function after each
  *        write page operation).    
  * 
  * @param  None
  * @retval OK (0) if operation is correctly performed, else return value 
  *         different from OK (0) or the timeout user callback.
  */
uint32_t WaitEepromStandbyState(uint16_t slaveAddress)      
{
  __IO uint16_t tmpSR1 = 0;
  __IO uint32_t sEETrials = 0;

  /*!< While the bus is busy */
  slaveTimeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2C2, I2C_FLAG_BUSY))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('u');
  }

  /* Keep looping till the slave acknowledge his address or maximum number 
     of trials is reached (this number is defined by MAX_TRIALS_NUMBER define
     in stm32_eval_i2c_ee.h file) */
  while (1)
  {
    /*!< Send START condition */
    I2C_GenerateSTART(I2C2, ENABLE);

    /*!< Test on EV5 and clear it */
    slaveTimeout = FLAG_TIMEOUT;
    while(!I2C_CheckEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT))
    {
      if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('v');
    }    

    /*!< Send EEPROM address for write */
    I2C_Send7bitAddress(I2C2, slaveAddress, I2C_Direction_Transmitter);
    
    /* Wait for ADDR flag to be set (Slave acknowledged his address) */
    slaveTimeout = LONG_TIMEOUT;
    do
    {     
      /* Get the current value of the SR1 register */
      tmpSR1 = I2C2->SR1;
      
      /* Update the timeout value and exit if it reach 0 */
      if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('w');
    }
    /* Keep looping till the Address is acknowledged or the AF flag is 
       set (address not acknowledged at time) */
    while((tmpSR1 & (I2C_SR1_ADDR | I2C_SR1_AF)) == 0);
     
    /* Check if the ADDR flag has been set */
    if (tmpSR1 & I2C_SR1_ADDR)
    {
      /* Clear ADDR Flag by reading SR1 then SR2 registers (SR1 have already 
         been read) */
      (void)I2C2->SR2;
      
      /*!< STOP condition */    
      I2C_GenerateSTOP(I2C2, ENABLE);
        
      /* Exit the function */
      return OK;
    }
    else
    {
      /*!< Clear AF flag */
      I2C_ClearFlag(I2C2, I2C_FLAG_AF);                  
    }
    
    /* Check if the maximum allowed numbe of trials has bee reached */
    if (sEETrials++ == MAX_TRIALS_NUMBER)
    {
      /* If the maximum number of trials has been reached, exit the function */
      return TIMEOUT_UserCallback('x');
    }
  }
}

//void I2C2_DMA_Config(u8 Direction, uint8_t* buffer, uint8_t NumData)
//{
//  DMA_InitTypeDef DMA_Init_Value;
//  
//  RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
//  
//  /* Initialize the DMA_PeripheralBaseAddr member */
//  DMA_Init_Value.DMA_PeripheralBaseAddr = I2C2->DR;
//  /* Initialize the DMA_MemoryBaseAddr member */
//  DMA_Init_Value.DMA_MemoryBaseAddr = (uint32_t)buffer;
//   /* Initialize the DMA_PeripheralInc member */
//  DMA_Init_Value.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
//  /* Initialize the DMA_MemoryInc member */
//  DMA_Init_Value.DMA_MemoryInc = DMA_MemoryInc_Enable;
//  /* Initialize the DMA_PeripheralDataSize member */
//  DMA_Init_Value.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
//  /* Initialize the DMA_MemoryDataSize member */
//  DMA_Init_Value.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
//  /* Initialize the DMA_Mode member */
//  DMA_Init_Value.DMA_Mode = DMA_Mode_Normal;
//  /* Initialize the DMA_Priority member */
//  DMA_Init_Value.DMA_Priority = DMA_Priority_Medium;
//  /* Initialize the DMA_M2M member */
//  DMA_Init_Value.DMA_M2M = DMA_M2M_Disable;
//  
//  /* If using DMA for Reception */
//  if (Direction == I2C_DMA_RX)
//  {
//    /* Initialize the DMA_DIR member */
//    DMA_Init_Value.DMA_DIR = DMA_DIR_PeripheralSRC;
//    
//    /* Initialize the DMA_BufferSize member */
//    DMA_Init_Value.DMA_BufferSize = NumData;
//    
//    DMA_DeInit(DMA1_Channel5);
//    
//    DMA_Init(DMA1_Channel5, &DMA_Init_Value);
//  }
//   /* If using DMA for Transmission */
//  else if (Direction == I2C_DMA_TX)
//  { 
//    /* Initialize the DMA_DIR member */
//    DMA_Init_Value.DMA_DIR = DMA_DIR_PeripheralDST;
//    
//    /* Initialize the DMA_BufferSize member */
//    DMA_Init_Value.DMA_BufferSize = NumData;
//    
//    DMA_DeInit(DMA1_Channel4);
//    
//    DMA_Init(DMA1_Channel4, &DMA_Init_Value);
//  }
//	
//	DMA_ITConfig(DMA1_Channel4,DMA_IT_TC,ENABLE);
//	DMA_ITConfig(DMA1_Channel5,DMA_IT_TC,ENABLE);
//}


//void DMA1_IT_Config(void)
//{
//	NVIC_InitTypeDef NVIC_Init_Value;
//	
//	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
//	NVIC_Init_Value.NVIC_IRQChannelPreemptionPriority = 1;
//	NVIC_Init_Value.NVIC_IRQChannelSubPriority = 1;
//	NVIC_Init_Value.NVIC_IRQChannelCmd = ENABLE;
//	
//	NVIC_Init_Value.NVIC_IRQChannel = DMA1_Channel4_IRQn | DMA1_Channel5_IRQn;
//	NVIC_Init(&NVIC_Init_Value);
//}




#ifdef USE_DEFAULT_TIMEOUT_CALLBACK
/**
  * @brief  Basic management of the timeout situation.
  * @param  None.
  * @retval None.
  */
uint8_t TIMEOUT_UserCallback(u8 mark)
{
  /* Block communication and all processes */
	printf("I2C or ADC Busy Timeout!__%c\r\n", mark);		//time out flag '~'
//	NVIC_SystemReset(); 
	return 0;
}
#endif /* USE_DEFAULT_TIMEOUT_CALLBACK */

#ifdef USE_DEFAULT_CRITICAL_CALLBACK
/**
  * @brief  Start critical section: these callbacks should be typically used
  *         to disable interrupts when entering a critical section of I2C1 communication
  *         You may use default callbacks provided into this driver by uncommenting the 
  *         define USE_DEFAULT_CRITICAL_CALLBACK.
  *         Or you can comment that line and implement these callbacks into your 
  *         application.
  * @param  None.
  * @retval None.
  */
void EnterCriticalSection_UserCallback(void)
{
  __disable_irq();  
}

/**
  * @brief  Start and End of critical section: these callbacks should be typically used
  *         to re-enable interrupts when exiting a critical section of I2C1 communication
  *         You may use default callbacks provided into this driver by uncommenting the 
  *         define USE_DEFAULT_CRITICAL_CALLBACK.
  *         Or you can comment that line and implement these callbacks into your 
  *         application.
  * @param  None.
  * @retval None.
  */
void ExitCriticalSection_UserCallback(void)
{
  __enable_irq();
}
#endif /* USE_DEFAULT_CRITICAL_CALLBACK */

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */

/**
  * @}
  */  

/******************* (C) COPYRIGHT 2011 STMicroelectronics *****END OF FILE****/
