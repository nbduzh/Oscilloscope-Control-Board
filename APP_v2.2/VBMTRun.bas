Attribute VB_Name = "VBMTRun"
Option Explicit

Public Declare Function SetParent Lib "user32" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long

'�����߳̾��
Public VBThreadHandle As Long
'�����߳�ID
Public VBThreadID As Long
Public TxtHwnd As Long
Public MainHwnd As Long, SubHwnd As Long
Public Finish As Boolean


'************************************ע�⣺VB6���̱߳�����SUB MAINΪ��������***************************************************
'***************************��ʾ�����Ѿ����ú��ˣ��Լ�ʹ��ʱע���ڹ��̡������ԡ�����������������ѡ��************************
Sub main()
If AvoidReentrant = False Then       '��ֹ���߳��ظ�����
    AvoidReentrant = True
        If App.PrevInstance Then        '��ֹ�����ظ�����
            MessageBox ByVal 0&, StrPtr("�����������л�δ��ȫ�˳�"), StrPtr("�ظ�����"), vbCritical
            Exit Sub
        Else
            InitCommonControls      '��ʼ��ͨ�ÿؼ�
            GETVBHeader                 '��ȡVB����ͷ
            
            Start.Show
        End If
End If
End Sub

Public Sub ThreadSub()        '���߳�1
    VBThreadEnded = False
    '***********************************����Ҫ����VB6�̻߳�����ʼ��*************************************************
    CreateIExprSrvObj 0&, 4&, 0&            'VB6���п��ʼ��
    CoInitializeEx ByVal 0&, ByVal (COINIT_MULTITHREADED Or COINIT_SPEED_OVER_MEMORY)   'COM�����ʼ��
    InitVBdll               '�յ�VB6���п��ڲ��������ֵĳ�ʼ��
    '***********************************����Ҫ����VB6�̻߳�����ʼ��*************************************************
    
    Call AutoMeasure
    
    CoUninitialize      'ж��COM�����ʡ��Ҳ����Ӱ���ȶ��ԣ���������ɾ�����ڴ�й©��Ϊ�����ɺ�ϰ�ߣ�����д�ϣ�
    VBThreadEnded = True
End Sub
