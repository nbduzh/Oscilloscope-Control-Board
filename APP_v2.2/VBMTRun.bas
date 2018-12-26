Attribute VB_Name = "VBMTRun"
Option Explicit

Public Declare Function SetParent Lib "user32" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long

'定义线程句柄
Public VBThreadHandle As Long
'定义线程ID
Public VBThreadID As Long
Public TxtHwnd As Long
Public MainHwnd As Long, SubHwnd As Long
Public Finish As Boolean


'************************************注意：VB6多线程必须以SUB MAIN为启动对象***************************************************
'***************************本示例中已经设置好了，自己使用时注意在工程——属性——启动对象中自行选择************************
Sub main()
If AvoidReentrant = False Then       '防止主线程重复运行
    AvoidReentrant = True
        If App.PrevInstance Then        '防止程序重复运行
            MessageBox ByVal 0&, StrPtr("程序正在运行或未完全退出"), StrPtr("重复运行"), vbCritical
            Exit Sub
        Else
            InitCommonControls      '初始化通用控件
            GETVBHeader                 '获取VB数据头
            
            Start.Show
        End If
End If
End Sub

Public Sub ThreadSub()        '子线程1
    VBThreadEnded = False
    '***********************************（重要！）VB6线程环境初始化*************************************************
    CreateIExprSrvObj 0&, 4&, 0&            'VB6运行库初始化
    CoInitializeEx ByVal 0&, ByVal (COINIT_MULTITHREADED Or COINIT_SPEED_OVER_MEMORY)   'COM组件初始化
    InitVBdll               '诱导VB6运行库内部其他部分的初始化
    '***********************************（重要！）VB6线程环境初始化*************************************************
    
    Call AutoMeasure
    
    CoUninitialize      '卸载COM组件（省掉也不会影响稳定性，但可能造成句柄或内存泄漏。为了养成好习惯，还是写上）
    VBThreadEnded = True
End Sub
