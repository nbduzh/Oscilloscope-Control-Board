Attribute VB_Name = "ApiDeclarations"
'*****************************************************************************
'Zhai Jing Define
'****************************************************************************
'VendorID , ProductID and DeviceName
'Public Const MyVendorID = &H400
'Public Const MyProductID = &HC35B
'Public Const DeviceName = "Laser Parameter Testing Instrument Sec5000"
'User-defined types for ProductInformation Array
Public Type ProductSpec_typ
    UserAddress As Long
    ProductSerialNumber As String * 16
    WriteCode As Long
    ReadCode As Long
End Type

'******************************************************************************
'API constants, listed alphabetically
'******************************************************************************

'from setupapi.h
Public Const DIGCF_PRESENT = &H2
Public Const DIGCF_DEVICEINTERFACE = &H10
Public Const FILE_FLAG_OVERLAPPED = &H40000000
Public Const FILE_SHARE_READ = &H1
Public Const FILE_SHARE_WRITE = &H2
Public Const FORMAT_MESSAGE_FROM_SYSTEM = &H1000
Public Const GENERIC_READ = &H80000000
Public Const GENERIC_WRITE = &H40000000

'Typedef enum defines a set of integer constants for HidP_Report_Type
'Remember to declare these as integers (16 bits)
Public Const HidP_Input = 0
Public Const HidP_Output = 1
Public Const HidP_Feature = 2

Public Const OPEN_EXISTING = 3
Public Const WAIT_TIMEOUT = &H102&
Public Const WAIT_OBJECT_0 = 0

'******************************************************************************
'User-defined types for API calls, listed alphabetically
'******************************************************************************

Public Type GUID
    data1 As Long
    data2 As Integer
    data3 As Integer
    data4(7) As Byte
End Type

Public Type HIDD_ATTRIBUTES
    Size As Long
    VendorID As Integer
    ProductID As Integer
    VersionNumber As Integer
End Type

'Windows 98 DDK documentation is incomplete.
'Use the structure defined in hidpi.h
Public Type HIDP_CAPS
    Usage As Integer
    UsagePage As Integer
    InputReportByteLength As Integer
    OutputReportByteLength As Integer
    FeatureReportByteLength As Integer
    Reserved(16) As Integer
    NumberLinkCollectionNodes As Integer
    NumberInputButtonCaps As Integer
    NumberInputValueCaps As Integer
    NumberInputDataIndices As Integer
    NumberOutputButtonCaps As Integer
    NumberOutputValueCaps As Integer
    NumberOutputDataIndices As Integer
    NumberFeatureButtonCaps As Integer
    NumberFeatureValueCaps As Integer
    NumberFeatureDataIndices As Integer
End Type

'If IsRange is false, UsageMin is the Usage and UsageMax is unused.
'If IsStringRange is false, StringMin is the string index and StringMax is unused.
'If IsDesignatorRange is false, DesignatorMin is the designator index and DesignatorMax is unused.
Public Type HidP_Value_Caps
    UsagePage As Integer
    ReportID As Byte
    IsAlias As Long
    BitField As Integer
    LinkCollection As Integer
    LinkUsage As Integer
    LinkUsagePage As Integer
    IsRange As Long
    IsStringRange As Long
    IsDesignatorRange As Long
    IsAbsolute As Long
    HasNull As Long
    Reserved As Byte
    BitSize As Integer
    ReportCount As Integer
    Reserved2 As Integer
    Reserved3 As Integer
    Reserved4 As Integer
    Reserved5 As Integer
    Reserved6 As Integer
    LogicalMin As Long
    LogicalMax As Long
    PhysicalMin As Long
    PhysicalMax As Long
    UsageMin As Integer
    UsageMax As Integer
    StringMin As Integer
    StringMax As Integer
    DesignatorMin As Integer
    DesignatorMax As Integer
    DataIndexMin As Integer
    DataIndexMax As Integer
End Type

Public Type OVERLAPPED
    Internal As Long
    InternalHigh As Long
    offset As Long
    OffsetHigh As Long
    hEvent As Long
End Type

Public Type SECURITY_ATTRIBUTES
    nLength As Long
    lpSecurityDescriptor As Long
    bInheritHandle As Long
End Type

Public Type SP_DEVICE_INTERFACE_DATA
   cbSize As Long
   InterfaceClassGuid As GUID
   Flags As Long
   Reserved As Long
End Type

Public Type SP_DEVICE_INTERFACE_DETAIL_DATA
    cbSize As Long
    DevicePath As Byte
End Type

Public Type SP_DEVINFO_DATA
    cbSize As Long
    ClassGuid As GUID
    DevInst As Long
    Reserved As Long
End Type

'******************************************************************************
'API functions, listed alphabetically
'******************************************************************************

Public Declare Function CancelIo _
    Lib "kernel32" _
    (ByVal hFile As Long) _
As Long

Public Declare Function CloseHandle _
    Lib "kernel32" _
    (ByVal hObject As Long) _
As Long

Public Declare Function CreateEvent _
    Lib "kernel32" _
    Alias "CreateEventA" _
    (ByRef lpSecurityAttributes As SECURITY_ATTRIBUTES, _
    ByVal bManualReset As Long, _
    ByVal bInitialState As Long, _
    ByVal lpName As String) _
As Long

Public Declare Function CreateFile _
    Lib "kernel32" _
    Alias "CreateFileA" _
    (ByVal lpFileName As String, _
    ByVal dwDesiredAccess As Long, _
    ByVal dwShareMode As Long, _
    ByRef lpSecurityAttributes As SECURITY_ATTRIBUTES, _
    ByVal dwCreationDisposition As Long, _
    ByVal dwFlagsAndAttributes As Long, _
    ByVal hTemplateFile As Long) _
As Long

Public Declare Function FormatMessage _
    Lib "kernel32" _
    Alias "FormatMessageA" _
    (ByVal dwFlags As Long, _
    ByRef lpSource As Any, _
    ByVal dwMessageId As Long, _
    ByVal dwLanguageZId As Long, _
    ByVal lpBuffer As String, _
    ByVal nSize As Long, _
    ByVal Arguments As Long) _
As Long

''''''�Լ���ӵģ�ȡ��ʶ���Ʒ���ַ�������ȡ�ð����豸���кŵ��ַ�����'''''''''''''''''
Public Declare Function HidD_GetProductString _
    Lib "HID.dll" _
    (ByVal HANDLE As Long, _
    ByVal BufferPtr As Long, _
    ByVal length As Long) _
As Long

Public Declare Function HidD_GetSerialNumberString _
    Lib "HID.dll" _
    (ByVal HANDLE As Long, _
    ByVal BufferPtr As Long, _
    ByVal length As Long) _
    As Long
''''''�п�����ߵĲ����ó���LONG��������������������������������'''''''''''''''''''''''

Public Declare Function HidD_FreePreparsedData _
    Lib "HID.dll" _
    (ByRef PreparsedData As Long) _
As Long

Public Declare Function HidD_GetAttributes _
    Lib "HID.dll" _
    (ByVal HidDeviceObject As Long, _
    ByRef Attributes As HIDD_ATTRIBUTES) _
As Long

'Declared as a function for consistency,
'but returns nothing. (Ignore the returned value.)
Public Declare Function HidD_GetHidGuid _
    Lib "HID.dll" _
    (ByRef HidGuid As GUID) _
As Long

Public Declare Function HidD_GetPreparsedData _
    Lib "HID.dll" _
    (ByVal HidDeviceObject As Long, _
    ByRef PreparsedData As Long) _
As Long

Public Declare Function HidP_GetCaps _
    Lib "HID.dll" _
    (ByVal PreparsedData As Long, _
    ByRef Capabilities As HIDP_CAPS) _
As Long

Public Declare Function HidP_GetValueCaps _
    Lib "HID.dll" _
    (ByVal ReportType As Integer, _
    ByRef ValueCaps As Byte, _
    ByRef ValueCapsLength As Integer, _
    ByVal PreparsedData As Long) _
As Long
       
Public Declare Function lstrcpy _
    Lib "kernel32" _
    Alias "lstrcpyA" _
    (ByVal dest As String, _
    ByVal Source As Long) _
As String

Public Declare Function lstrlen _
    Lib "kernel32" _
    Alias "lstrlenA" _
    (ByVal Source As Long) _
As Long

Public Declare Function ReadFile _
    Lib "kernel32" _
    (ByVal hFile As Long, _
    ByRef lpBuffer As Byte, _
    ByVal nNumberOfBytesToRead As Long, _
    ByRef lpNumberOfBytesRead As Long, _
    ByRef lpOverlapped As OVERLAPPED) _
As Long


Public Declare Function ResetEvent _
    Lib "kernel32" _
    (ByVal hEvent As Long) _
As Long

Public Declare Function RtlMoveMemory _
    Lib "kernel32" _
    (dest As Any, _
    src As Any, _
    ByVal count As Long) _
As Long

Public Declare Function SetupDiCreateDeviceInfoList _
    Lib "setupapi.dll" _
    (ByRef ClassGuid As GUID, _
    ByVal hwndParent As Long) _
As Long

Public Declare Function SetupDiDestroyDeviceInfoList _
    Lib "setupapi.dll" _
    (ByVal DeviceInfoSet As Long) _
As Long

Public Declare Function SetupDiEnumDeviceInterfaces _
    Lib "setupapi.dll" _
    (ByVal DeviceInfoSet As Long, _
    ByVal DeviceInfoData As Long, _
    ByRef InterfaceClassGuid As GUID, _
    ByVal MemberIndex As Long, _
    ByRef DeviceInterfaceData As SP_DEVICE_INTERFACE_DATA) _
As Long

Public Declare Function SetupDiGetClassDevs _
    Lib "setupapi.dll" _
    Alias "SetupDiGetClassDevsA" _
    (ByRef ClassGuid As GUID, _
    ByVal Enumerator As String, _
    ByVal hwndParent As Long, _
    ByVal Flags As Long) _
As Long

Public Declare Function SetupDiGetDeviceInterfaceDetail _
   Lib "setupapi.dll" _
   Alias "SetupDiGetDeviceInterfaceDetailA" _
   (ByVal DeviceInfoSet As Long, _
   ByRef DeviceInterfaceData As SP_DEVICE_INTERFACE_DATA, _
   ByVal DeviceInterfaceDetailData As Long, _
   ByVal DeviceInterfaceDetailDataSize As Long, _
   ByRef RequiredSize As Long, _
   ByVal DeviceInfoData As Long) _
As Long
    
Public Declare Function WaitForSingleObject _
    Lib "kernel32" _
    (ByVal hHandle As Long, _
    ByVal dwMilliseconds As Long) _
As Long
    
Public Declare Function WriteFile _
    Lib "kernel32" _
    (ByVal hFile As Long, _
    ByRef lpBuffer As Byte, _
    ByVal nNumberOfBytesToWrite As Long, _
    ByRef lpNumberOfBytesWritten As Long, _
    ByVal lpOverlapped As Long) _
As Long




 
