-- RunMorningResearch.applescript
--
-- Excel(Mac) VBA의 AppleScriptTask에서 호출되는 브리지 스크립트.
-- morning_research.sh를 실행해 USD/KRW 환율과 금(Gold) 가격을
-- ~/Desktop/마스터시트_원자재.csv 에 한 줄 append 시킨다.
--
-- 설치 위치(고정): ~/Library/Application Scripts/com.microsoft.Excel/RunMorningResearch.applescript
--
-- 핸들러 이름(run_research)과 파라미터 1개는 AppleScriptTask 규격상 필수.

on run_research(dummyArg)
	set scriptPath to (POSIX path of (path to home folder)) & "VBA/scripts/morning_research.sh"
	try
		do shell script "/bin/bash " & quoted form of scriptPath
		return "OK"
	on error errMsg
		return "ERROR: " & errMsg
	end try
end run_research
