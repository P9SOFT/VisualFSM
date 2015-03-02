
'for Arc
Private vStringData() As Object
Private aParam(1) As Object
Private iKey As Integer
Private g_iPrimaryArcStrID As Integer 'primary key

' for Action
Private vStringData2() As Object
Private aParam2(1) As Object
Private iKey2 As Integer
Private g_iPrimaryActionStrID As Integer 'primary key

' for Branch
Private vStringData3() As Object
Private aParam3(1) As Object
Private iKey3 As Integer

Public Function InitReservedWord()
    'Action
    Call boolIsExistString2("Change_Ani", 1)
    Call boolIsExistString2("Blend_Ani", 2)
    Call boolIsExistString2("Save_LastAni", 3)
    Call boolIsExistString2("Deactivate_Ani", 4)
End Function

Public Sub ExportToXML()
    iKey = 0
    iKey2 = 0
    iKey3 = 0

    ' 1 ~ 99 까지는 예약 arc 를 위해 할당.
    g_iPrimaryArcStrID = 100

    ' 1 ~ 99 까지는 예약 action 을 위해 할당.
    g_iPrimaryActionStrID = 100

    'Declare object variables as Visio object types.
    Dim vsoDocument As Visio.Document
    Dim vsoDocuments As Visio.Documents
    Dim vsoPages As Visio.Pages
    Dim vsoPage As Visio.Page
    Dim vsoShapes As Visio.Shapes
    Dim vsoShape As Visio.Shape

    Debug.Print()
    Debug.Print("========================================================")
    Debug.Print "Run Time : "; Time
    Debug.Print("=========================================================")

    'reserved word
    Call InitReservedWord()

    'Iterate through all open documents.
    vsoDocuments = Application.Documents
    For Each vsoDocument In vsoDocuments
        If vsoDocument.Type = visTypeDrawing Then

            'Print the drawing name in the Visual Basic Editor
            'Immediate window.
            Debug.Print "Doc name : "; vsoDocument.FullName
            Debug.Print()

            Dim xmldoc As New MSXML.DOMDocument
            xmldoc.async = False
            xmldoc.validateOnParse = False

            Dim rootnode As MSXML.IXMLDOMElement

            Dim TxtFileName As String
            TxtFileName = "export_define.txt"
            'TxtFileName = Replace(vsoDocument.Name, "vsd", "txt")

            Dim FileNum As Integer
            FileNum = FreeFile
            Open TxtFileName For Output As #FileNum
            Close #FileNum

            vsoPages = vsoDocument.Pages
            If FindPage(vsoPage, "Sht_Start", vsoPages) Then
                rootnode = xmldoc.createElement("Root")

                'define sheet name
                Dim Page As Visio.Page
                For Each Page In Pages
                    Dim str1, str2 As String
                    str1 = "#define FSM_" & UCase(Page.Name) & " (" & """" & Page.Name & """)"

                    Open TxtFileName For Append As #FileNum
                        Print #FileNum, str1
                    Close(FileNum)
                Next

                'new line after sheet name
                Dim strNewLine As String
                strNewLine = ""
                Open TxtFileName For Append As #FileNum
                    Print #FileNum, strNewLine
                Close(FileNum)

                For Each vsoPage In vsoPages
                    Call ExportFSM(rootnode, vsoPage, vsoPages, TxtFileName)
                Next

                rootnode = xmldoc.appendChild(rootnode)

                'Call ExportActionStringID(rootnode, TxtFileName)

                Dim FileName As String
                FileName = Replace(vsoDocument.Name, "vsd", "xml")
                Debug.Print "Saving XML File : "; FileName
                xmldoc.Save(FileName)
                Call xmldoc.removeChild(rootnode)
            Else
                Call WarningMsg("No Start FSM Page!!!")
            End If

            Debug.Print("----------------------------------------------------------")

        End If

    Next

End Sub

Public Function FindPage(ByVal Result As Visio.Page, ByVal Name As String, ByVal Pages As Visio.Pages) As Boolean
    FindPage = False
    Dim Page As Visio.Page
    For Each Page In Pages
        If Page.Name = Name Then
            Result = Page
            FindPage = True
            Exit Function
        End If
    Next
End Function

Public Function CountShape(ByVal Name As String, ByVal Shapes As Visio.Shapes) As Integer
    CountShape = 0
    Dim Shape As Visio.Shape
    For Each Shape In Shapes
        If Shape.Name Like Name Then
            CountShape = CountShape + 1
        End If
    Next
End Function

Public Function ExportFSM(ByVal ParentNode As MSXML.IXMLDOMElement, ByVal ThisPage As Visio.Page, ByVal Pages As Visio.Pages, ByVal FileName As String)

    Debug.Print "FSM : "; ThisPage.Name

    '이 shape를 위한 node를 생성한다.
    Dim ThisNode As MSXML.IXMLDOMElement
    ThisNode = ParentNode.ownerDocument.createElement("FSM")
    Call ThisNode.setAttribute("Name", ThisPage.Name)

    Dim Shape As Visio.Shape
    Dim Page As Visio.Page

    'Start는 반드시 하나 존재해야 한다!!!
    Dim Cnt As Integer
    Cnt = CountShape("State Start*", ThisPage.Shapes)
    If Not (Cnt = 1) Then
        Call ErrorMsg("State Start Count is not 1 !!!")
        Exit Function
    End If

    For Each Shape In ThisPage.Shapes

        Debug.Print Tab(5); "Shape : "; Shape.Text; "     "; Shape.Master.Name

        'Shape의 종류에 따라서 적절한 Export function을 호출해준다.
        If Shape.Master.Name Like "State*" Then
            Call ExportState(ThisNode, Shape, FileName)
        ElseIf Shape.Master.Name Like "Arc*" Then
            Call ExportArc(ThisNode, Shape, FileName)
        ElseIf Shape.Master.Name Like "Branch*" Then
            Call ExportBranch(ThisNode, Shape, FileName)
        Else
            Call WarningMsg("Unknown Shape!!!")
        End If

    Next

    'Root node에 붙인다.
    Call ParentNode.appendChild(ThisNode)

End Function

Public Function ExportState(ByVal ParentNode As MSXML.IXMLDOMElement, ByVal Shape As Visio.Shape, ByVal FileName As String)

    '이 shape를 위한 node를 생성한다.
    Dim node As MSXML.IXMLDOMElement
    node = ParentNode.ownerDocument.createElement("State")
    Call node.setAttribute("Name", Shape.Text)
    Call node.setAttribute("ID", Shape.ID)

    If Shape.Master.Name Like "State Start*" Then
        Call node.setAttribute("State_Type", "Start")
    ElseIf Shape.Master.Name Like "State End*" Then
        Call node.setAttribute("State_Type", "End")
    Else
        Call node.setAttribute("State_Type", "Normal")
    End If

    Call node.setAttribute("Enter_Actions", Shape.Shapes(1).Text)
    Call node.setAttribute("Exit_Actions", Shape.Shapes(3).Text)

    'FSM node에 붙인다.
    Call ParentNode.appendChild(node)

    '이미 존재하는 스트링인지 체크
    Dim nStrID As Integer

    'EnterAction
    Dim strEnterID As String
    Dim strExitID As String

    'definition file
    If Not (Shape.Shapes(1).Text = vbNullString) Then
        Dim FileNum As Integer
        Dim str1 As String
        FileNum = FreeFile

        ' 뉴라인으로 구분된 여러개일 경우
        Dim strToken As String
        Dim vToken As Object
        vToken = Split(Shape.Shapes(1).Text, vbLf, -1, 1)
        Dim iCount As Integer
        iCount = UBound(vToken)

        For ii = 0 To iCount
            strToken = vToken(ii)

            Dim strActionName As String
            Dim vActionToken As Object
            vActionToken = Split(strToken, " ", -1, 1)
            strActionName = vActionToken(0)

            Dim bIsExist As Boolean
            bIsExist = False

            ' 중복 스트링인지 검사
            g_iPrimaryActionStrID = g_iPrimaryActionStrID + 1
            nStrID = g_iPrimaryActionStrID
            If (boolIsExistString2(strActionName, nStrID)) Then
                bIsExist = True
            End If

            strEnterID = strEnterID & nStrID & " "

            If (bIsExist = False) Then
                ' 스트링에 해당하는 ID 출력
                str1 = "#define FSM_ACT_" & UCase(strActionName) & " " & nStrID
                Open FileName For Append As #FileNum
                Print #FileNum, str1
                Close(FileNum)

                ' 스트링 출력
                'str1 = "#define FSM_ACT_" & UCase(strActionName) & " (" & """" & strActionName & """)"
                'Open FileName For Append As #FileNum
                'Print #FileNum, str1
                'Close FileNum
            End If
        Next
    End If

    Call node.setAttribute("Enter_Actions_StrID", strEnterID)

    'ExitAction
    If Not (Shape.Shapes(3).Text = vbNullString) Then
        Dim FileNum2 As Integer
        Dim str2 As String
        FileNum2 = FreeFile

        ' 뉴라인으로 구분된 여러개일 경우
        Dim strToken2 As String
        Dim vToken2 As Object
        vToken2 = Split(Shape.Shapes(3).Text, vbLf, -1, 1)
        Dim iCount2 As Integer
        iCount2 = UBound(vToken2)
        For ii2 = 0 To iCount2
            strToken2 = vToken2(ii2)

            Dim strActionName2 As String
            Dim vActionToken2 As Object
            vActionToken2 = Split(strToken2, " ", -1, 1)
            strActionName2 = vActionToken2(0)

            Dim bIsExist2 As Boolean
            bIsExist2 = False

            ' 중복 스트링인지 검사
            g_iPrimaryActionStrID = g_iPrimaryActionStrID + 1
            nStrID = g_iPrimaryActionStrID
            If (boolIsExistString2(strActionName2, nStrID)) Then
                bIsExist2 = True
            End If

            strExitID = strExitID & nStrID & " "

            If (bIsExist2 = False) Then
                ' 스트링에 해당하는 ID 출력
                str2 = "#define FSM_ACT_" & UCase(strActionName2) & " " & nStrID
                Open FileName For Append As #FileNum2
                    Print #FileNum2, str2
                Close(FileNum2)

                ' 스트링 출력
                'str2 = "#define FSM_ACT_" & UCase(strActionName2) & " (" & """" & strActionName2 & """)"
                'Open FileName For Append As #FileNum2
                '    Print #FileNum2, str2
                'Close FileNum2
            End If
        Next
    End If

    Call node.setAttribute("Exit_Actions_StrID", strExitID)


End Function

Public Function ExportActionStringID(ByVal ParentNode As MSXML.IXMLDOMElement, ByVal FileName As String)
    Dim ThisNode As MSXML.IXMLDOMElement
    ThisNode = ParentNode.ownerDocument.createElement("Action")
    //Call ThisNode.setAttribute("String", "Start")

    'Root node에 붙인다.
    Call ParentNode.appendChild(ThisNode)

End Function


Public Function ExportArc(ByVal ParentNode As MSXML.IXMLDOMElement, ByVal Shape As Visio.Shape, ByVal FileName As String)

    '이 shape를 위한 node를 생성한다.
    Dim node As MSXML.IXMLDOMElement
    node = ParentNode.ownerDocument.createElement("Arc")

    If Shape.Connects.Count < 2 Then
        Call ErrorMsg("Connection Cnt < 2")
        Exit Function
    End If

    '스트링값을 정수형으로 관리하기 위해 사용
    Dim bIsExist As Boolean
    Dim nStrID As Integer
    bIsExist = False

    g_iPrimaryArcStrID = g_iPrimaryArcStrID + 1
    nStrID = g_iPrimaryArcStrID

    If Shape.Text = "End_Ani" Then  '예약어
        nStrID = 1
    End If

    If boolIsExistString(Shape.Text, nStrID) Then
        bIsExist = True
    End If

    Call node.setAttribute("Event", Shape.Text)
    Call node.setAttribute("StrID", nStrID)
    Call node.setAttribute("Link1", Shape.Connects(1).ToSheet.ID)
    Call node.setAttribute("Link2", Shape.Connects(2).ToSheet.ID)

    'FSM node에 붙인다.
    Call ParentNode.appendChild(node)

    If (bIsExist = True) Then
        Exit Function
    End If

    If (Shape.Text = "") Then
        Exit Function
    End If

    If Not (Shape.Text Like "Timer *") Then
        Dim FileNum As Integer
        Dim str1 As String
        FileNum = FreeFile
        str1 = "#define FSM_ARC_" & UCase(Shape.Text) & " " & nStrID
        'str1 = "#define FSM_ARC_" & UCase(Shape.Text) & " " & " _T(" & """" & Shape.Text & """)"

        Open FileName For Append As #FileNum
            Print #FileNum, str1
        Close(FileNum)
    End If

End Function

Public Function ExportBranch(ByVal ParentNode As MSXML.IXMLDOMElement, ByVal Shape As Visio.Shape, ByVal FileName As String)

    '이 shape를 위한 node를 생성한다.
    Dim node As MSXML.IXMLDOMElement
    node = ParentNode.ownerDocument.createElement("Branch")

    Call node.setAttribute("Function", Shape.Text)
    Call node.setAttribute("ID", Shape.ID)

    'FSM node에 붙인다.
    Call ParentNode.appendChild(node)

    '이미 존재하는 스트링인지 체크
    Dim bIsExist As Boolean
    Dim nStrID As Integer
    bIsExist = False

    nStrID = Shape.ID
    If boolIsExistString3(Shape.Text, nStrID) Then
        bIsExist = True
    End If

    If (bIsExist = True) Then
        Exit Function
    End If

    If Not (Shape.Text = vbNullString) Then
        Dim FileNum As Integer
        Dim str1, str2 As String
        FileNum = FreeFile
        str1 = "#define FSM_BRANCH_" & UCase(Shape.Text) & " (" & """" & Shape.Text & """)"

        Open FileName For Append As #FileNum
            Print #FileNum, str1
        Close(FileNum)
    End If


End Function

'for Arc
Public Function boolIsExistString(ByVal sText As String, ByVal DupKey As Integer) As Boolean
    boolIsExistString = False
    Dim i As Integer

    For i = 0 To iKey - 1

        ''이미 값이 있는 경우
        If sText = vStringData(i)(1) Then

            ''키값리턴
            DupKey = vStringData(i)(0)
            boolIsExistString = True
            Exit Function

        End If

    Next

    aParam(0) = DupKey
    aParam(1) = sText

    ''추가되면 배열을 증가
    ReDim Preserve vStringData(iKey)
    vStringData(iKey) = aParam

    ''추가되면 키값증가
    iKey = iKey + 1

End Function

' for Action
Public Function boolIsExistString2(ByVal sText As String, ByVal DupKey As Integer) As Boolean
    boolIsExistString2 = False
    Dim i As Integer

    For i = 0 To iKey2 - 1

        ''이미 값이 있는 경우
        If sText = vStringData2(i)(1) Then

            ''키값리턴
            DupKey = vStringData2(i)(0)
            boolIsExistString2 = True
            Exit Function

        End If

    Next

    aParam2(0) = DupKey
    aParam2(1) = sText

    ''추가되면 배열을 증가
    ReDim Preserve vStringData2(iKey2)
    vStringData2(iKey2) = aParam2

    ''추가되면 키값증가
    iKey2 = iKey2 + 1

End Function

' for Branch
Public Function boolIsExistString3(ByVal sText As String, ByVal DupKey As Integer) As Boolean
    boolIsExistString3 = False
    Dim i As Integer

    For i = 0 To iKey3 - 1

        ''이미 값이 있는 경우
        If sText = vStringData3(i)(1) Then

            ''키값리턴
            DupKey = vStringData3(i)(0)
            boolIsExistString3 = True
            Exit Function

        End If

    Next

    aParam3(0) = DupKey
    aParam3(1) = sText

    ''추가되면 배열을 증가
    ReDim Preserve vStringData3(iKey3)
    vStringData3(iKey3) = aParam3

    ''추가되면 키값증가
    iKey3 = iKey3 + 1

End Function

Public Function ErrorMsg(ByVal Text As String)
    Debug.Print "<<<<<<<<<< Error!!! "; Text; ">>>>>>>>>>"
End Function

Public Function WarningMsg(ByVal Text As String)
    Debug.Print "[[ Warning!!! "; Text; "]]"
End Function









