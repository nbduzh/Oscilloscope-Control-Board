/**
  ******************************************************************************
  * @file    main.c
  * $Author: wdluo $
  * $Revision: 67 $
  * $Date:: 2012-08-15 19:00:29 +0800 #$
  * @brief   主函数.
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
#include "main.h"
#include "usart.h"
#include "usb_lib.h"
#include "hw_config.h"
#include "usbio.h"
#include "math.h"
/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
extern uint8_t USB_Received_Flag;
extern uint8_t USB_Receive_Buffer[];
extern uint8_t USB_Send_Buffer[];
extern const uint8_t CustomHID_StringProduct[];
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

#define OP_GAIN ((4.02+1.0)/1.0)
#define VREF 3.0
#define OUT_DAC_RESOLUTION 2048.0
#define PWR_DAC_RESOLUTION 4096.0
#define RH 10.0
#define RL 0.732
#define VFB 1.221
#define VOP_DATA(v) ((VFB-(RL/RH)*(v-VFB))/VREF*PWR_DAC_RESOLUTION)

#define POWER_OFF 0
#define MEAN_MODE 1
#define INRUSH_MODE 2
#define PG_INIT_MODE 3
#define PG_SHOW_PATTERN 4
#define PG_READ_MODE 5
#define PG_EXIT_MODE 6
#define PG_WRITE_MODE 10
#define TIMING_RISE_MODE 7
#define TIMING_FALL_MODE 8
#define TIMING_ONOFF_MODE 9

//u16 dacData = 0x90;					// 12v
u16 dacData = 0x175;					//5v
bool TIM3_FLAG = FALSE, onoff_finish = FALSE;

unsigned char Reg_address[] = {0x01,0x02,0x03,0x04,0x00,0x00,0x20,0x21};
unsigned char Reg_data[] = {0xff,0x3f,0xff,0x3f,0x80,0xc0,0x02,0x00};
double Panel_Voltage[] = {5, 12, 3.3, 10};											//as same as VB Host

void Delay(u16 t)
{
	while(t--);
}


void Delayms(u16 t)
{
  unsigned int i,n;
  for(n=0;n<t;n++)
    for(i=0;i<800;i++);
}

//void Poweroff(void)
//{
//	DAC_MSB = 0;
//	Set_OutputVoltage(0x7fa);						//OUTPUT Voltage 调零0
//	TIM_Cmd(TIM3,DISABLE);
//	LVDS_LED = 0;
//}

/**
  * @brief  串口打印输出
  * @param  None
  * @retval None
  */
int main(void)
{
	uint8_t data[128], count, mode;
	uint32_t i=0, cnt_on=0, cnt_off=0, cnt_r, cnt_f, ret=0, targetRise, step_on, step_off, \
					step_r, step_f, riseTime, fallTime, onTime, offTime, BLUOn, BLUOff, tim_us_r, tim_us_f;
	uint16_t readdata;
	int32_t  outputData, gap_i_r, gap_i_f, out_r=0, out_f, t2time, t5time, cnt_t2, cnt_t5, temp, temp2;
	float targetVol, gap_r, gap_f, gain_r, gain_f;
	double panelVoltage, prePanelVoltage=0;
	char* cmd[16];
	long panelVoltageIndex, prePanelVoltageIndex=255;

	Set_System();//系统时钟初始化
	GPIO_Config();
	LVDS_LED = 0;
	BLU=0;
	USART_Configuration();//串口1初始化

	printf("\r\n*************************************************");
	printf("\r\n******** Oscilloscope Control Board v2.1 ********");
	printf("\r\n*************** By Innolux NGB PD ***************");
	printf("\r\n************** All Rights Reserved **************");
	printf("\r\n*************************************************");
	printf("\r\n");
	
	SPI_Config(SPI1);
	TIM_Config();
	
	USB_Interrupts_Config();
	Set_USBClock();
	USB_Init();
	
	DAC_CS = 1;
	SPI_CS = 1;
	
	for(i=0;i<64;i++)
	{
		USB_Receive_Buffer[i] = 0x00;
		USB_Send_Buffer[i] = 'R';
	}
	
	PG_SCLK = 1;
	PG_SDI = 1;	
	PG_SDO = 1;
	
	Set_VOPValue(0x3AC);
	DAC_MSB = 0;
	Set_OutputVoltage(0x7fa);								//OUTPUT Voltage 调零0
	
	printf("\n\r==> System start working...\r\n");	
	
	while(1)
	{
		if(USB_Received_Flag)
		{
			USB_Received_Flag=0;
//			USB_SendData(USB_Send_Buffer, 64);		
			ret = USB_GetData(data,sizeof(data));
			count = Split_Str(data, ";", cmd);
			mode = strtol(cmd[0], NULL, 10);
			printf("\n\r==> Receive USB Command = %s, %s, %s, %s, %s, %s, %s, %s, %s, \
			%s, %s, %s, %s, %s, %s, %s\r\n",cmd[0],cmd[1],cmd[2],cmd[3],cmd[4],cmd[5], \
			cmd[6],cmd[7],cmd[8],cmd[9],cmd[10],cmd[11],cmd[12],cmd[13],cmd[14],cmd[15]);
//			printf("usb get data %d byte data\n\r",ret);
			TIM_Setus(TIM_MIN_US);
			if(mode == MEAN_MODE)														/////////////////////////////
			{
					printf("\n\rENTER MEAN MODE\r\n");
					panelVoltageIndex = strtol(cmd[1],NULL,10);
					if(panelVoltageIndex != prePanelVoltageIndex)
					{
						prePanelVoltageIndex = panelVoltageIndex;
						Set_VOPValue(VOP_DATA(Panel_Voltage[panelVoltageIndex]*1.1+3.0));								//110% Voltage + 3.0v OP offset		
						Delayms(100);
					}
					targetVol = strtod(cmd[2], NULL)+0.50;							//+0.5v 线损Comp,防止90%电压重载画面无法启动；
					printf("	TargetVol = %lf\r\n",targetVol);
					outputData = targetVol/(VREF*OP_GAIN)*OUT_DAC_RESOLUTION;
					DAC_MSB = 1;
					Set_OutputVoltage(outputData);
					Delayms(400);
					LVDS_LED = 1;
					BLU=1;
					printf("\n\r==> Set VCC Value finish...\r\n");
			}
			else if(mode == INRUSH_MODE)										/////////////////////////////
			{
				printf("\n\rENTER INRUSH MODE\r\n");
				i = 0;
				out_r = 0;
				targetRise = strtol(cmd[1], NULL, 10) * 1.3;
				step_r = targetRise/TIM_MIN_US;										//TIM3 3us/times				
				gap_r = (float)outputData/step_r;
				gap_i_r = gap_r * 1000;														//浮点转整形计算，放大1000倍
				printf("	TargetRiseTime = %lu us\r\n",strtol(cmd[1], NULL, 10));
				Delayms(1000);
				TIM3_FLAG = FALSE;
				TIM_Cmd(TIM3,ENABLE);
				DAC_MSB = 1;
				while(step_r)
				{
					if(TIM3_FLAG != FALSE)
					{
						TIM3_FLAG = FALSE;
						out_r = (++i)*gap_i_r/1000;
						Set_OutputVoltage(out_r);
						step_r--;
					}
				}
				TIM_Cmd(TIM3,DISABLE);
				Delayms(400);
				LVDS_LED = 1;
				BLU=1;
				printf("\n\r==> VCC rising finish...\r\n");
			}
			else if(mode == TIMING_RISE_MODE)									/////////////////////////////
			{
				printf("\n\rENTER RISE MODE\r\n");
				i = 0;
				out_r = 0;
				panelVoltage = strtod(cmd[2],NULL);
				if(fabs(panelVoltage-prePanelVoltage)>0.005)
				{
					prePanelVoltage = panelVoltage;
					Set_VOPValue(VOP_DATA(panelVoltage*1.1+3.0));								//110% Voltage + 3.0v OP offset		
					printf("	Set OP Voltage = %lf\r\n", panelVoltage*1.1+3.0);
					Delayms(100);
				}
				targetVol = panelVoltage+0.25;							//+1.5v 线损Comp
				printf("	Target Voltage = %lf\r\n", panelVoltage);
//				printf("	outputData = %d\r\n", outputData);
				outputData = targetVol/(VREF*OP_GAIN)*OUT_DAC_RESOLUTION;
				riseTime = strtol(cmd[1], NULL, 10) * 1.3;
				step_r = riseTime/TIM_MIN_US;														//TIM3 3us/times
				gap_r = (float)outputData/step_r;
				gap_i_r = gap_r * 1000;														//浮点转整形计算，放大1000倍
				
				gain_r = ((float)step_r)/outputData;
				if(gain_r>1){
					step_r = outputData;
					gap_i_r = 1 * 1000;
					TIM_Setus(TIM_MIN_US*gain_r);
				}
				
				printf("	Rise Time = %lu us\r\n", strtol(cmd[1], NULL, 10));
				Delayms(1000);
				TIM3_FLAG = FALSE;
				TIM_Cmd(TIM3,ENABLE);
				DAC_MSB = 1;
				while(step_r)
				{
					if(TIM3_FLAG != FALSE)
					{
						TIM3_FLAG = FALSE;
						out_r = (++i)*gap_i_r/1000;
						Set_OutputVoltage(out_r);									
						step_r--;
					}
				}
				TIM_Cmd(TIM3,DISABLE);
				Delayms(400);
				LVDS_LED = 1;
				BLU=1;
				printf("\n\r==> VCC rising finish...\r\n");
			}
			else if(mode == TIMING_FALL_MODE)									/////////////////////////////
			{
				printf("\n\rENTER FALL MODE\r\n");
				i = 0;
				fallTime = strtol(cmd[1], NULL, 10) * 1.3;
				step_f = fallTime/TIM_MIN_US;																		//TIM3 3us/times
				gap_f = (double)outputData/step_f;
				gap_i_f = gap_f * 1000;														//浮点转整形计算，放大1000倍
				
				gain_f = ((float)step_f)/outputData;
				if(gain_f>1){
					step_f = outputData;
					gap_i_f = 1 * 1000;
					TIM_Setus(TIM_MIN_US*gain_f);
				}
				
				printf("	Fall Time = %lu us\r\n	Step = %d\r\n	Gap = %u\r\n", strtol(cmd[1], NULL, 10), step_f, gap_i_f);
				BLU=0;
				LVDS_LED = 0;
				Delayms(400);
				
				TIM3_FLAG = FALSE;
				TIM_Cmd(TIM3,ENABLE);
				DAC_MSB = 1;
				while(step_f)
				{
					if(TIM3_FLAG != FALSE)
					{
						TIM3_FLAG = FALSE;
						outputData = (outputData*1000 - gap_i_f)/1000;	
//						printf("	outputData = %d us\r\n", outputData);
						if(outputData < 0)
							outputData = 0;
						Set_OutputVoltage(outputData);
						step_f--;
					}
				}			
				TIM_Cmd(TIM3,DISABLE);
				printf("\n\r==> VCC falling finish...\r\n");
//				DAC_MSB = 0;
//				Set_OutputVoltage(0x7fa);						//OUTPUT Voltage 调零0
			}			
			else if(mode == TIMING_ONOFF_MODE)								/////////////////////////////
			{
				onoff_finish = FALSE;
				printf("\n\rENTER ON/OFF MODE\r\n");
				panelVoltage = strtod(cmd[9],NULL);
				if(fabs(panelVoltage-prePanelVoltage)>0.005)
				{
					prePanelVoltage = panelVoltage;
					Set_VOPValue(VOP_DATA(panelVoltage*1.1+3.0));									//110% Voltage + 3.0v OP offset		
					printf("	Set OP Voltage = %lf\r\n", panelVoltage*1.1+3.0);
					Delayms(100);
				}
				targetVol = panelVoltage+0.25;							//+0.25v 线损Comp
				printf("	Target Voltage = %lf\r\n", panelVoltage);
				
				LVDS_LED = 1;									//防止当T2小于零且绝对值大于Vcc上升时间，刚启动时无LVDS输出； 				
				DAC_MSB = 1;
				Delayms(1000);
				onoff_finish = FALSE;
//				while(!onoff_finish)
//				{
					/*************  set vcc rising argument  ************/
					outputData = targetVol/(VREF*OP_GAIN)*OUT_DAC_RESOLUTION;
					riseTime = strtol(cmd[1], NULL, 10) * 1.3;
					step_r = riseTime/TIM_MIN_US;														//TIM3 3us/times
					gap_r = (float)outputData/step_r;
					gap_i_r = gap_r * 1000;														//浮点转整形计算，放大1000倍
					cnt_r = step_r;
					
					/*************  set vcc falling argument  ************/
					fallTime = strtol(cmd[2], NULL, 10) * 1.3;
					step_f = fallTime/TIM_MIN_US;																		//TIM3 3us/times
					gap_f = (double)outputData/step_f;
					gap_i_f = gap_f * 1000;														//浮点转整形计算，放大1000倍
					cnt_f = step_f;
					
					onTime = strtol(cmd[3], NULL, 10)*1000;								//*1000 ==> ms to us
					step_on = onTime/TIM_MIN_US;																		//TIM3 3us/times
					offTime = strtol(cmd[4], NULL, 10)*1000;							//*1000 ==> ms to us
					step_off = offTime/TIM_MIN_US;																	//TIM3 3us/times		
					
					t2time = strtol(cmd[5], NULL, 10)*1000/TIM_MIN_US;								//*1000 ==> ms to us, /TIM_MIN_US TIM Count
					t5time = strtol(cmd[6], NULL, 10)*1000/TIM_MIN_US;							//*1000 ==> ms to us, /TIM_MIN_US TIM Count		
					cnt_t2 = t2time;
					cnt_t5 = t5time;

					BLUOn = strtol(cmd[7], NULL, 10)*1000/TIM_MIN_US;								//*1000 ==> ms to us, /TIM_MIN_US TIM Count
					BLUOff = strtol(cmd[8], NULL, 10)*1000/TIM_MIN_US;							//*1000 ==> ms to us, /TIM_MIN_US TIM Count					

					tim_us_r = TIM_MIN_US;
					gain_r = ((float)step_r)/outputData;
					if(gain_r>1){																			//若是上升时间过长，修改定时器最小单位时间，其他相应参数；
						step_r = outputData;
						gap_i_r = 1 * 1000;			
						step_on = step_on/gain_r;									
						t2time = t2time/gain_r;					//
						t5time = t5time/gain_r;					//
						BLUOn = BLUOn/gain_r;						//
						BLUOff = BLUOff/gain_r;					//
						tim_us_r = TIM_MIN_US*gain_r + 0.5;			//当Vcc上升时间过长时设置每次中断的定时器时间
					}
					
					tim_us_f = TIM_MIN_US;
					gain_f = ((float)step_f)/outputData;
					if(gain_f>1){
						step_f = outputData;
						gap_i_f = 1 * 1000;
						step_off = step_off/gain_f;			
						cnt_f = cnt_f/gain_f;								//同rise时的step_f
						cnt_r = cnt_r/gain_f;								//同rise时的step_r
						cnt_t2 = cnt_t2/gain_f;							//同rise时的t2time
						cnt_t5 = cnt_t5/gain_f;							//同rise时的t5time
						tim_us_f = TIM_MIN_US*gain_f + 0.5;			//当Vcc下降时间过长时设置每次中断的定时器时间
					}
					
				while(!onoff_finish)					
				{
					/*************  Power On  ************/
//					printf("\n\r Running Power On/Off  ==> On...\r\n");
					TIM_Setus(tim_us_r);
					temp = step_r;
					i = 0;
					out_r = 0;
					TIM_Cmd(TIM3,ENABLE);
					while(temp)
					{
						if(TIM3_FLAG != FALSE)
						{
							TIM3_FLAG = FALSE;
							out_r = (++i)*gap_i_r/1000;
							Set_OutputVoltage(out_r);		
							if(temp+t2time==0)					//T2小于零，且绝对值小于等于Vcc上升时间；
								LVDS_LED = 1;								
							temp--;
						}
					}									
					cnt_on=0;
					temp = step_on;
//					printf("\n\r step_on = %d, BLUOn = %d, BLUOff = %d\r\n",step_on, BLUOn, BLUOff);
					while(temp && (!onoff_finish)){
						if(TIM3_FLAG != FALSE)
						{
							TIM3_FLAG = FALSE;
							if(cnt_on==t2time) LVDS_LED=1;					//T2大于等于零；需在cnt_on++前；
							if(cnt_on==BLUOn) BLU=1;								//大于等于零，需在cnt_on++前；
							temp--;
							cnt_on++;
							if(temp==BLUOff) BLU=0;							//大于等于零，需在step_on--后；
							if(temp==t5time) LVDS_LED=0;					//T5大于等于零；需在step_on--后；
						}
					}		
					TIM_Cmd(TIM3,DISABLE);
					
					/*************  Power Off  ************/
//					printf("\n\r Running Power On/Off  ==> Off...\r\n");
					TIM_Setus(tim_us_f);
					temp = cnt_t5;
					temp2 = step_f;
					out_f = outputData;
					TIM_Cmd(TIM3,ENABLE);
					while(temp2)
					{
						if(TIM3_FLAG != FALSE)
						{
							TIM3_FLAG = FALSE;
							out_f = (out_f*1000 - gap_i_f)/1000;	
							if(out_f < 0)
								out_f = 0;
							Set_OutputVoltage(out_f);
							if(temp==0)						//T5小于等于零，且绝对值小于Vcc下降时间；
								LVDS_LED = 0;		
							temp2--;
							temp++;
						}
					}			
					cnt_off=0;
					temp = step_off;
					while(temp && (!onoff_finish)){
						if(TIM3_FLAG != FALSE)
						{
							TIM3_FLAG = FALSE;
							if(temp==(0-cnt_t2-cnt_r)) LVDS_LED=1;				//T2小于零，且绝对值大于Vcc上升时间；
							if(cnt_off==(0-cnt_t5-cnt_f)) LVDS_LED=0;					//T5小于零，且绝对值大于等于Vcc下降时间；
							temp--;
							cnt_off++;
						}
					}
					TIM_Cmd(TIM3,DISABLE);
				}
			}			
			else if(mode == PG_INIT_MODE)											/////////////////////////////
			{
				for(i=0;i<8;i++)
				{
					PG_WriteCMD(Reg_address[i],Reg_data[i]);
					Delayms(1000);
				}
				printf("\n\r==> PG init finished...\r\n");				
			}
			else if(mode == PG_SHOW_PATTERN)					/////////////////////////////
			{
				PG_WriteCMD(Reg_address[7], strtol(cmd[1], NULL, 10));
				printf("\n\r==> PG show pattern %ld...\r\n", strtol(cmd[1], NULL, 10));		
			}
			else if(mode == PG_WRITE_MODE)											/////////////////////////////
			{
				PG_WriteCMD(strtol(cmd[1], NULL, 10), strtol(cmd[2], NULL, 10));
				printf("\n\r==> Address = %ld, CMD = %ld ...\r\n", strtol(cmd[1], NULL, 10), strtol(cmd[2], NULL, 10));		
			} 
			else if(mode == PG_READ_MODE)							/////////////////////////////
			{
				printf("\n\rENTER PG READ MODE\r\n");
	//			PG_WriteCMD(0x00, 0x00);
//				Delayms(100);
				readdata = PG_ReadCMD(strtol(cmd[1], NULL, 10));
				if(readdata<256){
					USB_Send_Buffer[0] = 'R';
					USB_Send_Buffer[1] = (uint8_t)readdata;
					USB_SendData(USB_Send_Buffer, 64);
				}
				else{
					USB_Send_Buffer[0] = '3';					//PG5 not response
					USB_SendData(USB_Send_Buffer, 64);
				}
				printf("	Read Address = %ld\r\n", strtol(cmd[1], NULL, 10));	
				printf("	Read Data = %d\r\n", readdata);	
				printf("\n\r==> PG read completed...\r\n");				
			}
			else if(mode == PG_EXIT_MODE)						/////////////////////////////
			{
				PG_WriteCMD(0x00,0x00);
				printf("\n\r==> PG exit PC mode...\r\n");			
			}
			else if(mode == POWER_OFF)							/////////////////////////////
			{
				BLU=0;
				LVDS_LED = 0;
				Delayms(400);
				DAC_MSB = 0;
				Set_OutputVoltage(0x7fa);						//OUTPUT Voltage 调零0
				printf("\n\r==> Panel power off...\r\n");		
			}
		}
	}
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  报告在检查参数发生错误时的源文件名和错误行数
  * @param  file 源文件名
  * @param  line 错误所在行数 
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{
    /* 用户可以增加自己的代码用于报告错误的文件名和所在行数,
       例如：printf("错误参数值: 文件名 %s 在 %d行\r\n", file, line) */

    /* 无限循环 */
    while (1)
    {
    }
}
#endif

/*********************************END OF FILE**********************************/
