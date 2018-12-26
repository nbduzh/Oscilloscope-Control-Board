

#ifndef __PGAMMA_H__
#define __PGAMMA_H__

#include "stm32f10x.h"

typedef enum {EEPROM = 0, FlashIC} RomICType;
typedef enum {Digital = 0, CM602, CM603, IN603C, IN518C} VcomICType;
typedef enum {OtherV = 0, CM508, IN518} PWMICType;


u8 I2C_WriteCmd(I2C_TypeDef* I2Cx, u8 slaveAddress, s16 address, u8 cmd);
uint32_t PGammaVcomRange(VcomICType icType, char voltage[][16], u8 ch);
uint32_t PWMVcomRange(VcomICType icType, char voltage[][16], u8 ch);
uint32_t DigitalVcomRange(char voltage[][16], u8 ch);
uint16_t I2C_ReadPGamma(I2C_TypeDef* I2Cx, VcomICType vcom);
uint16_t I2C_ReadPWM(I2C_TypeDef* I2Cx, PWMICType pwm);
#endif


