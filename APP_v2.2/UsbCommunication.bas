Attribute VB_Name = "USBCommunication"
Option Explicit

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Public ReadHandle As Long
Public WriteHandle As Long
Public DeviceIndex As Integer

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Public DeviceChecked As Boolean
Dim Capabilities As HIDP_CAPS
Dim DataString As String
Dim DetailData As Long
Dim DeviceAttributes As HIDD_ATTRIBUTES
Dim DevicePathName As String
Dim DeviceInfoSet As Long
Dim EventObject As Long
Public HIDHandle As Long
Dim HIDOverlapped As OVERLAPPED
Dim IncreaseOfPacket As Integer
Dim LastDevice As Boolean
Dim UsefulMember As Byte
Public MyDeviceDetected As Boolean
Dim MyDeviceInfoData As SP_DEVINFO_DATA
Dim MyDeviceInterfaceDetailData As SP_DEVICE_INTERFACE_DETAIL_DATA
Dim MyDeviceInterfaceData As SP_DEVICE_INTERFACE_DATA
Dim Needed As Long
Dim DetailDataBuffer() As Byte
Dim OutputReportData(64) As Byte
Dim InputReportData() As Byte
Dim PreparsedData As Long
Public ProductInformation(3) As ProductSpec_typ
Public hUSBWriteHandle() As Long
Public Result As Long
Dim Security As SECURITY_ATTRIBUTES



Public Function OpenWriteUSBDevice(hDevice As Long, DevicePathName As String) As Boolean
    hDevice = CreateFile _
         (DevicePathName, _
         GENERIC_READ Or GENERIC_WRITE, _
         (FILE_SHARE_READ Or FILE_SHARE_WRITE), _
         Security, _
         OPEN_EXISTING, _
         0&, _
         0) '开启一个HID设备，取得设备的代号，使用设备的代号与设备交换数据。代号存在HIDHandle，将来存在ReadHandle中
    If hDevice = -1 Then
        OpenWriteUSBDevice = False
        PrintLog "设备联接失败，请重试！"
    Else
        OpenWriteUSBDevice = True
        PrintLog "设备联接成功！"
    End If
    Call GetDeviceCapabilities(hDevice)
    Call PrepareForOverlappedTransfer
End Function

Public Function OpenUSBDevice(hDevice As Long, DevicePathName As String) As Boolean
         
    hDevice = CreateFile _
          (DevicePathName, _
          (GENERIC_READ Or GENERIC_WRITE), _
          (FILE_SHARE_READ Or FILE_SHARE_WRITE), _
          Security, _
          OPEN_EXISTING, _
          FILE_FLAG_OVERLAPPED, _
          0)                    '此设备代号存在ReadHandle中

    Call GetDeviceCapabilities(hDevice)
    Call PrepareForOverlappedTransfer

End Function



Public Function GetDataString(address As Long, Bytes As Long) As String

    Dim offset As Integer
    Dim Result$
    Dim ThisByte As Byte
    
    For offset = 0 To Bytes - 1
        Call RtlMoveMemory(ByVal VarPtr(ThisByte), ByVal address + offset, 1)
        If (ThisByte And &HF0) = 0 Then
            Result$ = Result$ & "0"
        End If
        Result$ = Result$ & Hex$(ThisByte) & " "
    Next offset
    
    GetDataString = Result$


End Function



Public Sub GetDeviceCapabilities(HIDHandle As Long)
    
    Dim ppData(29) As Byte
    Dim ppDataString As Variant
    
    Result = HidD_GetPreparsedData _
        (HIDHandle, _
        PreparsedData) '取得一个包含设备能力信息的缓冲区的指针
        
    Result = RtlMoveMemory _
        (ppData(0), _
        PreparsedData, _
        30)
    
    ppDataString = ppData()
    ppDataString = StrConv(ppDataString, vbUnicode)
    
    Result = HidP_GetCaps _
        (PreparsedData, _
        Capabilities) '传回一个包含设备能力信息的结构，主要是报表的内容
        
    Dim ValueCaps(1023) As Byte
    
    Result = HidP_GetValueCaps _
        (HidP_Input, _
        ValueCaps(0), _
        Capabilities.NumberInputValueCaps, _
        PreparsedData) '传回一个报表中关于每个数值的信息的结构数组的指针
        
    Result = HidD_FreePreparsedData _
        (PreparsedData) '释放HidD_GetPreparsedData所使用的资源

End Sub


Public Sub PrepareForOverlappedTransfer()

    If EventObject = 0 Then
        EventObject = CreateEvent _
            (Security, _
            True, _
            True, _
            "")
    End If
    
    HIDOverlapped.offset = 0
    HIDOverlapped.OffsetHigh = 0
    HIDOverlapped.hEvent = EventObject

End Sub






'写USB设备
Public Sub WriteReport(WriteData As String)

'Send data to the device.

Dim count As Integer
Dim NumberOfBytesRead As Long
Dim NumberOfBytesToSend As Long
Dim NumberOfBytesWritten As Long
Dim ReadBuffer() As Byte
Dim SendBuffer() As Byte
Dim Cwritlong As Integer
Dim Wcont As Integer
'******************************************************************************
'WriteFile
'Sends a report to the device.
'Returns: success or failure.
'Requires: the handle returned by CreateFile and
'The output report byte length returned by HidP_GetCaps
'******************************************************************************

    
    'The SendBuffer array begins at 0, so subtract 1 from the number of bytes.
    ReDim SendBuffer(Capabilities.OutputReportByteLength - 1)
    
    Cwritlong = Len(WriteData)
    'The first byte is the Report ID, the second byte is the number of data
    SendBuffer(0) = 0
    
    For count = 1 To Cwritlong
        '从文本框中取出数放到发送中
        SendBuffer(count) = Asc(Mid(WriteData, count, 1))
    Next count

    NumberOfBytesWritten = 0
    
    Result = WriteFile _
        (WriteHandle, _
        SendBuffer(0), _
        CLng(Capabilities.OutputReportByteLength), _
        NumberOfBytesWritten, _
        0)
    If Result <> 1 Then
        Open LogFilePath For Append As #1
        Print #1, "[" + CStr(Format(Time, "hh:mm:ss")) + "]==> " + "Sent command fail, please retry."
        Close #1
    Else
'        PrintLog "Sent Command: " + """" + WriteData + """"
    End If
End Sub



Public Function ReadReport(ReadData As String) As Boolean

    'Read data from the device.
    Dim temp As String
    Dim count
    Dim NumberOfBytesRead As Long
    
    'Allocate a buffer for the report.
    'Byte 0 is the report ID.
    
    Dim ReadBuffer() As Byte
    
    '******************************************************************************
    'ReadFile
    'Returns: the report in ReadBuffer.
    'Requires: a device handle returned by CreateFile
    '(for overlapped I/O, CreateFile must be called with FILE_FLAG_OVERLAPPED),
    'the Input report length in bytes returned by HidP_GetCaps,
    'and an overlapped structure whose hEvent member is set to an event object.
    '******************************************************************************
    
    If DeviceChecked = False Then
        PrintLog "读出失败请先联接设备！"
        Exit Function
    End If
          
    
          
    'The ReadBuffer array begins at 0, so subtract 1 from the number of bytes.
    
    ReDim ReadBuffer(Capabilities.InputReportByteLength - 1)
    
    
    'Do an overlapped ReadFile.
    'The function returns immediately, even if the data hasn't been received yet.
    
    Result = ReadFile _
        (ReadHandle, _
        ReadBuffer(0), _
        CLng(Capabilities.InputReportByteLength), _
        NumberOfBytesRead, _
        HIDOverlapped)
    
'    PrintLog "waiting for ReadFile"
    
    
    '******************************************************************************
    'WaitForSingleObject
    'Used with overlapped ReadFile.
    'Returns when ReadFile has received the requested amount of data or on timeout.
    'Requires an event object created with CreateEvent
    'and a timeout value in milliseconds.
    '******************************************************************************
    Result = WaitForSingleObject _
        (EventObject, _
        100)
    
    'Find out if ReadFile completed or timeout.
    
    Select Case Result
        Case WAIT_OBJECT_0
            
            'ReadFile has completed
            ReadReport = True
     '       printlog "ReadFile completed successfully."
        Case WAIT_TIMEOUT
            
            'Timeout
            ReadReport = False
            PrintLog "Readfile timeout"
            
            'Cancel the operation
            
            '*************************************************************
            'CancelIo
            'Cancels the ReadFile
            'Requires the device handle.
            'Returns non-zero on success.
            '*************************************************************
            Result = CancelIo _
                (ReadHandle)
            PrintLog "************ReadFile timeout*************"
            PrintLog "CancelIO"
            
            'The timeout may have been because the device was removed,
            'so close any open handles and
            'set MyDeviceDetected=False to cause the application to
            'look for the device on the next attempt.
            
            'CloseHandle (HIDHandle)
            'Call DisplayResultOfAPICall("CloseHandle (HIDHandle)")
            'CloseHandle (ReadHandle)
            'Call DisplayResultOfAPICall("CloseHandle (ReadHandle)")
            'MyDeviceDetected = False
        Case Else
            ReadReport = False
            PrintLog "Readfile undefined error"
    End Select
    
    For count = 1 To UBound(ReadBuffer)
        temp = temp + Chr(ReadBuffer(count))
    Next count
    
    ReadData = temp
'    PrintLog "Receive Data: " + """" + temp + """"
    
    '******************************************************************************
    'ResetEvent
    'Sets the event object in the overlapped structure to non-signaled.
    'Requires a handle to the event object.
    'Returns non-zero on success.
    '******************************************************************************
    
    Call ResetEvent(EventObject)
    
End Function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Function FindTheHid() As Boolean

'Makes a series of API calls to locate the desired HID-class device.
'Returns True if the device is detected, False if not detected.
Dim itemX As ListItem
Dim Buffer(100) As Byte
Dim ProductName As String
Dim nUSBDeviceNum As Integer
Dim count As Integer
Dim GUIDString As String
Dim HidGuid As GUID
Dim MemberIndex As Long

LastDevice = False
If MyDeviceDetected = True Then
    Result = CloseHandle _
        (HIDHandle)
    MyDeviceDetected = False
End If

'Values for SECURITY_ATTRIBUTES structure:

Security.lpSecurityDescriptor = 0
Security.bInheritHandle = True
Security.nLength = Len(Security)

'******************************************************************************
'一、获得HID设备的GUID.
'HidD_GetHidGuid
'Get the GUID for all system HIDs.
'Returns: the GUID in HidGuid.
'The routine doesn't return a value in Result
'but the routine is declared as a function for consistency with the other API calls.
'******************************************************************************

Result = HidD_GetHidGuid(HidGuid)

GUIDString = _
    Hex$(HidGuid.data1) & "-" & _
    Hex$(HidGuid.data2) & "-" & _
    Hex$(HidGuid.data3) & "-"

For count = 0 To 7

    'Ensure that each of the 8 bytes in the GUID displays two characters.
    
    If HidGuid.data4(count) >= &H10 Then
        GUIDString = GUIDString & Hex$(HidGuid.data4(count)) & " "
    Else
        GUIDString = GUIDString & "0" & Hex$(HidGuid.data4(count)) & " "
    End If
Next count


'******************************************************************************
'二、找出所有已连接HID设备：
'SetupDiGetClassDevs
'Returns: a handle to a device information set for all installed devices.
'Requires: the HidGuid returned in GetHidGuid.
'******************************************************************************

DeviceInfoSet = SetupDiGetClassDevs _
    (HidGuid, _
    vbNullString, _
    0, _
    (DIGCF_PRESENT Or DIGCF_DEVICEINTERFACE))
    
DataString = GetDataString(DeviceInfoSet, 32)

'******************************************************************************
'三、列举每一个HID设备:
'SetupDiEnumDeviceInterfaces
'On return, MyDeviceInterfaceData contains the handle to a
'SP_DEVICE_INTERFACE_DATA structure for a detected device.
'Requires:
'the DeviceInfoSet returned in SetupDiGetClassDevs.
'the HidGuid returned in GetHidGuid.
'An index to specify a device.
'******************************************************************************

'Begin with 0 and increment until no more devices are detected.

MemberIndex = 0

Do
    'The cbSize element of the MyDeviceInterfaceData structure must be set to
    'the structure's size in bytes. The size is 28 bytes.
    
    MyDeviceInterfaceData.cbSize = LenB(MyDeviceInterfaceData)
    Result = SetupDiEnumDeviceInterfaces _
        (DeviceInfoSet, _
        0, _
        HidGuid, _
        MemberIndex, _
        MyDeviceInterfaceData)
    
    If Result = 0 Then
'        PrintLog "  设备未找到！"
        LastDevice = True
    Else    'If a device exists, display the information returned.
  
        
        '******************************************************************************
        '四、取设备的路径
        'SetupDiGetDeviceInterfaceDetail
        'Returns: an SP_DEVICE_INTERFACE_DETAIL_DATA structure
        'containing information about a device.
        'To retrieve the information, call this function twice.
        'The first time returns the size of the structure in Needed.
        'The second time returns a pointer to the data in DeviceInfoSet.
        'Requires:
        'A DeviceInfoSet returned by SetupDiGetClassDevs and
        'an SP_DEVICE_INTERFACE_DATA structure returned by SetupDiEnumDeviceInterfaces.
        '*******************************************************************************
        
        MyDeviceInfoData.cbSize = Len(MyDeviceInfoData)
        Result = SetupDiGetDeviceInterfaceDetail _
           (DeviceInfoSet, _
           MyDeviceInterfaceData, _
           0, _
           0, _
           Needed, _
           0)
        
        DetailData = Needed
            

        
        'Store the structure's size.
        
        MyDeviceInterfaceDetailData.cbSize = _
            Len(MyDeviceInterfaceDetailData)
        
        'Use a byte array to allocate memory for
        'the MyDeviceInterfaceDetailData structure
        
        ReDim DetailDataBuffer(Needed)
        
        'Store cbSize in the first four bytes of the array.
        
        Call RtlMoveMemory _
            (DetailDataBuffer(0), _
            MyDeviceInterfaceDetailData, _
            4)
        
        'Call SetupDiGetDeviceInterfaceDetail again.
        'This time, pass the address of the first element of DetailDataBuffer
        'and the returned required buffer size in DetailData.
        
        Result = SetupDiGetDeviceInterfaceDetail _
           (DeviceInfoSet, _
           MyDeviceInterfaceData, _
           VarPtr(DetailDataBuffer(0)), _
           DetailData, _
           Needed, _
           0)
        
        
        'Convert the byte array to a string.
        
        DevicePathName = CStr(DetailDataBuffer())
        
        'Convert to Unicode.
        
        DevicePathName = StrConv(DevicePathName, vbUnicode)
        
        'Strip cbSize (4 bytes) from the beginning.
        
        DevicePathName = Right$(DevicePathName, Len(DevicePathName) - 4)
                
        '******************************************************************************
        '五、取得设备的标示代号:
        'CreateFile
        'Returns: a handle that enables reading and writing to the device.
        'Requires:
        'The DevicePathName returned by SetupDiGetDeviceInterfaceDetail.
        '******************************************************************************
    
        HIDHandle = CreateFile _
            (DevicePathName, _
            GENERIC_READ Or GENERIC_WRITE, _
            (FILE_SHARE_READ Or FILE_SHARE_WRITE), _
            Security, _
            OPEN_EXISTING, _
            0&, _
            0)
            
        
        'Now we can find out if it's the device we're looking for.
        
        '******************************************************************************
        '取得厂商与产品ID：
        'HidD_GetAttributes
        'Requests information from the device.
        'Requires: The handle returned by CreateFile.
        'Returns: an HIDD_ATTRIBUTES structure containing
        'the Vendor ID, Product ID, and Product Version Number.
        'Use this information to determine if the detected device
        'is the one we're looking for.
        '******************************************************************************
        
        'Set the Size property to the number of bytes in the structure.
        
        DeviceAttributes.Size = LenB(DeviceAttributes)
        Result = HidD_GetAttributes _
            (HIDHandle, _
            DeviceAttributes)
            
        ProductName = ""
        If HidD_GetProductString(HIDHandle, VarPtr(Buffer(0)), UBound(Buffer)) Then
           For count = 0 To 82 Step 2                         '42 Byte
           ProductName = ProductName & Chr(Buffer(count))
           Next count
        End If

        If ProductName <> "" Then
            nUSBDeviceNum = nUSBDeviceNum + 1
        End If
        
        If (DeviceAttributes.VendorID = MyVendorID) And _
            (DeviceAttributes.ProductID = MyProductID) Then
                
            Call GetDeviceCapabilities(HIDHandle)
            Call PrepareForOverlappedTransfer
            ReadHandle = HIDHandle
            WriteHandle = HIDHandle
            DeviceChecked = True
            'It's the desired device.
'            PrintLog "  设备找到了！"
            DeviceName = ProductName
            MyDeviceDetected = True
            FindTheHid = True
        Else
            MyDeviceDetected = False
            
            'If it's not the one we want, close its handle.
            
            Result = CloseHandle _
                (HIDHandle)
        End If
    End If
    
    'Keep looking until we find the device or there are no more left to examine.
    
    MemberIndex = MemberIndex + 1
Loop Until (LastDevice = True) Or (MyDeviceDetected = True)

'Free the memory reserved for the DeviceInfoSet returned by SetupDiGetClassDevs.

Result = SetupDiDestroyDeviceInfoList _
    (DeviceInfoSet)

End Function


