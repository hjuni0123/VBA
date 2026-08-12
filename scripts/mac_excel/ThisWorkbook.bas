Attribute VB_Name = "ThisWorkbook"
' ThisWorkbook 모듈에 붙여넣을 코드.
' 엑셀 파일을 "열 때" 딱 한 번만 자동으로 최신 데이터를 갱신한다.
' (백그라운드 상시 갱신 아님 — 파일을 열 때만 실행)

Private Sub Workbook_Open()
    RefreshMorningData
End Sub
