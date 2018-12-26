VERSION 5.00
Begin VB.Form Timing 
   BackColor       =   &H80000004&
   Caption         =   "Timing"
   ClientHeight    =   5865
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   5415
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "Timing.frx":0000
   KeyPreview      =   -1  'True
   ScaleHeight     =   5865
   ScaleWidth      =   5415
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   Begin VB.Frame FraF 
      Height          =   2535
      Left            =   240
      TabIndex        =   13
      Top             =   360
      Width           =   4935
      Begin VB.CommandButton cmdCommand1 
         BackColor       =   &H008080FF&
         Caption         =   "Power Off"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1320
         Left            =   2760
         MaskColor       =   &H80000004&
         Style           =   1  'Graphical
         TabIndex        =   22
         Top             =   720
         Width           =   1815
      End
      Begin VB.TextBox txtRise 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   840
         TabIndex        =   16
         Text            =   "470"
         Top             =   1320
         Width           =   1095
      End
      Begin VB.TextBox txtFall 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   840
         TabIndex        =   15
         Text            =   "100"
         Top             =   1920
         Width           =   1095
      End
      Begin VB.TextBox txtPanelVol 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   960
         TabIndex        =   14
         Text            =   "5"
         Top             =   480
         Width           =   975
      End
      Begin VB.Label lblV 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "V"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   2040
         TabIndex        =   23
         Top             =   480
         Width           =   285
      End
      Begin VB.Label lblRisingTime 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T1:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   21
         Top             =   1320
         Width           =   375
      End
      Begin VB.Label lblFallingTime 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T6:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   20
         Top             =   1920
         Width           =   375
      End
      Begin VB.Label lblUs 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "us"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   2040
         TabIndex        =   19
         Top             =   1920
         Width           =   285
      End
      Begin VB.Label lblUs2 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "us"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   2040
         TabIndex        =   18
         Top             =   1320
         Width           =   285
      End
      Begin VB.Label lblVCC 
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
         Height          =   300
         Left            =   240
         TabIndex        =   17
         Top             =   480
         Width           =   615
      End
   End
   Begin VB.Frame Frame1 
      Height          =   2655
      Left            =   240
      TabIndex        =   0
      Top             =   3000
      Width           =   4935
      Begin VB.TextBox txtT5 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   3120
         TabIndex        =   25
         Text            =   "30"
         Top             =   1410
         Width           =   855
      End
      Begin VB.TextBox txtT2 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   840
         TabIndex        =   24
         Text            =   "30"
         Top             =   1410
         Width           =   855
      End
      Begin VB.TextBox txtOn 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   840
         TabIndex        =   10
         Text            =   "3000"
         Top             =   900
         Width           =   855
      End
      Begin VB.TextBox txtOff 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   3120
         TabIndex        =   9
         Text            =   "3000"
         Top             =   900
         Width           =   855
      End
      Begin VB.TextBox txtBLOn 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   840
         TabIndex        =   8
         Text            =   "100"
         Top             =   1920
         Width           =   855
      End
      Begin VB.TextBox txtBLOff 
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   405
         Left            =   3120
         TabIndex        =   7
         Text            =   "100"
         Top             =   1920
         Width           =   855
      End
      Begin VB.CheckBox chkCheck1 
         Caption         =   "Check1"
         Height          =   310
         Left            =   240
         TabIndex        =   1
         Top             =   360
         Width           =   255
      End
      Begin VB.Label lblMs5 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   4080
         TabIndex        =   31
         Top             =   2000
         Width           =   255
      End
      Begin VB.Label lblMs4 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   1800
         TabIndex        =   30
         Top             =   2000
         Width           =   255
      End
      Begin VB.Label lblMs3 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   4080
         TabIndex        =   29
         Top             =   1470
         Width           =   255
      End
      Begin VB.Label lblMs1 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   1800
         TabIndex        =   28
         Top             =   1470
         Width           =   255
      End
      Begin VB.Label lblT2 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T2:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   27
         Top             =   1470
         Width           =   375
      End
      Begin VB.Label lblT5 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T5:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2520
         TabIndex        =   26
         Top             =   1470
         Width           =   375
      End
      Begin VB.Label lblT4 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T4:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2520
         TabIndex        =   12
         Top             =   1980
         Width           =   375
      End
      Begin VB.Label lblT3 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "T3:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   11
         Top             =   1980
         Width           =   375
      End
      Begin VB.Label lblMs2 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   1800
         TabIndex        =   6
         Top             =   975
         Width           =   255
      End
      Begin VB.Label lblPowerOn 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "     Power On/Off:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   5
         Top             =   360
         Width           =   2145
      End
      Begin VB.Label lblOn 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ON:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   240
         TabIndex        =   4
         Top             =   960
         Width           =   435
      End
      Begin VB.Label lblMs 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "ms"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   240
         Left            =   4080
         TabIndex        =   3
         Top             =   975
         Width           =   255
      End
      Begin VB.Label lblOff 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "OFF:"
         BeginProperty Font 
            Name            =   "Tahoma"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2520
         TabIndex        =   2
         Top             =   960
         Width           =   510
      End
   End
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Left            =   4080
      Top             =   0
   End
End
Attribute VB_Name = "Timing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmdCommand1_Click()
    Dim WriteData As String
    If Check_DataOk Or chkCheck1.value = 0 Then
        Timing.Enabled = False
        If chkCheck1.value = False Then
            If cmdCommand1.Caption = "Power Off" Then
                'send power on
                WriteData = TIMING_RISE_MODE & txtRise.Text & ";" & Timing.txtPanelVol.Text
                Call WriteReport(WriteData)
                cmdCommand1.Caption = "Power On"
                cmdCommand1.BackColor = RGB(128, 255, 128)
                Sleep CLng(CLng(txtRise.Text) * 1.5 / 1000)
            Else
                'send power off
                WriteData = TIMING_FALL_MODE & txtFall.Text
                Call WriteReport(WriteData)
                cmdCommand1.Caption = "Power Off"
                cmdCommand1.BackColor = RGB(255, 128, 128)
                Sleep CLng(CLng(txtFall.Text) * 1.5 / 1000)
            End If
            Timing.Enabled = True
        Else
            If cmdCommand1.Caption = "Power Off" Then
                'send power on
                WriteData = TIMING_ONOFF_MODE & txtRise.Text & ";" & txtFall.Text & ";" _
                & txtOn.Text & ";" & txtOff.Text & ";" & txtT2.Text & ";" & txtT5.Text & ";" _
                & txtBLOn.Text & ";" & txtBLOff.Text & ";" & Timing.txtPanelVol.Text
                Call WriteReport(WriteData)
                cmdCommand1.Caption = "Power On"
                cmdCommand1.BackColor = RGB(128, 255, 128)
                Sleep CLng(CLng(txtRise.Text) * 1.5 / 1000)
            Else
                'send power off
                WriteData = POWER_OFF
                Call WriteReport(WriteData)
                cmdCommand1.Caption = "Power Off"
                cmdCommand1.BackColor = RGB(255, 128, 128)
                Sleep CLng(CLng(txtFall.Text) * 1.5 / 1000)
            End If
            Timing.Enabled = True
        End If
    Else
        MsgBox "Panel on time can not less than B/L & LVDS delay time."
    End If
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then               'press enter
        Call cmdCommand1_Click
    End If
End Sub

Private Sub Form_Load()
    Call File_Init
    Call DetectHID
End Sub


Private Sub Form_Unload(Cancel As Integer)
On Error Resume Next
    Call WriteReport(POWER_OFF)
    Unload Start
    End
End Sub

Private Sub lblPowerOn_Click()
    If chkCheck1.value = 1 Then
        chkCheck1.value = 0
    Else
        chkCheck1.value = 1
    End If
End Sub

Private Sub txtBLOff_Change()
    Call Check_Number(txtBLOff, 0, 3000)
End Sub

Private Sub txtBLOff_GotFocus()
    PreNumber = CLng(txtBLOff.Text)
End Sub

Private Sub txtBLOff_LostFocus()
    If txtBLOff.Text = "" Then
        txtBLOff.Text = PreNumber
    End If
End Sub

Private Sub txtBLOn_Change()
    Call Check_Number(txtBLOn, 0, 3000)
End Sub

Private Sub txtBLOn_GotFocus()
    PreNumber = CLng(txtBLOn.Text)
End Sub

Private Sub txtBLOn_LostFocus()
    If txtBLOn.Text = "" Then
        txtBLOn.Text = PreNumber
    End If
End Sub

Private Sub txtFall_Change()
    Call Check_Number(txtFall, 1, 300000)
End Sub

Private Sub txtFall_GotFocus()
    PreNumber = CLng(txtFall.Text)
End Sub

Private Sub txtFall_LostFocus()
    If txtFall.Text = "" Then
        txtFall.Text = PreNumber
    End If
    If CLng(txtFall.Text) < 30 Then
        txtFall.Text = "30"
        MsgBox "Falling time can not less than 30us."
    End If
End Sub

Private Sub txtOff_Change()
    Call Check_Number(txtOff, 1, 300000)
End Sub

Private Sub txtOff_GotFocus()
    PreNumber = CLng(txtOff.Text)
End Sub

Private Sub txtOff_LostFocus()
    If txtOff.Text = "" Then
        txtOff.Text = PreNumber
    End If
End Sub

Private Sub txtOn_Change()
    Call Check_Number(txtOn, 1, 300000)
End Sub

Private Sub txtOn_GotFocus()
    PreNumber = CLng(txtOn.Text)
End Sub

Private Sub txtOn_LostFocus()
    If txtOn.Text = "" Then
        txtOn.Text = PreNumber
    End If
End Sub

Private Sub txtPanelVol_Change()
    Call Check_Number(txtPanelVol, 1, 14)
End Sub

Private Sub txtPanelVol_GotFocus()
    PreNumber = CLng(txtPanelVol.Text)
End Sub

Private Sub txtPanelVol_LostFocus()
    If txtPanelVol.Text = "" Then
        txtPanelVol.Text = PreNumber
    End If
End Sub

Private Sub txtRise_Change()
    Call Check_Number(txtRise, 1, 300000)
End Sub

Private Sub txtRise_GotFocus()
    PreNumber = CLng(txtRise.Text)
End Sub

Private Sub txtRise_LostFocus()
    If txtRise.Text = "" Then
        txtRise.Text = PreNumber
    End If
    If CLng(txtRise.Text) < 100 Then
        txtRise.Text = "100"
        MsgBox "Rise time can not less than 100us."
    End If
End Sub

Private Sub txtT2_Change()
    Call Check_Number(txtT2, -1000, 1000)
End Sub

Private Sub txtT2_GotFocus()
    PreNumber = CLng(txtT2.Text)
End Sub

Private Sub txtT2_LostFocus()
    If txtT2.Text = "" Then
        txtT2.Text = PreNumber
    End If
End Sub

Private Sub txtT5_Change()
    Call Check_Number(txtT5, -1000, 1000)
End Sub

Private Sub txtT5_GotFocus()
    PreNumber = CLng(txtT5.Text)
End Sub

Private Sub txtT5_LostFocus()
    If txtT5.Text = "" Then
        txtT5.Text = PreNumber
    End If
End Sub
