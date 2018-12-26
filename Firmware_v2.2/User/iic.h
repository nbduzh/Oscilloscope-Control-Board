/**
  ******************************************************************************
  * @file    stm32_eval_i2c_ee.h
  * @author  MCD Application Team
  * @version V4.5.0
  * @date    07-March-2011
  * @brief   This file contains all the functions prototypes for the stm32_eval_i2c_ee
  *          firmware driver.
  ******************************************************************************
  * @attention
  *
  * THE PRESENT FIRMWARE WHICH IS FOR GUIDANCE ONLY AIMS AT PROVIDING CUSTOMERS
  * WITH CODING INFORMATION REGARDING THEIR PRODUCTS IN ORDER FOR THEM TO SAVE
  * TIME. AS A RESULT, STMICROELECTRONICS SHALL NOT BE HELD LIABLE FOR ANY
  * DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES WITH RESPECT TO ANY CLAIMS ARISING
  * FROM THE CONTENT OF SUCH FIRMWARE AND/OR THE USE MADE BY CUSTOMERS OF THE
  * CODING INFORMATION CONTAINED HEREIN IN CONNECTION WITH THEIR PRODUCTS.
  *
  * <h2><center>&copy; COPYRIGHT 2011 STMicroelectronics</center></h2>
  ******************************************************************************  
  */ 

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __IIC_H__
#define __IIC_H__

#ifdef __cplusplus
 extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
//#include "stm32_eval.h"	 
#include "stm32f10x.h"


	 
#define I2C_DMA_RX 0
#define I2C_DMA_TX 1	 
  
/* Uncomment this line to use the default start and end of critical section 
   callbacks (it disables then enabled all interrupts) */
#define USE_DEFAULT_CRITICAL_CALLBACK 
/* Start and End of critical section: these callbacks should be typically used
   to disable interrupts when entering a critical section of I2C communication
   You may use default callbacks provided into this driver by uncommenting the 
   define USE_DEFAULT_CRITICAL_CALLBACK.
   Or you can comment that line and implement these callbacks into your 
   application */

/* Uncomment the following line to use the default TIMEOUT_UserCallback() 
   function implemented in stm32_evel_i2c_ee.c file.
   TIMEOUT_UserCallback() function is called whenever a timeout condition 
   occure during communication (waiting on an event that doesn't occur, bus 
   errors, busy devices ...). */   
#define USE_DEFAULT_TIMEOUT_CALLBACK

#define SINGLE_BYTE_ADDRESS
   
#if !defined (SINGLE_BYTE_ADDRESS) && !defined (DOUBLE_BYTE_ADDRESS)
/* Use the defines below the choose the EEPROM type */
/* #define SINGLE_BYTE_ADDRESS*/  /* Support the device: SINGLE_BYTE_ADDRESS. */
/* note: Could support: M24C01, M24C02, M24C04 and M24C16 if the blocks and 
   HW address are correctly defined*/
#define DOUBLE_BYTE_ADDRESS  /* Support the devices: M24C32 and M24C64 */
#endif


#define I2C_SPEED               300000
#define I2C_SLAVE_ADDRESS7      0xA0

#if defined (SINGLE_BYTE_ADDRESS)
 #define PAGESIZE           16
#elif defined (DOUBLE_BYTE_ADDRESS)
 #define PAGESIZE           32
#endif
   
/* Maximum Timeout values for flags and events waiting loops. These timeouts are
   not based on accurate values, they just guarantee that the application will 
   not remain stuck if the I2C communication is corrupted.
   You may modify these timeout values depending on CPU frequency and application
   conditions (interrupts routines ...). */   
#define FLAG_TIMEOUT         ((uint32_t)0x2000)
#define LONG_TIMEOUT         ((uint32_t)(16 * FLAG_TIMEOUT))

/* Maximum number of trials for WaitEepromStandbyState() function */
#define MAX_TRIALS_NUMBER     150
   
/* Defintions for the state of the DMA transfer */   
#define STATE_READY           0
#define STATE_BUSY            1
#define STATE_ERROR           2

void I2C2_WP(FunctionalState status);
void I2C_Release_Bus(I2C_TypeDef* I2Cx);

uint16_t I2C_ReadEEPROMCheckSum (u16 address, u32 NumKByteToRead);
int16_t I2C_ReadByteData(uint16_t slaveAddress, uint16_t ReadAddr);
uint32_t ReadBuffer(uint8_t* pBuffer, uint16_t ReadAddr, uint16_t* NumByteToRead);
uint32_t I2C_ReadEEPROM(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t ReadAddr, uint16_t NumByteToRead);

uint32_t I2C_WritePage(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t WriteAddr, uint8_t NumByteToWrite);
void     WriteBuffer(uint8_t* pBuffer, uint16_t slaveAddress, uint16_t WriteAddr, uint16_t NumByteToWrite);
uint32_t WaitEepromStandbyState(uint16_t slaveAddress);

void I2C2_DMA_Config(u8 Direction, uint8_t* buffer, uint8_t NumData);
void DMA1_IT_Config(void);

/* USER Callbacks: These are functions for which prototypes only are declared in
   EEPROM driver and that should be implemented into user applicaiton. */  
/* TIMEOUT_UserCallback() function is called whenever a timeout condition 
   occure during communication (waiting on an event that doesn't occur, bus 
   errors, busy devices ...).
   You can use the default timeout callback implementation by uncommenting the 
   define USE_DEFAULT_TIMEOUT_CALLBACK in stm32_evel_i2c_ee.h file.
   Typically the user implementation of this callback should reset I2C peripheral
   and re-initialize communication or in worst case reset all the application. */
uint8_t TIMEOUT_UserCallback(u8 mark);

/* Start and End of critical section: these callbacks should be typically used
   to disable interrupts when entering a critical section of I2C communication
   You may use default callbacks provided into this driver by uncommenting the 
   define USE_DEFAULT_CRITICAL_CALLBACK in stm32_evel_i2c_ee.h file..
   Or you can comment that line and implement these callbacks into your 
   application */
void EnterCriticalSection_UserCallback(void);
void ExitCriticalSection_UserCallback(void);

//extern __IO uint16_t  slaveAddress;   
extern __IO uint32_t  slaveTimeout;
extern __IO uint16_t* slaveDataReadPointer;   
extern __IO uint8_t*  slaveDataWritePointer;  
extern __IO uint8_t   slaveDataNum;


#ifdef __cplusplus
}
#endif

#endif /* __STM32_EVAL_I2C_EE_H */
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


