Attribute VB_Name = "Common"
Option Explicit

'声明必要的 API 例程：
Declare Function FindWindow Lib "user32" Alias _
"FindWindowA" (ByVal lpClassName As String, _
               ByVal lpWindowName As Long) As Long

Declare Function SendMessage Lib "user32" Alias _
"SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, _
               ByVal wParam As Long, _
               ByVal lParam As Long) As Long

Public Declare Function URLDownloadToFile Lib "urlmon" Alias "URLDownloadToFileA" (ByVal pCaller As Long, ByVal szURL As String, ByVal szFileName As String, ByVal dwReserved As Long, ByVal lpfnCB As Long) As Long
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Declare Function GetPrivateProfileString Lib "kernel32" Alias "GetPrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Long, ByVal lpFileName As String) As Long
Private Declare Function WritePrivateProfileString Lib "kernel32" Alias "WritePrivateProfileStringA" (ByVal lpApplicationName As String, ByVal lpKeyName As Any, ByVal lpString As Any, ByVal lpFileName As String) As Long


Public Const VolPrecision As Double = 0.005
Public Const TimePrecision As Double = 4

Public xlsApp As Excel.Application
Public xlsBook As Excel.Workbook
Public xlsSheetValue As Excel.Worksheet
Public xlsSheetImage As Excel.Worksheet

Public PreNumber As Long
Public CurrentPattern As String
Public CurrentProcess As Integer
Public ProcessID As Long
Public CompletedSample As Byte
Public LogFilePath As String
Public OutputFilelistPath As String
Public WaveformFilelistPath As String
Public OutputFilelist(64) As String
Public WaveformFilelist(64) As String

Public ProductID As String
Public DeviceName As String
Public PanelVoltage As Double
Public TargetVol As Double
Public TargetRiseTime As Double
Public AutoMeasureFinish As Boolean
Public VBThreadEnded As Boolean

Public Const POWER_OFF As String = "0;"
Public Const OSC_MEAN_MODE As String = "1;"
Public Const OSC_INRUSH_MODE As String = "2;"
Public Const PG_INIT_MODE As String = "3;"
Public Const PG_WRITE_PATT As String = "4;"
Public Const PG_READ_MODE As String = "5;"
Public Const PG_EXIT_MODE As String = "6;"
Public Const PG_WRITE_CMD As String = "10;"
Public Const PG_PATTERN_ADDRESS As Byte = 41
Public Const PG_MODE_ADDRESS As Byte = 29
Public Const PG_TOTALPATTERN_ADDRESS As Byte = 42
Public Const TIMING_RISE_MODE As String = "7;"
Public Const TIMING_FALL_MODE As String = "8;"
Public Const TIMING_ONOFF_MODE As String = "9;"
Public TotalPattern As Integer

Public ErrorCode As Integer
Public Const ERROR_OSC_TIMEOUT As Integer = 111
Public Const ERROR_VOLTAGE_VALUE As Integer = 112
Public Const ERROR_VOLTAGE_RISE As Integer = 113
Public Const ERROR_PG_TIMEOUT As Integer = 114
Public Const ERROR_EXCEL_REPORT_DEMO As Integer = 115
Public Const ERROR_DOWNLOAD_FILE As Integer = 116
Public Const ERROR_TIMEOUT As Integer = 217
Public Const ERROR_STOPPED_BY_USER As Integer = 118
Public Const ERROR_UNDEFINED As Integer = 119
Public Const ERROR_PROCESS As Integer = 120


Public DeviceStatus As Byte
Public CurrentVoltage As Double
Public CurrentRiseTime As Double

Public HttpPort As String

Public Const MyVendorID As String = "&H0483"
Public Const MyProductID As String = "&H5750"
Dim PreparsedData As Long
Dim Capabilities As HIDP_CAPS
Public timeout As Boolean
Public TimeCount As Byte


Public Sub Check_Number(ByRef obj As VB.TextBox, min As Long, max As Long)
    If IsNumeric(obj.Text) Then
        If CLng(obj.Text) > max Then
            obj.Text = max
        ElseIf CLng(obj.Text) < min Then
            obj.Text = min
        End If
        obj.SelStart = Len(obj.Text)
        PreNumber = CLng(obj.Text)
    ElseIf obj.Text = "" Then
        obj.Text = ""
    ElseIf obj.Text = "-" Then
        obj.Text = "-"
    Else
        obj.Text = CStr(PreNumber)
        obj.SelStart = Len(obj.Text)
    End If
End Sub

Public Function Check_DataOk() As Boolean
    Check_DataOk = True
    If CLng(Timing.txtOn.Text) < (CLng(Timing.txtT2.Text) + CLng(Timing.txtBLOff.Text)) _
    Or CLng(Timing.txtOn.Text) < (CLng(Timing.txtT2.Text) + CLng(Timing.txtT5.Text)) _
    Or CLng(Timing.txtOn.Text) < (CLng(Timing.txtT5.Text) + CLng(Timing.txtBLOn.Text)) _
    Or CLng(Timing.txtOn.Text) < (CLng(Timing.txtBLOn.Text) + CLng(Timing.txtBLOff.Text)) _
    Or CLng(Timing.txtOff.Text) < (0 - CLng(Timing.txtT2.Text) - CLng(Timing.txtT5)) _
    Or CLng(Timing.txtOff.Text) <= (0 - CLng(Timing.txtT2.Text)) _
    Or CLng(Timing.txtOff.Text) <= (0 - CLng(Timing.txtT5.Text)) Then
        Check_DataOk = False
    End If
End Function


Public Sub File_Init()
    Dim MyTime As String
    Dim i As Integer
    Dim fso As New FileSystemObject
    MyTime = Date
    MyTime = Replace(MyTime, "/", "_")
On Error Resume Next
    MkDir "C:\LOG"
    MkDir "C:\LOG\Oscilloscope\"
    MkDir App.path & "\" & "Output"
    MkDir App.path & "\" & "Waveform"
On Error GoTo 0
    LogFilePath = "C:\LOG\Oscilloscope\" + MyTime + ".txt"
End Sub

Public Sub SetProcessID()
    Dim ret As Integer
    Dim product As String
    Dim sample As String * 4
    Dim completed As String * 4
    Call ReadCurrentProcess(CurrentProcess, ProcessID, product)
    If CurrentProcess > 0 Then
        ret = MsgBox("    上次量测未全部完成，是否接着量测，或是重新量测？" + Chr(10) + Chr(13) + "        确定:    继续量测" + Chr(10) + Chr(13) + "        取消:    重新量测", vbOKCancel + vbQuestion, "  警告!")
        If ret = 2 Then
            CurrentProcess = 0
            ProcessID = CLng(Timer)
            CompletedSample = 0
            Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
            Call WriteOtherINI
        Else
            ProductID = product
            frmMain.txtProductID.Text = ProductID
            frmMain.txtProductID.ForeColor = RGB(0, 0, 0)
            frmMain.txtProductID.FontBold = True
            If CurrentProcess = 4 Or CurrentProcess = 9 Or CurrentProcess = 14 Then
                CurrentProcess = CurrentProcess - 1     'if inrush, work from pre-process, for adj voltage
            End If
            Call ReadOtherINI
        End If
    Else
        Call GetPrivateProfileString("PROCESS SCHEDULE", "Completed Sample", "", completed, 4, App.path & "\" & "oscilloscope.ini")
        If CByte(completed) = 0 Then            'if CS or ES sample1 then re-measue
            GoTo remeasure
        End If
        If ProcessID <> 0 Then
            Call GetPrivateProfileString("PROCESS SCHEDULE", "Sample", "", sample, 4, App.path & "\" & "oscilloscope.ini")
            ret = MsgBox("    开始量测" & product & "的第 " & CStr(CByte(sample) + 1) & " 片Sample？" + Chr(10) + Chr(13) + "        确定:    继续量测" + product + Chr(10) + Chr(13) + "        取消:    量测其他模组", vbOKCancel + vbQuestion, "  警告!")
            If ret = 2 Then
                CurrentProcess = 0
                ProcessID = CLng(Timer)
                CompletedSample = 0
                Call WriteOtherINI
                Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
            Else
                ProductID = product
                frmMain.txtProductID.Text = ProductID
                frmMain.txtProductID.ForeColor = RGB(0, 0, 0)
                frmMain.txtProductID.FontBold = True
                Call ReadOtherINI
            End If
        Else
remeasure:
            CurrentProcess = 0
            ProcessID = CLng(Timer)
            CompletedSample = 0
            Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
            Call WriteOtherINI
        End If
    End If
End Sub

Public Sub IncreaseSample()
    Dim INIPath, SectionName, KeyName As String
    INIPath = App.path & "\" & "oscilloscope.ini"
    
    If frmMain.cmbPhase.ListIndex <> 0 Then
        If frmMain.cmbSample.ListIndex < frmMain.cmbSample.ListCount - 1 Then
            frmMain.cmbSample.ListIndex = frmMain.cmbSample.ListIndex + 1
        Else
            frmMain.cmbSample.ListIndex = 0
        End If
        SectionName = "PROCESS SCHEDULE"
        KeyName = "Sample"
        WritePrivateProfileString SectionName, KeyName, CStr(frmMain.cmbSample.ListIndex), INIPath
    End If
End Sub

Public Sub DisableComponents()
    frmMain.fraPATTERN.Enabled = False
    frmMain.FraINFO.Enabled = False
    frmMain.txtProductID.Locked = True
    frmMain.cmdAutoMeasure.Enabled = False
End Sub

Public Sub EnableComponents()
    frmMain.fraPATTERN.Enabled = True
    frmMain.FraINFO.Enabled = True
    frmMain.txtProductID.Locked = False
    frmMain.cmdAutoMeasure.Enabled = True
End Sub

Public Function Is_AllDeviceReady() As Boolean
    Dim temp As String
    Is_AllDeviceReady = True
    temp = ""
    On Error GoTo error
    frmMain.Tvc1.WriteString ("*IDN?")
    temp = frmMain.Tvc1.ReadString
    If temp = "" Then
        frmMain.lblOSCILLOSCOPENAME.Caption = "No Oscilloscope"
        frmMain.lblOSCILLOSCOPENAME.ForeColor = RGB(255, 0, 0)
        PrintLog "Oscilloscope out ot hand, please re-connect, and restart application"
        Is_AllDeviceReady = False
    End If
    If Not FindPG5 Then
        Is_AllDeviceReady = False
    End If
    Exit Function
error:
    frmMain.lblOSCILLOSCOPENAME.Caption = "No Oscilloscope"
    frmMain.lblOSCILLOSCOPENAME.ForeColor = RGB(255, 0, 0)
    PrintLog "Oscilloscope out ot hand, please re-connect, and restart application"
    Is_AllDeviceReady = False
End Function

Public Sub DetectHID()
    Dim ErrorStr As String

    DeviceStatus = 255
    If Not FindTheHid Then
        DeviceStatus = DeviceStatus - 1
    End If

    If DeviceStatus <> 255 Then
        If (DeviceStatus And 1) <> 1 Then
            ErrorStr = ErrorStr + " & Control Board"
        End If
        If (DeviceStatus And 2) <> 2 Then
            ErrorStr = ErrorStr + " & Oscilloscope"
        End If
        If (DeviceStatus And 4) <> 4 Then
            ErrorStr = ErrorStr + " & PG"
        End If
        MsgBox "No " + ErrorStr + " connected, please check them and restart UI", vbOKOnly, "  Error!"
        End
    End If
End Sub

Public Sub DetectDevice()
    Dim ErrorStr As String
    
    'flag all device bit = 1
    DeviceStatus = 255
    If FindOscilloscope Then
        If FindTheHid Then
            'FindPG5() must after FindTheHid()
            If Not FindPG5 Then
                'flag PG5 status bit = 0
                DeviceStatus = DeviceStatus - 4
            End If
        Else
            'flag HID Device status bit = 0
            DeviceStatus = DeviceStatus - 1
        End If
    Else
        'flag Oscilloscope status bit = 0;
        DeviceStatus = DeviceStatus - 2
    End If

    If DeviceStatus <> 255 Then
        If (DeviceStatus And 1) <> 1 Then
            ErrorStr = ErrorStr + " & Control Board"
        End If
        If (DeviceStatus And 2) <> 2 Then
            ErrorStr = ErrorStr + " & Oscilloscope"
        End If
        If (DeviceStatus And 4) <> 4 Then
            ErrorStr = ErrorStr + " & PG"
        End If
        MsgBox "No " + ErrorStr + " connected, please check them and restart UI", vbOKOnly, "  Error!"
        End
    End If
End Sub

Public Sub UI_Init()
    Dim i As Integer
    For i = 0 To TotalPattern
        frmMain.ComBLACK.AddItem i
        frmMain.ComWHITE.AddItem i
        frmMain.ComVSTRIP.AddItem i
        frmMain.ComHEAVY.AddItem i
    Next
    
    frmMain.ComBLACK.ListIndex = 0
    frmMain.ComWHITE.ListIndex = 1
    frmMain.ComVSTRIP.ListIndex = 14
    frmMain.ComHEAVY.ListIndex = 20
    
    frmMain.cmbChannelSel1.ListIndex = 0
    frmMain.cmbChannelSel2.ListIndex = 3
        
    frmMain.cmbPanelVol.ListIndex = 0
    frmMain.cmbPhase.ListIndex = 0
    frmMain.cmbSample.ListIndex = 0
    
On Error GoTo 0
    ProductID = "NA"
    PanelVoltage = CDbl(Trim$(Mid$(frmMain.cmbPanelVol.Text, 1, 5)))
    AutoMeasureFinish = False
End Sub


Public Sub PG5_Init()
    Call WriteReport(PG_INIT_MODE)
End Sub

Public Sub PG5_Exit()
    Call WriteReport(PG_EXIT_MODE)
End Sub

Public Function Is_PG5_Controled() As Boolean
    Dim status As Integer
    status = PG5_ReadData(PG_MODE_ADDRESS)
    If (status And 2) <> 2 Then
        Is_PG5_Controled = False
    Else
        Is_PG5_Controled = True
    End If
End Function

Public Function PG5_WritePattern(pattern As Integer) As Boolean
    Call WriteReport(PG_WRITE_PATT + CStr(pattern))
    Sleep 10
    If PG5_ReadData(PG_PATTERN_ADDRESS) = pattern Then
        PG5_WritePattern = True
    Else
        PG5_WritePattern = False
    End If
End Function

Public Function PG5_ReadData(address As Byte) As Integer
    Dim ReceivedData As String
    Call WriteReport(PG_READ_MODE + CStr(address))
    Sleep 100
    Call ReadReport(ReceivedData)
    If Mid$(ReceivedData, 1, 1) = "R" Then
        PG5_ReadData = Asc(Mid(ReceivedData, 2, 1))
    Else
        PG5_ReadData = -256   '11111111 00000000
'        MsgBox "PG5 out of control, app close.", vbOKOnly, "  Error!"
    End If
End Function

Public Function FindPG5() As Boolean
    Dim ReceivedData As String
    FindPG5 = False
    
    Call WriteReport(PG_READ_MODE)
    Call ReadReport(ReceivedData)
    If Mid$(ReceivedData, 1, 1) = "R" Then          'Connected to PG5 and read data from PG5
        frmMain.lblPG5Ver.ForeColor = RGB(0, 0, 255)
        frmMain.lblPG5Ver.Caption = "PG5 Ver " + CStr(Asc(Mid(ReceivedData, 2, 1)))
        TotalPattern = PG5_ReadData(PG_TOTALPATTERN_ADDRESS)
        If TotalPattern > 0 Then
            FindPG5 = True
        Else
            TotalPattern = 0
        End If
    ElseIf Mid$(ReceivedData, 1, 1) = "3" Then
        frmMain.lblPG5Ver.Caption = "No PG"
        frmMain.lblPG5Ver.ForeColor = RGB(255, 0, 0)
        PrintLog "Can not receive data from PG, please reboot PG, and restart application"
    Else
        frmMain.lblCONNECTION.Caption = "No Device"
        frmMain.lblCONNECTION.ForeColor = RGB(255, 0, 0)
        PrintLog "Can not receive data from device, please reboot device, and restart application"
    End If
End Function

Public Function FindOscilloscope() As Boolean
    Dim err As Long
    'Oscillosope variable
    Dim Sesn, Vi, RetCnt As Long
    Dim Desc As String * 40
    
    Call viOpenDefaultRM(Sesn)
    err = viFindRsrc(Sesn, "USB::?*INSTR", Vi, RetCnt, Desc)
    viClose (Vi)
    viClose (Sesn)
    frmMain.Tvc1.Descriptor = Desc
    
    frmMain.Tvc1.WriteString ("*IDN?")
    frmMain.lblOSCILLOSCOPENAME.ForeColor = RGB(0, 0, 255)
    frmMain.lblOSCILLOSCOPENAME.Caption = frmMain.Tvc1.ReadString
    If frmMain.lblOSCILLOSCOPENAME.Caption <> "" Then
        FindOscilloscope = True
    End If
End Function

Public Function SetTekVisa_Init() As Boolean
    Dim PanelVol As Double
    Dim CHxScale As String
    PanelVol = CDbl(Trim(Left(frmMain.cmbPanelVol.Text, 5)))
    CHxScale = CStr(CLng(PanelVol / 2 - 0.1))
    frmMain.Tvc1.WriteString ("*RST")       'Reset osc
    Sleep 1000
'    frmMain.Tvc1.WriteString ("CLEARMenu")        'MENU OFF
    frmMain.Tvc1.WriteString ("ETHERnet:NETWORKCONFig MANual")
    frmMain.Tvc1.WriteString ("ETHERnet:IPADDress '192.168.1.254'")
    frmMain.Tvc1.WriteString ("HORizontal:RECOrdlength 1E6")
    'set waveform light 85%
    frmMain.Tvc1.WriteString ("DISplay:INTENSITy:WAVEform 85")

    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel1.Text + ":BANdwidth FULl")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":BANdwidth FULl")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel1.Text + ":COUPling DC")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":COUPling DC")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel1.Text + ":LABel 'VCC'")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":LABel 'Current'")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel1.Text + ":POSition 0")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":POSition -3")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel1.Text + ":SCAle " + CHxScale)

    
    frmMain.Tvc1.WriteString ("SELect:CH1 OFF")
    frmMain.Tvc1.WriteString ("SELect:" + frmMain.cmbChannelSel1.Text + " ON")
    frmMain.Tvc1.WriteString ("SELect:" + frmMain.cmbChannelSel2.Text + " ON")
    frmMain.Tvc1.WriteString ("ETHERnet:HTTPPort " & """" & "81" & """")
    frmMain.Tvc1.WriteString ("ETHERnet:HTTPPort?")
    HttpPort = Replace(frmMain.Tvc1.ReadString, """", "")
    If HttpPort = "" Then
        SetTekVisa_Init = False
        ErrorCode = ERROR_OSC_TIMEOUT
        Exit Function
'        MsgBox "Read oscilloscope error, close UI.", vbOKOnly, "  Error!"
    End If
    SetTekVisa_Init = True
End Function

Public Sub SetTekVisa_Mean()

    frmMain.Tvc1.WriteString ("HORizontal:SCAle 1E-2")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":SCAle 5E-1")
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:SOUrce " + frmMain.cmbChannelSel1.Text)     'Add measurement "1"，source："CH1"
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:TYPe MEAN")        'measure type "mean"(Average)
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:STATE ON")         'Display measurement 1 item
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:SOUrce " + frmMain.cmbChannelSel2.Text)     'Add measurement "2"，source："CH4"
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:TYPe MEAN")        'measure type "mean"(Average)
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:STATE ON")         'Display measurement 2 item
   
End Sub

Public Sub SetTekVisa_Inrush()
    Dim PanelVol As Double
    Dim CHxLevel As String
    PanelVol = CDbl(Trim(Left(frmMain.cmbPanelVol.Text, 5)))
    CHxLevel = CStr(PanelVol * 2 / 3)
    
    frmMain.Tvc1.WriteString ("HORizontal:SCAle 1E-2")
    frmMain.Tvc1.WriteString ("HORizontal:DELay:MODe OFF")
    frmMain.Tvc1.WriteString ("HORizontal:POSition 20")
    frmMain.Tvc1.WriteString (frmMain.cmbChannelSel2.Text + ":SCAle 5E-1")
    frmMain.Tvc1.WriteString ("TRIGger:A:EDGE:SLOpe RISe")
    frmMain.Tvc1.WriteString ("TRIGger:A:EDGE:SOUrce " + frmMain.cmbChannelSel1.Text)
    frmMain.Tvc1.WriteString ("TRIGger:A:LEVel:" + frmMain.cmbChannelSel1.Text + " " + CHxLevel)
    
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:SOUrce " + frmMain.cmbChannelSel1.Text)     'Add measurement "1"，source："CH1"
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:TYPe RISe")        'measure type "mean"(Average)
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS1:STATE ON")         'Display measurement 1 item
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:SOUrce " + frmMain.cmbChannelSel2.Text)     'Add measurement "2"，source："CH4"
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:TYPe MAXimum")        'measure type "mean"(Average)
    frmMain.Tvc1.WriteString ("MEASUrement:MEAS2:STATE ON")         'Display measurement 2 item
   
End Sub

Public Function ReadTekVisaMeasure(ch As String) As String

    frmMain.Tvc1.WriteString ("MEASUrement:MEAS" + ch + ":VALue?")
    ReadTekVisaMeasure = frmMain.Tvc1.ReadString

End Function

Public Function DataProcess_Mean(TargetVoltage As Double) As Boolean
    Dim temp As String
    Dim MeanCurrent As Double
    Dim flag As Integer
    Dim PreVoltage As Double
    Dim WriteData As String
    Dim ReceivedData As String
    Dim PreReceivedData As String
    Dim ImagePath As String
    Dim MeasureFinish As Boolean
    Dim ret As Long
    
'On Error GoTo error
    DataProcess_Mean = False
    MeasureFinish = False
'    WriteData = OSC_MEAN_MODE & frmMain.cmbPanelVol.ListIndex & ";" + CStr(TargetVoltage)
'    Call WriteReport(WriteData)
    
    Call SetTekVisa_Mean
    Sleep 1000
    WriteData = OSC_MEAN_MODE & frmMain.cmbPanelVol.ListIndex & ";" & CStr(TargetVoltage)
    frmMain.Tvc1.WriteString ("ACQUIRE:STATE?")             'Is oscilloscope stoped?   0:stoped, 1:running
    If frmMain.Tvc1.ReadString = "0" Then
        frmMain.Tvc1.WriteString ("FPAnel:PRESS RUnstop")
    End If
    
    Do While (Not MeasureFinish) And (Not timeout)
        DoEvents
        PreVoltage = CDbl(Mid(WriteData, 5))
        Call WriteReport(WriteData)     ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        
        Sleep 6000
        flag = 6
        ReceivedData = ""
        Do While (ReceivedData = "" And flag > 0)
            DoEvents
            Sleep 1000
            ReceivedData = ReadTekVisaMeasure("1")
            flag = flag - 1
        Loop
        'oscilloscope busy ,do not measure finished (---')
        Do While (CDbl(ReceivedData) > 100 And flag > 0)
            DoEvents
            Sleep 1000
            ReceivedData = ReadTekVisaMeasure("1")
            flag = flag - 1
        Loop
        
        If flag = 0 Then
            DataProcess_Mean = False
            ErrorCode = ERROR_OSC_TIMEOUT
   '         PrintLog "Read Oscilloscope data timeout, please check it and re-measure."
            Exit Function
        End If
        
        temp = ReceivedData
        
        If Not timeout Then
            PrintLog "Current Voltage = " + Format(temp, "0.00") + "V"
        Else
            DataProcess_Mean = False
            Exit Function
        End If
        
        CurrentVoltage = CDbl(temp)
        If Abs(CurrentVoltage - TargetVoltage) > VolPrecision Then
            If TargetVoltage - CurrentVoltage + PreVoltage < 0 Or Abs(PreVoltage - CurrentVoltage) > 2 Then
                DataProcess_Mean = False
                ErrorCode = ERROR_VOLTAGE_VALUE
 '               PrintLog "Voltage error, please check it and re-measure."
                Exit Function
            Else
                WriteData = OSC_MEAN_MODE & frmMain.cmbPanelVol.ListIndex & ";" & Format(TargetVoltage - CurrentVoltage + PreVoltage, "0.0000")
 '               frmMain.Text2.Text = frmMain.Text2.Text + CStr(CurrentVoltage) + "  ->  " + WriteData + Chr(13) + Chr(10)
            End If
        Else
            frmMain.Tvc1.WriteString ("FPAnel:PRESS RUnstop")
            Sleep 100
            frmMain.Tvc1.WriteString ("FPAnel:TURN VERTPOS" + Mid$(frmMain.cmbChannelSel1.Text, 3) + ",1")  '消除波形残影
            Sleep 3000
            MeanCurrent = CDbl(ReadTekVisaMeasure("2"))
On Error Resume Next
            MkDir App.path & "\Waveform\" & ProductID & "_" & ProcessID
On Error GoTo 0
            ImagePath = App.path & "\" & "Waveform\" & ProductID & "_" & ProcessID & "\" & frmMain.cmbSample.Text & "_" & ProductID & "_" & Format(TargetVoltage, "0.0") & "V_MEAN_" & CurrentPattern & "_" & CStr(ProcessID) & ".png"
            ret = URLDownloadToFile(0, "http://192.168.1.254:" & HttpPort & "/image.png", ImagePath, 0, 0)
            If ret <> 0 Then
                ErrorCode = ERROR_DOWNLOAD_FILE
                Exit Function
            End If
            Sleep 200
            Call WriteToExcel(frmMain.cmbSample.ListIndex, CurrentProcess, MeanCurrent, ImagePath)
            Sleep 100
            MeasureFinish = True
            DataProcess_Mean = True
            Exit Function
        End If
        Sleep 1000
    Loop
    Exit Function
error:
    TerminateThread VBThreadHandle, ByVal 0&
    CloseHandle VBThreadHandle
    ErrorCode = err.Number
    Call ExitMeasure(ErrorCode)
    err.Clear
    End         '强制结束一切，防止有线程不听话造成进程残留
End Function


Public Function DataProcess_Inrush(Target As String) As Boolean
    Dim RiseTime As Double
    Dim MaxCurrent As Double
    Dim flag, flag2, count As Integer
    Dim PreRiseTime As Double
    Dim WriteData As String
    Dim ret As Long
    Dim ReceivedData As String
    Dim ImagePath As String
    Dim RiseFinish As Boolean
    
    On Error GoTo error
    Call WriteReport(POWER_OFF)
    
    DataProcess_Inrush = False
    CurrentRiseTime = 0
    RiseFinish = False
    flag2 = 0
    Call SetTekVisa_Inrush
    
    WriteData = OSC_INRUSH_MODE + Target
    Do While (Not RiseFinish) And (Not timeout)
        DoEvents
        PreRiseTime = CDbl(Mid(WriteData, 3))
        frmMain.Tvc1.WriteString ("FPAnel:PRESS SINGleseq")
        Sleep 2000
        Call WriteReport(WriteData)     ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        
        Sleep 3000
        flag = 5
        ReceivedData = ""
        Do While (ReceivedData = "" And flag > 0)
            DoEvents
            Sleep 1000
            ReceivedData = ReadTekVisaMeasure("1")
            flag = flag - 1
        Loop
        If flag = 0 Then
            DataProcess_Inrush = False
            ErrorCode = ERROR_OSC_TIMEOUT
 '           PrintLog "Read Oscilloscope data timeout, please check it and re-measure."
            Exit Function
        End If
        
        flag = 3
        'oscilloscope busy ,do not measure finished (---')
        Do While (CDbl(ReceivedData) > 100 And flag > 0)
            DoEvents
            Sleep 1000
            ReceivedData = ReadTekVisaMeasure("1")
            flag = flag - 1
        Loop
        
        If flag = 0 Then                'maybe osc get the falling edge, try 3 more times
            flag2 = flag2 + 1
            If flag2 > 3 Then
                DataProcess_Inrush = False
                ErrorCode = ERROR_OSC_TIMEOUT
                Exit Function
            End If
            GoTo nextloop
        End If
        
        RiseTime = CDbl(ReceivedData) * 1000000
        If Not timeout Then
            PrintLog "Current Rise Time = " + Format(RiseTime, "0.0") + "us"
        Else
            DataProcess_Inrush = False
            Exit Function
        End If
        
        If Abs(RiseTime - Target) <= TimePrecision Then
            MaxCurrent = CDbl(ReadTekVisaMeasure("2"))
            On Error Resume Next
                MkDir App.path & "\" & "Waveform" & "\" & ProductID & "_" & ProcessID
 '               MkDir App.path & "\" & "Output" & "\" & ProductID & "_" & ProcessID
            On Error GoTo 0
            ImagePath = App.path & "\" & "Waveform\" & ProductID & "_" & ProcessID & "\" & frmMain.cmbSample.Text & "_" & ProductID & "_" & Format(TargetVol, "0.0") & "V_INRUSH_" & CStr(ProcessID) & ".png"
            ret = URLDownloadToFile(0, "http://192.168.1.254:" & HttpPort & "/image.png", ImagePath, 0, 0)
            If ret <> 0 Then
                ErrorCode = ERROR_DOWNLOAD_FILE
                Exit Function
            End If
            Sleep 1000
            Call WriteToExcel(frmMain.cmbSample.ListIndex, CurrentProcess, MaxCurrent, ImagePath)
            Sleep 1000
            RiseFinish = True
            DataProcess_Inrush = True
            Exit Function
        Else
            CurrentRiseTime = CurrentRiseTime + RiseTime
            count = count + 1
        End If
        
        If count > 2 Then
            count = 0
            CurrentRiseTime = CurrentRiseTime / 3
            If Target - CurrentRiseTime + PreRiseTime < 0 Then
                DataProcess_Inrush = False
                ErrorCode = ERROR_VOLTAGE_RISE
'                   PrintLog "Rise time error, please check it and re-measure."
                Exit Function
            Else
                PrintLog "Write next Rise Time = " + Format(Target - CurrentRiseTime + PreRiseTime, "0.00") + "us"
                WriteData = OSC_INRUSH_MODE + Format(Target - CurrentRiseTime + PreRiseTime, "0.00")
'                frmMain.Text2.Text = frmMain.Text2.Text + CStr(CurrentRiseTime) + "  ->  " + WriteData + Chr(13) + Chr(10)
            End If
            Sleep 1000
            CurrentRiseTime = 0
        End If
nextloop:
        Call WriteReport(POWER_OFF)
    Loop
    Exit Function
error:
    TerminateThread VBThreadHandle, ByVal 0&
    CloseHandle VBThreadHandle
    ErrorCode = err.Number
    Call ExitMeasure(ErrorCode)
    err.Clear
    End         '强制结束一切，防止有线程不听话造成进程残留
End Function


Public Sub WriteINI(process As Integer, id As Long, product As String, samp As Byte)
    Dim i As Byte
    Dim INIPath, SectionName, KeyName As String
    
    If process < 0 Or process > 15 Then
        MsgBox "Write ini file error!", vbOKOnly, "  Error!"
    End If
    INIPath = App.path & "\" & "oscilloscope.ini"

    SectionName = "PROCESS SCHEDULE"
    KeyName = "Product ID"
    WritePrivateProfileString SectionName, KeyName, product, INIPath
    
    KeyName = "Current Process"
    WritePrivateProfileString SectionName, KeyName, CStr(process), INIPath

    KeyName = "Process ID"
    WritePrivateProfileString SectionName, KeyName, CStr(id), INIPath
    
    KeyName = "Completed Sample"
    WritePrivateProfileString SectionName, KeyName, CStr(samp), INIPath
    
End Sub

Public Sub ReadINI(process As Integer, id As Long, product As String)
    Dim idd As String * 8                         'must * 8(=nsize1 in GetPrivateProfileString)
    Dim value As String * 4                         'must * 4(=nsize2 in GetPrivateProfileString)
    Dim pro As String * 16                          'must * 13(=nsize3 in GetPrivateProfileString)
    Dim INIPath, SectionName, KeyName As String
    Dim nSize1, nSize2, nSize3 As Integer
    Dim i As Integer
    i = 1
    nSize1 = 8
    nSize2 = 4
    nSize3 = 16

    INIPath = App.path & "\" & "oscilloscope.ini"
    
    SectionName = "PROCESS SCHEDULE"
    KeyName = "Product ID"
    GetPrivateProfileString SectionName, KeyName, "", pro, nSize3, INIPath
    
    KeyName = "Current Process"
    GetPrivateProfileString SectionName, KeyName, "", value, nSize2, INIPath
    
    KeyName = "Process ID"
    GetPrivateProfileString SectionName, KeyName, "", idd, nSize1, INIPath
    
    process = CLng(value)
    id = CLng(idd)
    product = ""
    Do While Asc(Mid(pro, i, 1)) > 31
        product = product + Mid$(pro, i, 1)
        i = i + 1
    Loop
End Sub

Public Sub ReadOtherINI()
    '必须分开定义，否则无法写入数据到变量
    Dim rs As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim pv As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim ph As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim sp As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim hv As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim wh As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim bl As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim vs As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim cs As String * 8                       'must * 8(=nsize in GetPrivateProfileString)
    Dim INIPath, SectionName, KeyName As String
    Dim nSize, ret As Integer
    Dim i As Integer
    nSize = 8

    INIPath = App.path & "\" & "oscilloscope.ini"
    
    SectionName = "PROCESS SCHEDULE"
    KeyName = "Panel Voltage"
    ret = GetPrivateProfileString(SectionName, KeyName, "", pv, nSize, INIPath)
    
    KeyName = "Rise Time"
    ret = GetPrivateProfileString(SectionName, KeyName, "", rs, nSize, INIPath)
    
    KeyName = "Phase"
    ret = GetPrivateProfileString(SectionName, KeyName, "", ph, nSize, INIPath)
    
    KeyName = "Sample"
    ret = GetPrivateProfileString(SectionName, KeyName, "", sp, nSize, INIPath)
    
    KeyName = "Heavy Pattern"
    ret = GetPrivateProfileString(SectionName, KeyName, "", hv, nSize, INIPath)
    
    KeyName = "White Pattern"
    ret = GetPrivateProfileString(SectionName, KeyName, "", wh, nSize, INIPath)
    
    KeyName = "Black Pattern"
    ret = GetPrivateProfileString(SectionName, KeyName, "", bl, nSize, INIPath)
    
    KeyName = "V_Strip Pattern"
    ret = GetPrivateProfileString(SectionName, KeyName, "", vs, nSize, INIPath)

    KeyName = "Completed Sample"
    ret = GetPrivateProfileString(SectionName, KeyName, "", cs, nSize, INIPath)
    
With frmMain
    .cmbPhase.ListIndex = CLng(ph)
    .ComHEAVY.ListIndex = CLng(hv)
    .ComWHITE.ListIndex = CLng(wh)
    .ComBLACK.ListIndex = CLng(bl)
    .ComVSTRIP.ListIndex = CLng(vs)
    .cmbSample.ListIndex = CLng(sp)
    TargetRiseTime = CLng(rs)
    .txtRiseTime.Text = CStr(TargetRiseTime)
    .cmbPanelVol.ListIndex = CLng(pv)
    PanelVoltage = CDbl(Trim(Mid$(.cmbPanelVol.Text, 1, 5)))
    CompletedSample = CByte(cs)
End With
End Sub

Public Sub WriteOtherINI()
    Dim INIPath, SectionName, KeyName As String

    INIPath = App.path & "\" & "oscilloscope.ini"
With frmMain
    SectionName = "PROCESS SCHEDULE"
    KeyName = "Panel Voltage"
    WritePrivateProfileString SectionName, KeyName, CStr(.cmbPanelVol.ListIndex), INIPath
    
    KeyName = "Rise Time"
    WritePrivateProfileString SectionName, KeyName, .txtRiseTime.Text, INIPath
    
    KeyName = "Phase"
    WritePrivateProfileString SectionName, KeyName, CStr(.cmbPhase.ListIndex), INIPath
    
    KeyName = "Sample"
    WritePrivateProfileString SectionName, KeyName, CStr(.cmbSample.ListIndex), INIPath
    
    KeyName = "Heavy Pattern"
    WritePrivateProfileString SectionName, KeyName, CStr(.ComHEAVY.ListIndex), INIPath

    KeyName = "White Pattern"
    WritePrivateProfileString SectionName, KeyName, CStr(.ComWHITE.ListIndex), INIPath
    
    KeyName = "Black Pattern"
    WritePrivateProfileString SectionName, KeyName, CStr(.ComBLACK.ListIndex), INIPath
    
    KeyName = "V_Strip Pattern"
    WritePrivateProfileString SectionName, KeyName, CStr(.ComVSTRIP.ListIndex), INIPath
    
End With
End Sub

Public Function ReadCurrentProcess(process As Integer, id As Long, product As String) As Integer               'Scan INI file
    Dim INIPath As String
    INIPath = App.path & "\" & "oscilloscope.ini"
    If Dir(INIPath) = "" Then
        Call WriteINI(0, 0, "", 0)
        process = 0 'new process
        id = 0
        product = ""
    Else
        Call ReadINI(process, id, product)
    End If
End Function


Public Sub ExitMeasure(code As Integer)
    Call WriteReport(PG_EXIT_MODE)
    Sleep 10
    Call WriteReport(POWER_OFF)
'    frmMain.ProgressBar1.Visible = False
    frmMain.ProgressBar1.value = 0
    Select Case code
        Case 0
        Case ERROR_PG_TIMEOUT
            PrintLog "PG out ot hand, Measure was failed, Please restart PG."
        Case ERROR_OSC_TIMEOUT
            PrintLog "Read Oscilloscope data timeout, please check it and re-measure."
        Case ERROR_VOLTAGE_VALUE
            PrintLog "Voltage error, please check it and re-measure."
        Case ERROR_VOLTAGE_RISE
            PrintLog "Rise time error, please check it and re-measure."
        Case ERROR_STOPPED_BY_USER
            PrintLog "Measurement was stopped by user."
        Case ERROR_TIMEOUT
            PrintLog "Measurement time out."
        Case ERROR_EXCEL_REPORT_DEMO
            PrintLog "There is no 'Report Demo', Please make it first!"
        Case ERROR_DOWNLOAD_FILE
            PrintLog "Download wavefirm screen failed!"
        Case Else
            PrintLog "Unknown error, error code = " & CStr(code) & ", application close."
    End Select
    PrintEndLog
End Sub


Public Sub AutoMeasure()
    Dim currentsample As String
With frmMain
    AutoMeasureFinish = False
    Call PrintStartLog
    If Not SetTekVisa_Init Then
        CurrentProcess = ERROR_PROCESS
    End If
    
    If Not Excel_Init Then          'Excel_Init() Must behind SetProcessID
        CurrentProcess = ERROR_PROCESS
    End If
    
    Do While Not AutoMeasureFinish
        DoEvents
        TargetVol = PanelVoltage
        If CurrentProcess > 4 And CurrentProcess < 10 Then
            TargetVol = PanelVoltage * 0.9
        ElseIf CurrentProcess >= 10 Then
            TargetVol = PanelVoltage * 1.1
        End If
        If CurrentProcess <= 15 Then
            .ProgressBar1.Visible = True
            .ProgressBar1.value = CurrentProcess
        End If
        
        Select Case CurrentProcess
            Case 0
                If PG5_WritePattern(CLng(Trim(.ComWHITE.Text))) Then
                    CurrentPattern = "WHITE"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process WHITE 100% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 1
                If PG5_WritePattern(CLng(Trim(.ComVSTRIP.Text))) Then
                    CurrentPattern = "VSTRIP"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process VSTRIP 100% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 2
                If PG5_WritePattern(CLng(Trim(.ComHEAVY.Text))) Then
                    CurrentPattern = "HEAVY"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process HEAVY 100% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 3
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    CurrentPattern = "BLACK"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process BLACK 100% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 4
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    If Not DataProcess_Inrush(CStr(TargetRiseTime)) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process BLACK 100% Inrush completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 5
                If PG5_WritePattern(CLng(Trim(.ComWHITE.Text))) Then
                    CurrentPattern = "WHITE"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process WHITE 90% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 6
                If PG5_WritePattern(CLng(Trim(.ComVSTRIP.Text))) Then
                    CurrentPattern = "VSTRIP"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process VSTRIP 90% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 7
                If PG5_WritePattern(CLng(Trim(.ComHEAVY.Text))) Then
                    CurrentPattern = "HEAVY"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process HEAVY 90% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 8
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    CurrentPattern = "BLACK"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process BLACK 90% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 9
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    If Not DataProcess_Inrush(CStr(TargetRiseTime)) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process BLACK 90% Inrush completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 10
                If PG5_WritePattern(CLng(Trim(.ComWHITE.Text))) Then
                    CurrentPattern = "WHITE"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
 '                       Call WriteOtherINI
                        PrintLog ("Process WHITE 110% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 11
                If PG5_WritePattern(CLng(Trim(.ComVSTRIP.Text))) Then
                    CurrentPattern = "VSTRIP"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process VSTRIP 110% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 12
                If PG5_WritePattern(CLng(Trim(.ComHEAVY.Text))) Then
                    CurrentPattern = "HEAVY"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process HEAVY 110% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 13
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    CurrentPattern = "BLACK"
                    If Not DataProcess_Mean(TargetVol) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process BLACK 110% Mean completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 14
                If PG5_WritePattern(CLng(Trim(.ComBLACK.Text))) Then
                    If Not DataProcess_Inrush(CStr(TargetRiseTime)) Then
                        CurrentProcess = ERROR_PROCESS
                    Else
                        CurrentProcess = CurrentProcess + 1
                        
                        Call WriteINI(CurrentProcess, ProcessID, ProductID, CompletedSample)
'                        Call WriteOtherINI
                        PrintLog ("Process BLACK 110% Inrush completed.")
                    End If
                Else
                    ErrorCode = ERROR_PG_TIMEOUT
                    CurrentProcess = ERROR_PROCESS
                End If
            Case 15
                CurrentProcess = 0
                AutoMeasureFinish = True
On Error Resume Next
                xlsBook.Close
                Set xlsBook = Nothing
                xlsApp.Quit
                Set xlsApp = Nothing
On Error GoTo 0
                Call ExitMeasure(0)
                Call EnableComponents
                'if phase = cs, clear ProcessID & module name
                If frmMain.cmbPhase.ListIndex = 0 Then          'CS REPORT
                    ProcessID = 0
                    Call WriteINI(0, 0, "", 0)   'reset process file
                    PrintLog ("All measurement was completed.")
                    MsgBox "  All measurement was completed.", vbOKOnly + vbInformation, "   Completed!"
                Else                                               'ES REPORT
                    'measure next sample
                    CompletedSample = CompletedSample + 2 ^ CByte(frmMain.cmbSample.ListIndex)
                    If (CompletedSample And 7) = 7 Then     '3pcs all completed
                        CompletedSample = 0
                        Call IncreaseSample
                        Call WriteINI(0, 0, "", 0)   'reset process file
                        PrintLog ("All measurement was completed.")
                        MsgBox "  All measurement was completed.", vbOKOnly + vbInformation, "   Completed!"
                    Else
                        currentsample = Mid$(frmMain.cmbSample.Text, 2, 1)
                        PrintLog (ProductID & "的第 " & currentsample & " 片Sample量测完成")
                        Call IncreaseSample
                        Call WriteINI(0, ProcessID, ProductID, CompletedSample)
                        MsgBox ProductID & "的第 " & currentsample & " 片Sample量测完成", vbOKOnly + vbInformation, " 提示！"
                    End If
'                    Call WriteOtherINI
                End If
                frmMain.Timer1.Enabled = False
            Case Else
On Error Resume Next
                xlsBook.Close
                Set xlsBook = Nothing
                xlsApp.Quit
                Set xlsApp = Nothing
On Error GoTo 0
                Call ExitMeasure(ErrorCode)
                Call EnableComponents
                frmMain.cmdSTOP.Enabled = True
                frmMain.Timer1.Enabled = False
                frmMain.Enabled = True
                Exit Sub
        End Select
    Loop
End With
End Sub


Public Sub PrintStartLog()
With frmMain
    Open LogFilePath For Append As #1
    Print #1, Chr(10) + Chr(13)
    Print #1, "[" + CStr(Format(Time, "hh:mm:ss")) + "]==> //************************** Start Auto Measure *******************************//" + Chr(10) + Chr(13)
    Print #1, "[Module Name:]  ==> " + ProductID
    Print #1, "[Panel Voltage:]==> " + .cmbPanelVol.Text
    Print #1, Chr(10) + Chr(13)
    Close #1
    .txtLog.Text = .txtLog.Text + vbCrLf + "==> Start Auto Measure" + vbCrLf
    .txtLog.SelStart = Len(.txtLog.Text) - 1
End With
End Sub

Public Sub PrintEndLog()
With frmMain
    Open LogFilePath For Append As #1
    Print #1, Chr(10) + Chr(13)
    Print #1, "[" + CStr(Format(Time, "hh:mm:ss")) + "]==> //****************** Exit Auto Measure ***********************//"
    Print #1, Chr(10) + Chr(13)
    Close #1
    .txtLog.Text = .txtLog.Text + "==> Exit Auto Measure" + vbCrLf
    .txtLog.SelStart = Len(.txtLog.Text) - 1
End With
End Sub

Public Sub PrintLog(log As String)
With frmMain
    Open LogFilePath For Append As #1
    Print #1, "[" + CStr(Format(Time, "hh:mm:ss")) + "]==> " + log
    Close #1
    .txtLog.Text = .txtLog.Text + log + vbCrLf
    'Scroll to the bottom of the list box.
    .txtLog.SelStart = Len(.txtLog.Text) - 1
End With
End Sub



Public Function Excel_Init() As Boolean
    Dim filename As String
    Dim outpath As String
    Dim reportname As String
    Excel_Init = True
On Error Resume Next
    xlsBook.Close
    Set xlsBook = Nothing
    xlsApp.Quit
    Set xlsApp = Nothing
    outpath = App.path & "\" & "Output" & "\" & ProductID & "_" & ProcessID
    MkDir outpath
On Error GoTo 0
    If frmMain.cmbPhase.ListIndex = 1 Then                      'ES
        filename = App.path & "\ReportDemo\ES.xls"
        reportname = outpath + "\Design_Verification_Report_ES_Part_A.xls"
        If Not isWorkbookOpen(reportname) Then
            If Not isWorkbookExist(reportname) Then
                If Not isWorkbookExist(filename) Then
                    ErrorCode = ERROR_EXCEL_REPORT_DEMO
                    Excel_Init = False
'                    MsgBox "There is no 'Report Demo', Please make it first!", vbOKOnly, "  Error!"
                    Exit Function
                Else
                    Set xlsApp = CreateObject("excel.application")
                    xlsApp.Visible = False
                    Set xlsBook = xlsApp.Workbooks.Open(filename)
                End If
                
                xlsBook.SaveAs (reportname)
On Error Resume Next
                xlsBook.Close
                Set xlsBook = Nothing
                xlsApp.Quit
                Set xlsApp = Nothing
On Error GoTo 0
            End If
            
            Set xlsApp = CreateObject("excel.application")
            xlsApp.Visible = False
            Set xlsBook = xlsApp.Workbooks.Open(reportname)
        End If
    Else                                                        'CS
        filename = App.path & "\ReportDemo\CS.xls"
        reportname = outpath + "\Design_Verification_Report_CS_Part_A.xls"
        If Not isWorkbookOpen(reportname) Then
            If Not isWorkbookExist(reportname) Then
                If Not isWorkbookExist(filename) Then
                    ErrorCode = ERROR_EXCEL_REPORT_DEMO
                    Excel_Init = False
'                    MsgBox "There is no 'Report Demo', Please make it first!", vbOKOnly, "  Error!"
                    Exit Function
                Else
                    Set xlsApp = CreateObject("excel.application")
                    xlsApp.Visible = False
                    Set xlsBook = xlsApp.Workbooks.Open(filename)
                End If
                
                xlsBook.SaveAs (reportname)
On Error Resume Next
                xlsBook.Close
                Set xlsBook = Nothing
                xlsApp.Quit
                Set xlsApp = Nothing
On Error GoTo 0
            End If
            
            Set xlsApp = CreateObject("excel.application")
            xlsApp.Visible = False
            Set xlsBook = xlsApp.Workbooks.Open(reportname)
        End If
    End If
End Function


Public Function isWorkbookOpen(fPathName As String) As Boolean
    Dim xlApp As Excel.Application
    Dim xlBook As Workbook
    Dim i
    Dim errNo
    isWorkbookOpen = False
    
    On Error Resume Next
    Set xlApp = CreateObject("Excel.Application")
    Set xlApp = GetObject(fPathName).Application   '沽刚莉Excel癸禜
    errNo = err.Number
    On Error GoTo 0
    If (errNo <> 0) Then    'fPathName not exist or unlawfulness
        Exit Function
    Else
        If (xlApp.Workbooks.count > 0) Then
            For i = 1 To xlApp.Workbooks.count
                Set xlBook = xlApp.Workbooks(i)
                'If xlBook.Name = fPathName Then        'only compare filename
                If UCase(xlBook.FullName) = UCase(fPathName) Then        'compare full path
                    isWorkbookOpen = True
                    Set xlsBook = xlApp.Workbooks(i)
                    Set xlBook = Nothing
                    Exit For
                End If
                Set xlBook = Nothing
            Next
        End If
        Set xlApp = Nothing
    End If
End Function


Public Function isWorkbookExist(fPathName As String) As Boolean
        isWorkbookExist = False
        
        Dim xlApp As Excel.Application
 '       Dim xlBook As Workbook
        Dim errNo
        
        On Error Resume Next
        Set xlApp = CreateObject("Excel.Application")
        Set xlApp = GetObject(fPathName).Application   '沽刚莉Excel癸禜
        errNo = err.Number
        On Error GoTo 0
        If (errNo <> 432) Then   'fPathName not exist or unlawfulness
            isWorkbookExist = True
        Else
            xlApp.Quit
            Set xlApp = Nothing
        End If
End Function


Public Sub WriteToExcel(sample As Integer, process As Integer, value As Double, image As String)
    
    Dim pic As Object
    Set xlsSheetValue = xlsBook.Sheets(3 + sample * 2)           'value sheet
    Set xlsSheetImage = xlsBook.Sheets(4 + sample * 2)          'Image sheet
     
    Select Case process
        Case 0                  'TYP WHITE
            xlsSheetValue.Range("D39").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("B16").Select
        Case 1                  'TYP V-STRIP
            xlsSheetValue.Range("D41").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("J16").Select
        Case 2                  'TYP Heavy
            xlsSheetValue.Range("D42").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("B29").Select
        Case 3                  'TYP BLACK
            xlsSheetValue.Range("D40").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("D16").Select
        Case 4                  'TYP INRUSH
            xlsSheetValue.Range("D34").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("B3").Select
        Case 5                  '90% WHITE
            xlsSheetValue.Range("D43").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("D29").Select
        Case 6                  '90% V_STRIP
            xlsSheetValue.Range("D45").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("B43").Select
        Case 7                  '90% HEAVY
            xlsSheetValue.Range("D46").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("D43").Select
        Case 8                  '90% BLACK
            xlsSheetValue.Range("D44").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("J29").Select
        Case 9                  '90% INRUSH
            xlsSheetValue.Range("D35").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("D3").Select
        Case 10                  '110% WHITE
            xlsSheetValue.Range("D47").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("J43").Select
        Case 11                     '110% V-STRIP
            xlsSheetValue.Range("D49").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("D58").Select
        Case 12                     '110% HEAVY
            xlsSheetValue.Range("D50").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("J58").Select
        Case 13                     '110% BLACK
            xlsSheetValue.Range("D48").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("B58").Select
        Case 14                     '110% INRUSH
            xlsSheetValue.Range("D36").value = Format(value, "0.000")
            xlsSheetImage.Activate
            xlsSheetImage.Range("J3").Select
    End Select
    
'    Do While Dir(image) = ""
'        DoEvents
'    Loop
    Set pic = xlsSheetImage.Pictures.Insert(image)
    pic.ShapeRange.LockAspectRatio = True
    pic.ShapeRange.Width = 244
    xlsBook.Save
End Sub


Sub GetExcel()
   Dim MyXL As Object   '用于存放
                        'Microsoft Excel 引用的变量。
   Dim ExcelWasNotRunning As Boolean   '用于最后释放的标记。

'测试 Microsoft Excel 的副本是否在运行。
   On Error Resume Next   '延迟错误捕获。
'不带第一个参数调用 Getobject 函数将
'返回对该应用程序的实例的引用。
'如果该应用程序不在运行，则会产生错误。
   Set MyXL = GetObject(, "Excel.Application")
   If err.Number <> 0 Then ExcelWasNotRunning = True
   err.Clear   '如果发生错误则要清除 Err 对象。

'检测 Microsoft Excel。如果 Microsoft Excel 在运行，
'则将其加入运行对象表。
   DetectExcel

'将对象变量设为对要看的文件的引用。
   Set MyXL = GetObject(App.path & "\ReportDemo\ES.xls")

'设置其 Application 属性，显示 Microsoft Excel。
'然后使用 MyXL 对象引用的 Windows 集合
'显示包含该文件的实际窗口。
   MyXL.Application.Visible = True
   MyXL.Parent.Windows(1).Visible = True
   '在此处对文件
   '进行操作。
   ' ...
'如果在启动时，Microsoft Excel 的这份副本不在运行中，
'则使用 Application 属性的 Quit 方法来关闭它。
'注意，当试图退出 Microsoft Excel 时，
'标题栏会闪烁，并显示一条消息
'询问是否保存所加载的文件。
   If ExcelWasNotRunning = True Then
      MyXL.Application.Quit
   End If

   Set MyXL = Nothing   '释放对该应用程序
                        '和电子数据表的引用。
End Sub

Sub DetectExcel()
'该过程检测并登记正在运行的 Excel。
   Const WM_USER = 1024
   Dim hwnd As Long
'如果 Excel 在运行，则该 API 调用将返回其句柄。
   hwnd = FindWindow("XLMAIN", 0)
'   frmMain.Text1.Text = hwnd
   If hwnd = 0 Then   '0 表示没有 Excel 在运行。
      Exit Sub
   Else
   'Excel 在运行，因此可以使用 SendMessage API
   '函数将其放入运行对象表。
      SendMessage hwnd, WM_USER + 18, 0, 0
   End If
End Sub



