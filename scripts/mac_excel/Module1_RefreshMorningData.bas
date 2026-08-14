Attribute VB_Name = "Module1"
' 표준 모듈(Module1)에 붙여넣을 코드.
'
' RefreshMorningData:
'   1) AppleScriptTask로 morning_research.sh를 실행시켜
'      ~/Desktop/마스터시트_원자재.csv 에 최신 한 줄을 append하고,
'      그 마지막 줄의 내용을 그대로 문자열로 돌려받음
'      (VBA의 Dir()/Open은 Mac에서 한글 파일명 정규화 문제로
'       파일을 못 찾는 경우가 있어, 파일을 직접 열지 않고
'       AppleScript가 읽은 내용을 그대로 사용한다)
'   2) 그 내용을 "Dashboard" 시트에 표시
'   3) "Log" 시트에 같은 값을 누적 (같은 타임스탬프면 중복 추가 안 함)
'
' 필요 시트 구조 (미리 만들어두어야 함):
'   - Dashboard!A2="수집일시", B2=(값), A3="USD/KRW", B3=(값), A4="Gold(XAUUSD)", B4=(값)
'   - Log!A1:C1 = 수집일시 / USD_KRW / Gold  (헤더)
'
' 새로고침 버튼을 만들고 싶다면 도형/버튼에 이 매크로(RefreshMorningData)를 연결하면 됨.

Sub RefreshMorningData()
    On Error GoTo ErrHandler

    Dim lastLine As String
    lastLine = AppleScriptTask("RunMorningResearch.applescript", "run_research", "")

    If Left$(lastLine, 5) = "ERROR" Then
        MsgBox "데이터 수집 실패: " & lastLine, vbExclamation
        Exit Sub
    End If

    Dim fields() As String
    fields = Split(lastLine, ",")
    If UBound(fields) < 2 Then
        MsgBox "CSV 형식이 예상과 다릅니다: " & lastLine, vbExclamation
        Exit Sub
    End If

    Dim dashboardWs As Worksheet
    Set dashboardWs = ThisWorkbook.Sheets("Dashboard")
    dashboardWs.Range("B2").Value = fields(0) ' 수집일시
    dashboardWs.Range("B3").Value = fields(1) ' USD/KRW
    dashboardWs.Range("B4").Value = fields(2) ' Gold(XAUUSD)

    Dim logWs As Worksheet
    Set logWs = ThisWorkbook.Sheets("Log")
    Dim lastRow As Long
    lastRow = logWs.Cells(logWs.Rows.Count, 1).End(xlUp).Row
    If lastRow < 1 Then lastRow = 1 ' 헤더 행 보정

    If logWs.Cells(lastRow, 1).Value <> fields(0) Then
        logWs.Cells(lastRow + 1, 1).Value = fields(0)
        logWs.Cells(lastRow + 1, 2).Value = fields(1)
        logWs.Cells(lastRow + 1, 3).Value = fields(2)
    End If

    Exit Sub

ErrHandler:
    MsgBox "데이터 갱신 중 오류: " & Err.Description, vbCritical
End Sub
