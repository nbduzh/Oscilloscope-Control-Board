VERSION 5.00
Begin VB.Form Start 
   Caption         =   "Start"
   ClientHeight    =   2775
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   3990
   BeginProperty Font 
      Name            =   "Tahoma"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "Start.frx":0000
   ScaleHeight     =   2775
   ScaleWidth      =   3990
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdTiming 
      Caption         =   "Timing"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   840
      Left            =   480
      TabIndex        =   1
      Top             =   1560
      Width           =   3015
   End
   Begin VB.CommandButton cmdAutoMeasurement 
      Caption         =   "Auto Measurement"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   960
      Left            =   480
      TabIndex        =   0
      Top             =   240
      Width           =   3015
   End
End
Attribute VB_Name = "Start"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdAutoMeasurement_Click()
    frmMain.Show
    Unload Me
End Sub

Private Sub cmdTiming_Click()
    Timing.Show
    Unload Me
End Sub

