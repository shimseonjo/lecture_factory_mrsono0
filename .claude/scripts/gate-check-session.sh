#!/bin/bash
# gate-check-session.sh — session 파일의 정량 검증
# 사용법: gate-check-session.sh <session_file> <content_type>
# content_type: hands-on / concept / activity
# 반환: 0=PASS, 1=FAIL (FAIL 시 원인을 stdout 출력)

set -euo pipefail

SESSION_FILE="${1:?사용법: gate-check-session.sh <session_file> <content_type>}"
CONTENT_TYPE="${2:?content_type 필요: hands-on / concept / activity}"

FAIL=0
REASONS=""

add_fail() {
  FAIL=1
  REASONS="${REASONS}FAIL: $1\n"
}

# ── 1. 금지 문구 검출 ──
FORBIDDEN_PATTERNS=(
  "구성안 비유 체계 참조"
  "선수 확인 질문"
  "강사 시연을 따라 코드 작성"
  "다음 차시 주제와의 연결점을 안내합니다"
  "해당 SLO 달성 여부 확인"
)

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  count=$(grep -c "$pattern" "$SESSION_FILE" 2>/dev/null || true)
  if [ "$count" -gt 0 ]; then
    add_fail "금지 문구 발견: \"$pattern\" (${count}회)"
  fi
done

# ── 2. 줄 수 하한 ──
LINE_COUNT=$(wc -l < "$SESSION_FILE" | tr -d ' ')

case "$CONTENT_TYPE" in
  hands-on)
    MIN_LINES=150
    ;;
  concept)
    MIN_LINES=120
    ;;
  activity)
    MIN_LINES=100
    ;;
  *)
    MIN_LINES=100
    ;;
esac

if [ "$LINE_COUNT" -lt "$MIN_LINES" ]; then
  add_fail "줄 수 부족: ${LINE_COUNT}줄 (최소 ${MIN_LINES}줄, content_type=${CONTENT_TYPE})"
fi

# ── 3. 코드 블록 카운트 (hands-on 차시) ──
CODE_FENCE_COUNT=$(grep -c '```' "$SESSION_FILE" 2>/dev/null || true)

if [ "$CONTENT_TYPE" = "hands-on" ]; then
  # 코드 블록 열기+닫기 = 쌍. 최소 3쌍(6개) 필요 (I Do + We Do + You Do)
  if [ "$CODE_FENCE_COUNT" -lt 6 ]; then
    add_fail "hands-on 코드 블록 부족: ${CODE_FENCE_COUNT}개 fence (최소 6개 = 3쌍)"
  fi
fi

# ── 4. ★ 핵심 예시 마커 카운트 ──
STAR_COUNT=$(grep -c '★' "$SESSION_FILE" 2>/dev/null || true)

if [ "$CONTENT_TYPE" = "hands-on" ] || [ "$CONTENT_TYPE" = "concept" ]; then
  if [ "$STAR_COUNT" -lt 2 ]; then
    add_fail "★ 핵심 예시 부족: ${STAR_COUNT}개 (최소 2개)"
  fi
fi

# ── 5. 동일 흔한 실수 패턴 검출 ──
GENERIC_MISTAKE=$(grep -c "어노테이션 누락" "$SESSION_FILE" 2>/dev/null || true)
if [ "$GENERIC_MISTAKE" -gt 0 ]; then
  # 추가 확인: "패키지 위치 오류"도 동시에 있으면 템플릿 복사로 판단
  GENERIC_MISTAKE2=$(grep -c "패키지 위치 오류" "$SESSION_FILE" 2>/dev/null || true)
  if [ "$GENERIC_MISTAKE2" -gt 0 ]; then
    add_fail "흔한 실수 시나리오가 범용 템플릿 (어노테이션 누락 + 패키지 위치 오류)"
  fi
fi

# ── 결과 출력 ──
if [ "$FAIL" -eq 0 ]; then
  echo "PASS: ${SESSION_FILE} (${LINE_COUNT}줄, 코드블록=${CODE_FENCE_COUNT}, ★=${STAR_COUNT})"
  exit 0
else
  echo "=== GATE-6 FAIL: ${SESSION_FILE} ==="
  echo -e "$REASONS"
  exit 1
fi
