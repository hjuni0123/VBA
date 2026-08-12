# Mac Excel에서 "파일 열 때만" 자동 최신화하기

크론탭으로 백그라운드에서 상시 도는 방식이 아니라, **엑셀 파일을 열 때 딱 한 번**
`morning_research.sh`를 실행해서 최신 USD/KRW 환율 · 금(Gold) 가격을 시트에 반영하는 방식입니다.

## 왜 AppleScript가 끼어있나요?

Mac용 Excel VBA는 Windows VBA와 달리 `WinHTTP.WinHTTPRequest`, `MSXML2.XMLHTTP` 같은
COM 기반 HTTP 객체가 없습니다. 대신 macOS의 `AppleScriptTask` 기능으로 쉘 명령(`curl`,
우리가 만든 `morning_research.sh`)을 실행시키고, 그 결과로 갱신된 CSV를 VBA가 읽어오는
방식을 씁니다.

```
Excel(Workbook_Open)
   └─ VBA: AppleScriptTask 호출
         └─ AppleScript: do shell script "morning_research.sh"
               └─ curl/jq/awk 로 환율·금값 수집 → CSV append
   └─ VBA: CSV 마지막 줄을 읽어서 시트에 기록
```

## 설치 순서

### 1) AppleScript 브리지 파일 배치

`RunMorningResearch.applescript` 파일을 아래 **고정 경로**에 복사합니다. (없으면 폴더 새로 생성)

```bash
mkdir -p ~/Library/Application\ Scripts/com.microsoft.Excel
cp ~/VBA/scripts/mac_excel/RunMorningResearch.applescript \
   ~/Library/Application\ Scripts/com.microsoft.Excel/
```

### 2) 쉘 스크립트 실행 권한 확인

```bash
chmod +x ~/VBA/scripts/morning_research.sh
```

### 3) 엑셀 시트 구조 만들기

워크북에 시트 2개를 만듭니다.

- **Dashboard** 시트
  - A2: `수집일시`, B2: (자동 채워짐)
  - A3: `USD/KRW`, B3: (자동 채워짐)
  - A4: `Gold(XAUUSD)`, B4: (자동 채워짐)
- **Log** 시트
  - A1: `수집일시`, B1: `USD_KRW`, C1: `Gold` (헤더만 미리 입력)

### 4) VBA 코드 삽입

`Option ⌥ + F11` (또는 개발 도구 탭 → Visual Basic)로 VBA 편집기를 열고:

1. 프로젝트 탐색기에서 `ThisWorkbook`을 더블클릭 → `scripts/mac_excel/ThisWorkbook.bas` 내용을 붙여넣기
2. 오른쪽 클릭 → 삽입 → 모듈(Module1) → `scripts/mac_excel/Module1_RefreshMorningData.bas` 내용을 붙여넣기
3. 저장 시 파일 형식을 **매크로 사용 통합 문서(.xlsm)** 로 저장

### 5) 매크로 보안 설정

Excel 환경설정 → 보안 및 개인정보 보호 → 매크로 보안에서
"모든 매크로 포함(알림 없음)" 또는 "디지털 서명된 매크로만 포함"이 아니라
최소 "알림과 함께 모든 매크로 포함"으로 설정 후, 파일 열 때 매크로 사용을 허용해야 합니다.

### 6) 최초 실행 시 macOS 권한 팝업

파일을 처음 열면 macOS가 "Excel이 다른 앱을 제어하려고 합니다" 같은 자동화 권한 팝업을
띄웁니다. **허용**을 눌러야 `do shell script`가 정상 동작합니다.
(나중에 거부했다면 `시스템 설정 > 개인정보 보호 및 보안 > 자동화`에서 Excel 항목을 다시 켜면 됩니다.)

## 동작 확인

파일을 새로 열면:
1. 몇 초간 백그라운드에서 curl 호출 (네트워크 상황에 따라 1~3초)
2. Dashboard 시트 B2~B4에 최신 값 표시
3. Log 시트 맨 아래에 한 줄 추가 (같은 타임스탬프면 중복 추가 안 함)

수동으로 다시 갱신하고 싶다면(재오픈 없이), 시트에 도형/버튼을 하나 만들고
매크로 지정에서 `RefreshMorningData`를 연결하면 버튼 클릭만으로 재실행됩니다.

## 참고

- 백그라운드 상시 자동화(크론탭 방식)가 필요하면 `scripts/morning_research.sh` +
  `scripts/README.md`의 crontab 설정을 그대로 사용하면 됩니다. 두 방식은 독립적이며
  같은 쉘 스크립트를 공유합니다.
