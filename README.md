# Oscilloscope-Control-Board v2.2


History:
v1.0 Oscilloscope Control function
v2.0 Host：Add Timing, Vcc rising falling & Backlight Timing

v2.1 ：
	Host：
		1. Add LVDS Timing；
		2. 测Inrush时示波器触发电压由1/3 Vcc改为2/3 Vcc，防止有电压杂讯导致误触发；
		3. 测平均电流时电流通道的level由300mA改为500mA，防止电流过大时电流波形和电压波形重叠；
	firmware：
		1. 测平均电流时的线损补偿由0.25v改为0.5v，防止90%电压重载画面无法启动（3.3v机种可能输入电压过大？）

v2.2 ：
	Host：
			1. 将White，Black，V-Strip画面的选项写入ini文件，防止继续量测时读取不到正确的画面设置。
	firmware：
	2018.12.26	1. 外部晶振由8M改为12M，修改代码使系统时钟仍为72M。（“hw_config.c”，第91行）
