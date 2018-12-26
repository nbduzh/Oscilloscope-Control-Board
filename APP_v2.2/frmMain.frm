VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{DFEB0DA3-D648-11D4-9C5F-EA48B7E9393D}#2.0#0"; "tvc.ocx"
Begin VB.Form frmMain 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Oscilloscope Control v2.1"
   ClientHeight    =   5385
   ClientLeft      =   3885
   ClientTop       =   1290
   ClientWidth     =   9015
   Icon            =   "frmMain.frx":0000
   MaxButton       =   0   'False
   ScaleHeight     =   5385
   ScaleWidth      =   9015
   Visible         =   0   'False
   Begin VB.Frame Frame1 
      Caption         =   "PG"
      Height          =   1215
      Left            =   5760
      TabIndex        =   35
      Top             =   2040
      Width           =   3015
      Begin VB.OptionButton Opt4K2KPG 
         Caption         =   "4K2KPG"
         Height          =   195
         Index           =   1
         Left            =   120
         TabIndex        =   38
         Top             =   360
         Width           =   975
      End
      Begin VB.OptionButton Opt4K2KPG 
         Caption         =   "PG5"
         Height          =   195
         Index           =   0
         Left            =   1440
         TabIndex        =   37
         Top             =   360
         Width           =   735
      End
      Begin VB.ComboBox Com4K2K 
         Height          =   315
         Left            =   120
         TabIndex        =   36
         Text            =   "Please select a timing"
         Top             =   720
         Width           =   2775
      End
   End
   Begin MSComctlLib.ProgressBar ProgressBar1 
      Height          =   375
      Left            =   240
      TabIndex        =   34
      Top             =   4920
      Width           =   8535
      _ExtentX        =   15055
      _ExtentY        =   661
      _Version        =   393216
      Appearance      =   1
      Enabled         =   0   'False
      Max             =   15
   End
   Begin VB.Frame FraLog 
      Caption         =   "Log"
      Height          =   1335
      Left            =   5760
      TabIndex        =   32
      Top             =   3360
      Width           =   3015
      Begin VB.TextBox txtLog 
         BackColor       =   &H8000000F&
         BorderStyle     =   0  'None
         Height          =   975
         Left            =   120
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         TabIndex        =   33
         Top             =   240
         Width           =   2775
      End
   End
   Begin VB.Frame FraINFO 
      Caption         =   "INFO"
      Height          =   2655
      Left            =   2760
      TabIndex        =   15
      Top             =   2040
      Width           =   2775
      Begin VB.ComboBox cmbSample 
         Height          =   315
         ItemData        =   "frmMain.frx":2CFA
         Left            =   1440
         List            =   "frmMain.frx":2D01
         Style           =   2  'Dropdown List
         TabIndex        =   31
         Top             =   2040
         Width           =   975
      End
      Begin VB.ComboBox cmbPhase 
         Height          =   315
         ItemData        =   "frmMain.frx":2D09
         Left            =   240
         List            =   "frmMain.frx":2D13
         Style           =   2  'Dropdown List
         TabIndex        =   30
         Top             =   2040
         Width           =   975
      End
      Begin VB.ComboBox cmbPanelVol 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   420
         ItemData        =   "frmMain.frx":2D28
         Left            =   1320
         List            =   "frmMain.frx":2D38
         Style           =   2  'Dropdown List
         TabIndex        =   18
         Top             =   480
         Width           =   1095
      End
      Begin VB.ComboBox cmbChannelSel1 
         Height          =   315
         ItemData        =   "frmMain.frx":2D5C
         Left            =   240
         List            =   "frmMain.frx":2D6C
         Style           =   2  'Dropdown List
         TabIndex        =   17
         Top             =   1320
         Width           =   975
      End
      Begin VB.ComboBox cmbChannelSel2 
         Height          =   315
         ItemData        =   "frmMain.frx":2D84
         Left            =   1440
         List            =   "frmMain.frx":2D94
         Style           =   2  'Dropdown List
         TabIndex        =   16
         Top             =   1320
         Width           =   975
      End
      Begin VB.Label lblSample 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Sample:"
         Height          =   195
         Left            =   1440
         TabIndex        =   24
         Top             =   1800
         Width           =   570
      End
      Begin VB.Label lblPhase 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Phase:"
         Height          =   195
         Left            =   240
         TabIndex        =   23
         Top             =   1800
         Width           =   495
      End
      Begin VB.Label lblCurrentCH 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Current CH:"
         Height          =   195
         Left            =   1440
         TabIndex        =   22
         Top             =   1080
         Width           =   825
      End
      Begin VB.Label lblVoltageCH 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Voltage CH:"
         Height          =   195
         Left            =   240
         TabIndex        =   21
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label lblPanelVoltage 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "VCC:"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   360
         Left            =   240
         TabIndex        =   20
         Top             =   480
         Width           =   720
      End
   End
   Begin VB.CommandButton cmdSTOP 
      Caption         =   "STOP"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   7440
      TabIndex        =   14
      Top             =   1200
      Width           =   1245
   End
   Begin VB.TextBox txtProductID 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00C0C0C0&
      Height          =   450
      Left            =   2400
      MaxLength       =   13
      TabIndex        =   12
      Text            =   "Product ID"
      Top             =   1320
      Width           =   3375
   End
   Begin VB.Frame FraPG5Ver 
      Caption         =   "PG Ver"
      Height          =   615
      Left            =   240
      TabIndex        =   6
      Top             =   1200
      Width           =   1935
      Begin VB.Label lblPG5Ver 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "NO PG"
         ForeColor       =   &H000000FF&
         Height          =   195
         Left            =   675
         TabIndex        =   7
         Top             =   285
         Width           =   525
      End
   End
   Begin VB.Timer Timer1 
      Interval        =   60000
      Left            =   3120
      Top             =   0
   End
   Begin VB.Frame FraOSCILLOSCOPENAME 
      Caption         =   "OSCILLOSCOPE NAME"
      Height          =   735
      Left            =   4200
      TabIndex        =   4
      Top             =   240
      Width           =   4575
      Begin VB.Label lblOSCILLOSCOPENAME 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "NO OSCILLOSCOPE"
         ForeColor       =   &H000000FF&
         Height          =   195
         Left            =   1485
         TabIndex        =   5
         Top             =   300
         Width           =   1515
      End
   End
   Begin VB.Frame FraDEVICENAME 
      Caption         =   "DEVICE NAME"
      Height          =   735
      Left            =   240
      TabIndex        =   2
      Top             =   240
      Width           =   3735
      Begin VB.Label lblCONNECTION 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "NO DEVICE"
         ForeColor       =   &H000000FF&
         Height          =   195
         Left            =   0
         TabIndex        =   3
         Top             =   300
         Width           =   3735
      End
   End
   Begin VB.Frame fraPATTERN 
      Caption         =   "PATTERN"
      Height          =   2655
      Left            =   240
      TabIndex        =   1
      Top             =   2040
      Width           =   2295
      Begin VB.TextBox txtRiseTime 
         Height          =   285
         Left            =   1250
         MaxLength       =   4
         TabIndex        =   13
         Text            =   "470"
         Top             =   338
         Width           =   495
      End
      Begin VB.ComboBox ComHEAVY 
         Height          =   315
         Left            =   1250
         Style           =   2  'Dropdown List
         TabIndex        =   11
         Top             =   2123
         Width           =   855
      End
      Begin VB.ComboBox ComVSTRIP 
         Height          =   315
         Left            =   1250
         Style           =   2  'Dropdown List
         TabIndex        =   10
         Top             =   1667
         Width           =   855
      End
      Begin VB.ComboBox ComBLACK 
         Height          =   315
         Left            =   1250
         Style           =   2  'Dropdown List
         TabIndex        =   9
         Top             =   1214
         Width           =   855
      End
      Begin VB.ComboBox ComWHITE 
         Height          =   315
         ItemData        =   "frmMain.frx":2DAC
         Left            =   1250
         List            =   "frmMain.frx":2DAE
         Style           =   2  'Dropdown List
         TabIndex        =   8
         Top             =   761
         Width           =   855
      End
      Begin VB.Label lblWHITE 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "WHITE"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   120
         TabIndex        =   29
         Top             =   810
         Width           =   735
      End
      Begin VB.Label lblBLACK 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "BLACK"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   120
         TabIndex        =   28
         Top             =   1260
         Width           =   705
      End
      Begin VB.Label lblVSTRIP 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "V-STRIP"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   120
         TabIndex        =   27
         Top             =   1710
         Width           =   900
      End
      Begin VB.Label lblHEAVY 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "HEAVY"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   120
         TabIndex        =   26
         Top             =   2160
         Width           =   765
      End
      Begin VB.Label lblRiseTime 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "RiseTime"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   120
         TabIndex        =   25
         Top             =   360
         Width           =   1005
      End
      Begin VB.Label lblUs 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "us"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   300
         Left            =   1800
         TabIndex        =   19
         Top             =   315
         Width           =   255
      End
   End
   Begin TVCLib.Tvc Tvc1 
      Left            =   3840
      Top             =   -120
      _Version        =   65536
      _ExtentX        =   847
      _ExtentY        =   847
      _StockProps     =   0
      VisaDescriptor  =   ""
   End
   Begin VB.CommandButton cmdAutoMeasure 
      Caption         =   "Measure"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   615
      Left            =   6000
      TabIndex        =   0
      Top             =   1200
      Width           =   1245
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'Private PreNumber As Long

Private Sub cmbChannelSel1_Click()
    If cmbChannelSel1.Text = cmbChannelSel2.Text Then
        If cmbChannelSel1.ListIndex > 0 Then
            cmbChannelSel1.ListIndex = cmbChannelSel1.ListIndex - 1
        Else
            cmbChannelSel1.ListIndex = cmbChannelSel1.ListCount - 1
        End If
    End If
End Sub

Private Sub cmbChannelSel2_Click()
    If cmbChannelSel1.Text = cmbChannelSel2.Text Then
        If cmbChannelSel2.ListIndex > 0 Then
            cmbChannelSel2.ListIndex = cmbChannelSel2.ListIndex - 1
        Else
            cmbChannelSel2.ListIndex = cmbChannelSel2.ListCount - 1
        End If
    End If
End Sub

Private Sub cmbPanelVol_Click()
    PanelVoltage = CDbl(Trim(Mid$(frmMain.cmbPanelVol.Text, 1, 5)))
End Sub

Private Sub cmdAutoMeasure_Click()
    If Not Is_AllDeviceReady Then
        Call EnableComponents
        Exit Sub
    End If
    Call DisableComponents
    timeout = False
    TimeCount = 0
    Timer1.Enabled = True
    TargetRiseTime = CDbl(Trim(txtRiseTime.Text))
    If DeviceChecked Then
        Call PG5_Init
        If Not Is_PG5_Controled Then
            ErrorCode = ERROR_Frame1_TIMEOUT
            Call ExitMeasure(ErrorCode)
            Call EnableComponents
            Timer1.Enabled = False
            Exit Sub
        End If
        Call SetProcessID
        TerminateThread VBThreadHandle, ByVal 0&
        CloseHandle VBThreadHandle
        VBThreadHandle = CreateThread(ByVal 0&, ByVal 0&, AddressOf ThreadSub, ByVal 0&, ByVal CREATE_DEFAULT, VBThreadID)
'        Call AutoMeasure
    Else
        PrintLog "设备未连接，请先连接设备。"
    End If
End Sub




Private Sub cmdSTOP_Click()
    If cmdAutoMeasure.Enabled = True Then Exit Sub
    cmdSTOP.Enabled = False
    timeout = True
    ErrorCode = ERROR_STOPPED_BY_USER
    frmMain.Enabled = False
'    Call ExitMeasure(ErrorCode)
End Sub

Private Sub cmbPhase_Click()
    If cmbPhase.ListIndex = 0 Then
        cmbSample.Clear
        cmbSample.AddItem "S1", 0
    Else
        cmbSample.Clear
        cmbSample.AddItem "S1", 0
        cmbSample.AddItem "S2", 1
        cmbSample.AddItem "S3", 2
    End If
    cmbSample.ListIndex = 0
End Sub


Private Sub Form_Load()
        
    VBThreadEnded = True
    PreNumber = 10
'    Call File_Init
'    Call DetectDevice
 '   Call UI_Init
    
    lblCONNECTION.Caption = DeviceName
    lblCONNECTION.ForeColor = RGB(0, 0, 255)

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    If MsgBox("你真的要退出吗?", vbOKCancel, "提示") = vbCancel Then
        Cancel = True
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
'    Shell "cmd /c dir /tc /odg /b " & App.path & "\Waveform\*.* > " & App.path & "\Waveform\filelist.txt", vbHide
'    Shell "cmd /c dir /tc /odg /b " & App.path & "\Output\*.* > " & App.path & "\Output\filelist.txt", vbHide
    frmMain.Visible = False
    timeout = True
    ErrorCode = ERROR_STOPPED_BY_USER
    Do While Not VBThreadEnded
        DoEvents
    Loop
    Call ExitMeasure(0)
    TerminateThread VBThreadHandle, ByVal 0&
    CloseHandle VBThreadHandle
    Unload Start
    End         '强制结束一切，防止有线程不听话造成进程残留
End Sub




Private Sub Timer1_Timer()
    TimeCount = TimeCount + 1
    If TimeCount > 10 Then timeout = True
    ErrorCode = ERROR_TIMEOUT
End Sub

Private Sub txtLog_DblClick()
    On Error Resume Next
    Shell "C:\WINDOWS\NOTEPAD.EXE" + " " + LogFilePath, 1
End Sub

Private Sub txtProductID_Change()
    Dim s As Variant
    Dim temp As String
    Dim arry() As Byte
    temp = "\/:*?<>""|!@#$%^&()+=;'.,`~{}[]"
    arry = StrConv(temp, vbFromUnicode)
    txtProductID.FontBold = True
    txtProductID.ForeColor = RGB(0, 0, 0)
    For Each s In arry
        txtProductID.Text = Replace(txtProductID.Text, Chr(s), "")
    Next
'    If Len(txtProductID.Text) > 13 Then txtProductID.Text = Left(txtProductID.Text, 13)
    
    txtProductID.SelStart = Len(txtProductID.Text)
End Sub


Private Sub txtProductID_Click()
    If txtProductID.Text = "Product ID" Then
        txtProductID.SelStart = 0
        txtProductID.SelLength = Len(txtProductID.Text)
    End If
End Sub


Private Sub txtProductID_DblClick()
    Dim path, ret As String
    path = App.path & "\" & "Waveform\" & ProductID & "_" & ProcessID
    ret = Dir(path, vbDirectory)
    If ret <> "" Then
        Shell "C:\WINDOWS\explorer.exe" + " " + path, 1
    End If
End Sub

Private Sub txtProductID_LostFocus()
    If Trim$(txtProductID.Text) = "" Then
        txtProductID.Text = "Product ID"
        txtProductID.FontBold = False
        txtProductID.ForeColor = RGB(192, 192, 192)
    ElseIf txtProductID.Text = "Product ID" Then
        ProductID = "NA"
    Else
        ProductID = Trim$(txtProductID.Text)
    End If
End Sub

Private Sub txtRiseTime_Change()
    Call Check_Number(txtRiseTime, 1, 300000)
End Sub

Private Sub txtRiseTime_GotFocus()
    PreNumber = CLng(txtRiseTime.Text)
End Sub

Private Sub txtRiseTime_LostFocus()
    If txtRiseTime.Text = "" Then txtRiseTime.Text = "0"
    If CLng(txtRiseTime.Text) > 1000 Or CLng(txtRiseTime.Text) < 300 Then
        txtRiseTime.Text = "470"
        MsgBox "Rise time can not greater than 1ms, or less than 300us."
    End If
End Sub
