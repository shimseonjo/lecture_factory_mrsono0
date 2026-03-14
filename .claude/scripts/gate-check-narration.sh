#!/bin/bash
# gate-check-narration.sh — narration 파일의 정량 검증
# 사용법: gate-check-narration.sh <narration_file>
# 반환: 0=PASS, 1=FAIL (FAIL 시 원인을 stdout 출력)

set -euo pipefail

NARRATION_FILE="${1:?사용법: gate-check-narration.sh <narration_file>}"

FAIL=0
REASONS=""

add_fail() {
  FAIL=1
  REASONS="${REASONS}FAIL: $1\n"
}

# ── 1. "___" 빈칸 검출 ──
BLANK_COUNT=$(grep -c '___' "$NARRATION_FILE" 2>/dev/null || true)
if [ "$BLANK_COUNT" -gt 0 ]; then
  add_fail "빈칸(___) ${BLANK_COUNT}개 발견 — 모든 placeholder를 실제 내용으로 교체 필요"
fi

# ── 2. 줄 수 하한 ──
LINE_COUNT=$(wc -l < "$NARRATION_FILE" | tr -d ' ')
if [ "$LINE_COUNT" -lt 80 ]; then
  add_fail "줄 수 부족: ${LINE_COUNT}줄 (최소 80줄)"
fi

# ── 3. 발화문(> ") 존재 확인 ──
SPEECH_COUNT=$(grep -c '^> "' "$NARRATION_FILE" 2>/dev/null || true)
if [ "$SPEECH_COUNT" -lt 5 ]; then
  add_fail "발화문(> \") 부족: ${SPEECH_COUNT}개 (최소 5개)"
fi

# ── 4. 범용 템플릿 문구 검출 ──
GENERIC_PATTERNS=(
  "강사가 핵심 개념을 설명하고 코드를 시연하는 구간"
  "학습자가 독립적으로 실습하는 구간"
  "선수지식 확인 발문"
  "학습목표 안내"
  "핵심 3가지 요약"
)

for pattern in "${GENERIC_PATTERNS[@]}"; do
  count=$(grep -c "$pattern" "$NARRATION_FILE" 2>/dev/null || true)
  if [ "$count" -gt 0 ]; then
    add_fail "범용 템플릿 문구 발견: \"$pattern\""
  fi
done

# ── 5. 발문(❓) 존재 확인 ──
QUESTION_COUNT=$(grep -c '❓' "$NARRATION_FILE" 2>/dev/null || true)
if [ "$QUESTION_COUNT" -lt 2 ]; then
  add_fail "발문(❓) 부족: ${QUESTION_COUNT}개 (최소 2개)"
fi

# ── 결과 출력 ──
if [ "$FAIL" -eq 0 ]; then
  echo "PASS: ${NARRATION_FILE} (${LINE_COUNT}줄, 발화문=${SPEECH_COUNT}, 발문=${QUESTION_COUNT})"
  exit 0
else
  echo "=== GATE-8 FAIL: ${NARRATION_FILE} ==="
  echo -e "$REASONS"
  exit 1
fi
