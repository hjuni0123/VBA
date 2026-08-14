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
-- 성공 시 CSV 파일의 실제 경로(POSIX path)를 문자열로 반환한다.
-- (한글 파일명을 VBA 코드에 직접 적으면 macOS의 NFD 정규화 때문에
--  같은 글자처럼 보여도 바이트가 달라 Dir()/Open이 파일을 못 찾는
--  문제가 생길 수 있어, 실제 파일시스템에서 찾은 경로 문자열을
--  그대로 돌려주는 방식으로 우회한다.)

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
		return csvPath
	on error errMsg
		return "ERROR: " & errMsg
	end try
end run_research
