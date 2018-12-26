/**
  ******************************************************************************
  * @file    main.h
  * $Author: wdluo $
  * $Revision: 67 $
  * $Date:: 2012-08-15 19:00:29 +0800 #$
  * @brief   主函数包含的头文件.
  ******************************************************************************
  * @attention
  *
  *<h3><center>&copy; Copyright 2009-2012, ViewTool</center>
  *<center><a href="http:\\www.viewtool.com">http://www.viewtool.com</a></center>
  *<center>All Rights Reserved</center></h3>
  * 
  ******************************************************************************
  */
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H
/* Includes ------------------------------------------------------------------*/
#include "stm32f10x_conf.h"

/* Exported Functions --------------------------------------------------------*/
//????,??51???GPIO????
//??????,??<<CM3????>>???(87?~92?).
//IO??????
#define BITBAND(addr, bitnum) ((addr & 0xF0000000)+0x2000000+((addr &0xFFFFF)<<5)+(bitnum<<2)) 
#define MEM_ADDR(addr)  *((volatile unsigned long  *)(addr)) 
#define BIT_ADDR(addr, bitnum)   MEM_ADDR(BITBAND(addr, bitnum)) 
//IO?????
#define GPIOA_ODR_Addr    (GPIOA_BASE+12) //0x4001080C 
#define GPIOB_ODR_Addr    (GPIOB_BASE+12) //0x40010C0C 
#define GPIOC_ODR_Addr    (GPIOC_BASE+12) //0x4001100C 
#define GPIOD_ODR_Addr    (GPIOD_BASE+12) //0x4001140C 
#define GPIOE_ODR_Addr    (GPIOE_BASE+12) //0x4001180C 
#define GPIOF_ODR_Addr    (GPIOF_BASE+12) //0x40011A0C    
#define GPIOG_ODR_Addr    (GPIOG_BASE+12) //0x40011E0C    

#define GPIOA_IDR_Addr    (GPIOA_BASE+8) //0x40010808 
#define GPIOB_IDR_Addr    (GPIOB_BASE+8) //0x40010C08 
#define GPIOC_IDR_Addr    (GPIOC_BASE+8) //0x40011008 
#define GPIOD_IDR_Addr    (GPIOD_BASE+8) //0x40011408 
#define GPIOE_IDR_Addr    (GPIOE_BASE+8) //0x40011808 
#define GPIOF_IDR_Addr    (GPIOF_BASE+8) //0x40011A08 
#define GPIOG_IDR_Addr    (GPIOG_BASE+8) //0x40011E08 
 
//IO???,?????IO?!
//??n????16!
#define PAout(n)   BIT_ADDR(GPIOA_ODR_Addr,n)  //?? 
#define PAin(n)    BIT_ADDR(GPIOA_IDR_Addr,n)  //?? 

#define PBout(n)   BIT_ADDR(GPIOB_ODR_Addr,n)  //?? 
#define PBin(n)    BIT_ADDR(GPIOB_IDR_Addr,n)  //?? 

#define PCout(n)   BIT_ADDR(GPIOC_ODR_Addr,n)  //?? 
#define PCin(n)    BIT_ADDR(GPIOC_IDR_Addr,n)  //?? 

#define PDout(n)   BIT_ADDR(GPIOD_ODR_Addr,n)  //?? 
#define PDin(n)    BIT_ADDR(GPIOD_IDR_Addr,n)  //?? 

#define PEout(n)   BIT_ADDR(GPIOE_ODR_Addr,n)  //?? 
#define PEin(n)    BIT_ADDR(GPIOE_IDR_Addr,n)  //??

#define PFout(n)   BIT_ADDR(GPIOF_ODR_Addr,n)  //?? 
#define PFin(n)    BIT_ADDR(GPIOF_IDR_Addr,n)  //??

#define PGout(n)   BIT_ADDR(GPIOG_ODR_Addr,n)  //?? 
#define PGin(n)    BIT_ADDR(GPIOG_IDR_Addr,n)  //??


#define PG_SCLK PBout(13)	// CLK	
#define PG_SDI PBout(14)	// SDI
#define PG_SDO PBin(15)	// SDO

#define SPI_CS PBout(8)		// POWER_DAC_SYNC
#define DAC_CS PBout(9)		// OUTPUT_DAC_CS
#define DAC_MSB PAout(15)		// OUTPUT_DAC_MSB D12
#define LVDS_LED PBout(2)	//LVDS_LED
#define BLU PCout(15)	//BLU Enable

#define TIM_MIN_US	3				//定时器可设置的最小时间（3us）
#define TIM_MIN_PERIOD 72 	//定时器设置为最小时间3us时，Period的值

extern bool TIM3_FLAG, onoff_finish;

void Delayms(u16 t);
void Delay(u16 t);


#endif/* __MAIN_H */

/*********************************END OF FILE**********************************/
