

#ifndef __PROCESS_H__
#define __PROCESS_H__

#include "stm32f10x.h"
#include "pgamma.h"


/* DAC Command see datasheet */
#define DAC_CMD_USE_INT_REF	0x06
#define DAC_CMD_USE_EXT_REF	0x07
#define DAC_CMD_WRITE_DATA	0x03
#define DAC_DATA_DUMMY 0x340
#define DAC_DATA_MAX	0x1ce
#define DAC_DATA_MIN	0xa4


#define FAIL 0xff
#define OK 1

void Set_VOPValue(uint16_t dat);
void Set_OutputVoltage(uint16_t dat);
uint32_t DAC_WriteCMD(I2C_TypeDef* I2Cx, u8 command, u16 data);
double ADC_ReadValue(u16 readCount);
uint8_t Split_Str(char* rawdata, char* split, char* data[]);
void PG_WriteCMD(	unsigned char address, unsigned char data);
uint16_t PG_ReadCMD(unsigned char address);
void Enable_TIM(TIM_TypeDef* TIMx, uint16_t TIM_IT, uint32_t cnt);

#endif


