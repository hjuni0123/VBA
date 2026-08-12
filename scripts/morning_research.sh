#!/usr/bin/env bash
#
# morning_research.sh
# 금융권 리서치센터 인턴용 "아침 루틴" 자동화 스크립트
#
# - USD/KRW 환율 (er-api.com, 무료, 키 불필요)
# - 금(Gold) 현물가 (goldprice.org 무료 JSON 시세, 키 불필요)
# - 결과를 바탕화면의 마스터시트_원자재.csv 에 누적(append) 저장
#
# 필요 도구: curl, jq (macOS: brew install jq)

set -euo pipefail

# ---------------------------------------------------------------------------
# 설정
# ---------------------------------------------------------------------------
DESKTOP_DIR="$HOME/Desktop"
OUTPUT_CSV="$DESKTOP_DIR/마스터시트_원자재.csv"

# IP 차단 방지를 위해 일반 브라우저처럼 보이는 User-Agent 사용
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

CURL_OPTS=(-s -A "$USER_AGENT" --max-time 10)

# ---------------------------------------------------------------------------
# 1) 수집 날짜
# ---------------------------------------------------------------------------
TODAY="$(date '+%Y-%m-%d %H:%M:%S')"

# ---------------------------------------------------------------------------
# 2) USD/KRW 환율 (er-api.com)
#    https://open.er-api.com/v6/latest/USD -> .rates.KRW
# ---------------------------------------------------------------------------
FX_JSON="$(curl "${CURL_OPTS[@]}" "https://open.er-api.com/v6/latest/USD")"
USD_KRW="$(echo "$FX_JSON" | jq -r '.rates.KRW // empty')"

if [[ -z "$USD_KRW" ]]; then
  echo "[ERROR] USD/KRW 환율 수집 실패" >&2
  USD_KRW="N/A"
fi

# ---------------------------------------------------------------------------
# 3) 금(Gold, XAU/USD) 현물 가격 (goldprice.org 무료 JSON 시세)
#    https://data-asg.goldprice.org/dbXRates/USD -> .items[0].xauPrice
#    Referer 헤더가 없으면 403 Forbidden을 반환하므로 반드시 함께 보낸다.
# ---------------------------------------------------------------------------
GOLD_JSON="$(curl "${CURL_OPTS[@]}" -H "Referer: https://goldprice.org/" "https://data-asg.goldprice.org/dbXRates/USD")"
GOLD_PRICE="$(echo "$GOLD_JSON" | jq -r '.items[0].xauPrice // empty')"

if [[ -z "${GOLD_PRICE:-}" ]]; then
  echo "[ERROR] 금 가격 수집 실패" >&2
  GOLD_PRICE="N/A"
fi

# ---------------------------------------------------------------------------
# 4) CSV 누적 저장 (헤더는 파일이 없을 때만 최초 1회 생성)
# ---------------------------------------------------------------------------
mkdir -p "$DESKTOP_DIR"

if [[ ! -f "$OUTPUT_CSV" ]]; then
  echo "수집일시,USD/KRW,Gold(XAUUSD)" >> "$OUTPUT_CSV"
fi

echo "${TODAY},${USD_KRW},${GOLD_PRICE}" >> "$OUTPUT_CSV"

echo "[OK] $TODAY  USD/KRW=$USD_KRW  Gold=$GOLD_PRICE  -> $OUTPUT_CSV"
