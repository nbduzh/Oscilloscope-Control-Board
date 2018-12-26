#include "stm32f10x_conf.h"

u8 cm603_HI[4]={0xb2,0x96,0xa9,0x69};             //HI: Himax, NT: Novatek, GM: GMT, RI: Richtek
u8 cm603_GMT[4]={0xb2,0x96,0xa9,0x69};
u8 cm603_NT[4]={0x82,0x96,0x81,0x69};

u8 in603c_RI[4]={0x80,0x5a,0x81,0xa5}; 
u8 in603c_NT[4]={0x80,0x5a,0x81,0xa5};           
u8 in603c_HI[4]={0xbc,0x5a,0x91,0xa5}; 
u8 in603c_GMT[4]={0xbc,0x5a,0x91,0xa5};  

u8 in518_Vcom[2]={0xa3, 0x5c};  

/**
 * device ID 0xF1:
 *   CM603 
 *     GMT: 0x0000
 *     NT:  0x0008
 *     HI:  0x0005
 *   IN603C
 *     HI:  0x0C05
 *     NT:  0x0C08
 *     GMT: 0x0C07
 *     RI:  TBD       //Richtek no device ID description in datasheet
 */


u8 I2C_WriteCmd(I2C_TypeDef* I2Cx, u8 slaveAddress, s16 address, u8 cmd)
{ 
  
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
  
  /*!< Send EEPROM address for write */
  slaveTimeout = FLAG_TIMEOUT;
  I2C_Send7bitAddress(I2Cx, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  slaveTimeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('j');
  }
  
  if(address >= 0){
    /*!< Send the EEPROM's internal address to write to : only one byte Address */
    I2C_SendData(I2Cx, address);

    slaveTimeout = FLAG_TIMEOUT; 
    while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
    {
      if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('K');
    }  
  }

  I2C_SendData(I2Cx, cmd);

  slaveTimeout = FLAG_TIMEOUT; 
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_BYTE_TRANSMITTED))
  {
    if((slaveTimeout--) == 0) return TIMEOUT_UserCallback('K');
  }  
  
  I2C_GenerateSTOP(I2Cx,ENABLE);

  return OK;
}



uint32_t PGammaVcomRange(VcomICType icType, char voltage[][16], u8 ch)
{
  u8 vcom[2], temp[4], deviceID[2];
  u8* protect;
  u8 protect_flag = 0;
  double min, max;

  /*!< Read Device ID */  
  if(!I2C_ReadEEPROM(deviceID, 0xd4, 0xF1, 2)){
    return 0;
  }

  switch(icType)
  {
    case IN603C:
      protect_flag = 1;
      switch(deviceID[1]){
        case 0x05:
          protect = in603c_HI;
          break;
        case 0x08:
          protect = in603c_NT;
          break;
        case 0x07:
          protect = in603c_GMT;
          break;
        default:
          protect = in603c_RI;        /////Richtek no device ID description in datasheet
          break;
      }
      break;
    case CM603:
      switch(deviceID[1]){
        case 0x00:
          protect = cm603_GMT;
          break;
        case 0x08:
          protect = cm603_NT;
          break;
        case 0x05:
          protect = cm603_HI;
          break;
        default:
          protect = cm603_HI;       ////////////////////////////
          break;
      }
      protect_flag = 1;
      break;
  }

  if(protect_flag){
    if(!I2C_ReadEEPROM(temp, 0xd4, 0x00, 4))
      return 0;
    if(!I2C_WritePage(protect, 0xd4, 0x00,2))
      return 0;
    Delayms(10);
    if(!I2C_WritePage(protect+2, 0xd4, 0x01,2))
      return 0;
  }

  if(!I2C_ReadEEPROM(vcom, 0xd4, 0x18, 2)){
    return 0;
  }
  Delayms(100);
  vcom[0]=vcom[0]&0x3f;
  vcom[0]=vcom[0]|0x80;
  if(!I2C_WritePage(vcom, 0xd4, 0x12, 2)){
    return 0;
  }
  Delayms(1000);
  min = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));

  if(!I2C_ReadEEPROM(vcom, 0xd4, 0x19, 2)){
    return 0;
  }

  // if(protect_flag){
  //   if(!I2C_WritePage(protect, 0xd4, 0x00,2))
  //     return 0;
  //   Delayms(10);
  //   if(!I2C_WritePage(protect+2, 0xd4, 0x01,2))
  //     return 0;
  // }
  vcom[0]=vcom[0]&0x3f;
  vcom[0]=vcom[0]|0x80;
  Delayms(100);
  if(!I2C_WritePage(vcom, 0xd4, 0x12, 2)){
    return 0;
  }
  Delayms(1000);
  max = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));

  if(protect_flag){
    temp[0]=temp[0]|0x80;
    temp[2]=temp[2]|0x80;
    if(!I2C_WritePage(temp, 0xd4, 0x00, 2))
      return 0;
    if(!I2C_WritePage(temp+2, 0xd4, 0x01, 2))
      return 0;
  }

  sprintf(voltage[ch], "%1.2f~%1.2f,", min, max); 
  return OK; 
}

/**
 * Read format:
 *   start -> 0x3b=0x01 -> sent address -> read data -> stop;
 * Write format(WP3):
 *   start -> 0x2f=0xa3, 0x30=0x5c (disable soft protect) -> 0x3d=0x80 (reset status) -> sent address 
 *   -> write data -> 0x3a=0x80 (write to MTP) -> 0x3c=0x80 (internal flag pull high, enable MTP Protect) -> 0x3e=0x80 (reset WP) -> stop
 */
uint32_t PWMVcomRange(VcomICType icType, char voltage[][16], u8 ch)          ///////////////need add slaveaddress
{
	int16_t vcom, vendorCode;
  	u8* protect;
  	double min, max;

  	vendorCode = I2C_ReadByteData(0x40, 0xf3);
  	if(vendorCode < 0){
    	return 0;
  	}

  	switch(icType)
  	{
  		case IN518C:
  			protect = in518_Vcom;
  			break;
  		default:
  			break;
  	}

  	/*********  Disable soft protection  ********/
	if(!I2C_WritePage(protect, 0x40, 0x2f, 2)){
	    return 0;
	}
	Delayms(100);
	if(!I2C_WriteCmd(I2C2, 0x40, 0x3d, 0x80)){
		return 0;
	}
	Delayms(800);
	/*********  Read min vcom  ********/
  	vcom = I2C_ReadByteData(0x40, 0x33);
  	if(vcom < 0) 	return 0;

	Delayms(100);
 	if(!I2C_WriteCmd(I2C2, 0x40, 0x34, vcom)){
		return 0;
	} 	
  	Delayms(1000);
  	min = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));

	if(!I2C_WriteCmd(I2C2, 0x40, 0x3c, 0x80)){
		return 0;
	}
	Delayms(100);
	if(!I2C_WriteCmd(I2C2, 0x40, 0x3e, 0x80)){
		return 0;
	}


  	/*********  Disable soft protection  ********/
	if(!I2C_WritePage(protect, 0x40, 0x2f, 2)){
	    return 0;
	}
	Delayms(100);
	if(!I2C_WriteCmd(I2C2, 0x40, 0x3d, 0x80)){
		return 0;
	}
	Delayms(800);

	/*********  Read max vcom  ********/
  	vcom = I2C_ReadByteData(0x40, 0x32);
  	if(vcom < 0)	return 0;
	Delayms(100);

 	if(!I2C_WriteCmd(I2C2, 0x40, 0x34, vcom)){
		return 0;
	} 	
  	Delayms(1000);
  	max = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));

	if(!I2C_WriteCmd(I2C2, 0x40, 0x3c, 0x80)){
		return 0;
	}
	Delayms(100);
	if(!I2C_WriteCmd(I2C2, 0x40, 0x3e, 0x80)){
		return 0;
	}
  	sprintf(voltage[ch], "%1.2f~%1.2f,", min, max); 
  	return OK; 
}


uint32_t DigitalVcomRange(char voltage[][16], u8 ch)          
{
  	double min=0, max=0;
	
//  	I2C2_WP(DISABLE);
	if(!I2C_WriteCmd(I2C2, 0x9e, -1, 0x01)){
		return 0;
	} 	
//	Delayms(1);
//	I2C2_WP(ENABLE);
  	Delayms(3000);
  	max = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));
  	
//   	I2C2_WP(DISABLE);
	 if(!I2C_WriteCmd(I2C2, 0x9e, -1, 0xff)){
	 	return 0;
	 }
//	 Delayms(1);
//	 I2C2_WP(ENABLE);
   	Delayms(3000);
   	min = ADC_VoltageAddComp(ch, ADC_ReadChannelValue(ch));

  	sprintf(voltage[ch], "%1.2f~%1.2f,", min, max); 
  	return OK; 
}



uint16_t I2C_ReadPGamma(I2C_TypeDef* I2Cx, VcomICType vcom)   
{ 
  u32 sum;
  u8 data[256];
  u8 slaveAddress = 0xd4, romSize, i = 0;
  u32 Timeout;

  switch(vcom)
  {
    case CM602:
      romSize = 0x37 * 2 + 2;
      break;
    case CM603:
    case IN603C:
      romSize = 0x3f * 2 + 2;
      break;
  }

  /*!< Set all DAC to MTP Value */
  I2C_WriteCmd(I2Cx, slaveAddress, -1, 0x80);               
  Delayms(1500);

  /*!< While the bus is busy */
  Timeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2Cx, I2C_FLAG_BUSY))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('a');
  }
  
  I2C_GenerateSTART(I2Cx, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('b');
  }
  
  I2C_Send7bitAddress(I2Cx, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('c');
  } 

  
  /*!< Send the EEPROM's internal address to read from: Only one byte address */
  I2C_SendData(I2Cx, 0x00);  

  /*!< Test on EV8 and clear it */
  Timeout = FLAG_TIMEOUT;
  while(I2C_GetFlagStatus(I2Cx, I2C_FLAG_BTF) == RESET)
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('d');
  }
  
  I2C_GenerateSTART(I2Cx, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('e');
  } 
  
  I2C_Send7bitAddress(I2Cx, slaveAddress, I2C_Direction_Receiver);  
  
  while(i < romSize)              
  {   
    if(i == (romSize - 1))
    {
      I2C_AcknowledgeConfig(I2Cx, DISABLE);   
      I2C_GenerateSTOP(I2Cx, ENABLE);
    }
    
     /* Wait for the byte to be received */
    Timeout = FLAG_TIMEOUT;
    while(!I2C_CheckEvent(I2Cx,I2C_EVENT_MASTER_BYTE_RECEIVED))
    {
      if((Timeout--) == 0) return TIMEOUT_UserCallback('g');
    }
    data[i] = I2C_ReceiveData(I2Cx);
    I2C_AcknowledgeConfig(I2Cx, ENABLE);  
    sum += data[i];   
    i++;   
    /*!< Re-Enable Acknowledgement to be ready for another reception */
  }

  switch(vcom)
  {
    case CM602:
    case CM603:
      sum = sum - data[110] - data[111];      //checksum = all - MRT;
      break;
    case IN603C:
      break;
  }

  return (u16)sum;
}


/**
 * IN518 Read format:
 *   start -> 0x3b=0x01 -> sent address -> read data -> stop;
 * CM508 Read format:
 * 	 
 */
uint16_t I2C_ReadPWM(I2C_TypeDef* I2Cx, PWMICType pwm)   
{ 
  u32 sum=0;
  u8 data[256], slaveAddress = 0x40, romSize, flagAddress, flag=0, i=0;
  u32 Timeout;

  switch(pwm)
  {
    case CM508:
      romSize = 12;
      flagAddress = 0xff;
      flag = 0x01;
      break;
    case IN518:
      romSize = 0x39 + 1;
      flagAddress = 0x3b;
      flag = 0x01;
      break;
  }

  /*!< Set read EEPROM value */
  I2C_WriteCmd(I2Cx, slaveAddress, flagAddress, flag);               
  Delayms(1500);

  /*!< While the bus is busy */
  Timeout = LONG_TIMEOUT;
  while(I2C_GetFlagStatus(I2Cx, I2C_FLAG_BUSY))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('a');
  }
  
  I2C_GenerateSTART(I2Cx, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('b');
  }
  
  I2C_Send7bitAddress(I2Cx, slaveAddress, I2C_Direction_Transmitter);

  /*!< Test on EV6 and clear it */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('c');
  } 

  
  /*!< Send the EEPROM's internal address to read from: Only one byte address */
  I2C_SendData(I2Cx, 0x00);  

  /*!< Test on EV8 and clear it */
  Timeout = FLAG_TIMEOUT;
  while(I2C_GetFlagStatus(I2Cx, I2C_FLAG_BTF) == RESET)
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('d');
  }
  
  I2C_GenerateSTART(I2Cx, ENABLE);
  
  /*!< Test on EV5 and clear it (cleared by reading SR1 then writing to DR) */
  Timeout = FLAG_TIMEOUT;
  while(!I2C_CheckEvent(I2Cx, I2C_EVENT_MASTER_MODE_SELECT))
  {
    if((Timeout--) == 0) return TIMEOUT_UserCallback('e');
  } 
  
  I2C_Send7bitAddress(I2Cx, slaveAddress, I2C_Direction_Receiver);  
  
  while(i < romSize)              
  {   
    if(i == (romSize - 1))
    {
      I2C_AcknowledgeConfig(I2Cx, DISABLE);   
      I2C_GenerateSTOP(I2Cx, ENABLE);
    }
    
     /* Wait for the byte to be received */
    Timeout = FLAG_TIMEOUT;
    while(!I2C_CheckEvent(I2Cx,I2C_EVENT_MASTER_BYTE_RECEIVED))
    {
      if((Timeout--) == 0) return TIMEOUT_UserCallback('g');
    }
    data[i] = I2C_ReceiveData(I2Cx);
    I2C_AcknowledgeConfig(I2Cx, ENABLE);  
    sum += data[i];   
    i++;   
    /*!< Re-Enable Acknowledgement to be ready for another reception */
  }

  return (u16)sum;
}


