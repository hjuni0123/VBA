-- RunMorningResearch.applescript
--
-- Excel(Mac) VBA의 AppleScriptTask에서 호출되는 브리지 스크립트.
-- morning_research.sh를 실행해 USD/KRW 환율과 금(Gold) 가격을
-- ~/Desktop/마스터시트_원자재.csv 에 한 줄 append 시킨다.
--
-- 설치 위치(고정): ~/Library/Application Scripts/com.microsoft.Excel/RunMorningResearch.applescript
--
-- 핸들러 이름(run_research)과 파라미터 1개는 AppleScriptTask 규격상 필수.
--
-- VBA의 Dir()/Open은 Mac에서 한글(비 ASCII) 파일명을 다룰 때
-- 정규화(NFC/NFD) 문제로 파일을 못 찾는 경우가 있어, 아예 VBA가
-- 파일을 직접 열지 않도록 이 스크립트가 CSV의 "마지막 줄 내용"
-- 자체를 읽어서 문자열로 돌려준다.

on run_research(dummyArg)
	set scriptPath to (POSIX path of (path to home folder)) & "VBA/scripts/morning_research.sh"
	try
		do shell script "/bin/bash " & quoted form of scriptPath
	on error errMsg
		return "ERROR: " & errMsg
	end try

	try
		set desktopPath to POSIX path of (path to desktop folder)
		set csvPath to do shell script "ls -t " & quoted form of desktopPath & "*.csv 2>/dev/null | head -1"
		if csvPath is "" then
			return "ERROR: CSV_NOT_FOUND"
		end if

		set lastLine to do shell script "tail -n 1 " & quoted form of csvPath
		if lastLine is "" then
			return "ERROR: CSV_EMPTY"
		end if
		return lastLine
	on error errMsg
		return "ERROR: " & errMsg
	end try
end run_research
