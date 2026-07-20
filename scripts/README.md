# morning_research.sh — 리서치센터 인턴 아침 루틴 자동화

증권사 리서치센터에서 매일 아침 확인하는 USD/KRW 환율과 금(Gold, XAUUSD) 가격을
비용 없이 자동 수집해 바탕화면의 `마스터시트_원자재.csv`에 누적 저장하는 셸 스크립트입니다.
Python이나 별도 프레임워크 없이 `curl`, `jq`, `awk`, `sed`만 사용합니다.

## 사용 데이터 소스 (모두 무료, API 키 불필요)

- 환율: [er-api.com](https://www.exchangerate-api.com/docs/free) — `https://open.er-api.com/v6/latest/USD`
- 금 가격: [stooq.com](https://stooq.com) 무료 CSV 시세 — `https://stooq.com/q/l/?s=xauusd&f=sd2t2ohlcv&h&e=csv`
  - WTI유로 바꾸고 싶으면 `s=xauusd`를 `s=cl.f`(WTI 선물)로 교체하면 됩니다.

두 요청 모두 IP 차단을 피하기 위해 일반 브라우저처럼 보이는 `User-Agent` 헤더를 붙여 보냅니다.

## 사전 준비 (macOS)

```bash
# jq가 없다면 설치 (Homebrew 필요)
brew install jq
```

## 실행 권한 부여

```bash
chmod +x ~/VBA/scripts/morning_research.sh
```

## 수동 실행 테스트

```bash
~/VBA/scripts/morning_research.sh
```

정상 실행되면 바탕화면에 `마스터시트_원자재.csv`가 생성되고(최초 1회만 헤더 추가),
아래처럼 한 줄씩 누적됩니다.

```
수집일시,USD/KRW,Gold(XAUUSD)
2026-07-20 08:30:01,1385.42,2402.30
2026-07-21 08:30:01,1381.10,2410.75
```

## 크론탭(Crontab) 등록 — 평일 오전 8시 30분 자동 실행

1. 크론탭 편집기 열기

```bash
crontab -e
```

2. 아래 줄 추가 (경로는 실제 스크립트 위치에 맞게 수정, `MAILTO=""`로 메일 알림 비활성화 권장)

```cron
MAILTO=""
30 8 * * 1-5 /bin/bash ~/VBA/scripts/morning_research.sh >> ~/VBA/scripts/morning_research.log 2>&1
```

- `30 8 * * 1-5` : 매주 월~금(1-5), 오전 8시 30분
- 로그는 `morning_research.log`에 남도록 설정해 실패 원인을 추적할 수 있게 했습니다.

3. 등록 확인

```bash
crontab -l
```

## macOS 참고사항

- macOS는 기본적으로 cron(`crond`)이 백그라운드에서 항상 동작하지만, 절전모드(sleep) 중에는 실행되지 않습니다.
  절전 중에도 반드시 실행되어야 한다면 `launchd`(`.plist`) 방식으로 전환하는 것을 권장합니다.
- 최초 1회는 터미널에서 `crontab -e` 저장 시 macOS가 "터미널이 전체 디스크 접근 권한을 요청" 하는 보안 팝업을 띄울 수 있습니다.
  `시스템 설정 > 개인정보 보호 및 보안 > 전체 디스크 접근 권한`에서 `cron`(또는 `/usr/sbin/cron`)을 허용해야
  바탕화면 파일 쓰기가 정상 동작합니다.
