#!/bin/bash
# Stop hook: 커밋되지 않은 변경사항이 있을 때 /session-wrap 실행을 유도
# 세션별 1회만 동작 (lock 파일로 중복 방지)

INPUT=$(cat)

# 무한 루프 방지: Stop hook에 의해 이미 재실행 중이면 종료
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# 세션별 lock 파일로 중복 실행 방지 (같은 세션에서 1회만 block)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
LOCK_FILE="/tmp/claude-session-wrap-${SESSION_ID}.lock"

if [ -f "$LOCK_FILE" ]; then
  exit 0
fi

# git 변경사항 체크
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
CHANGES=$(cd "$CWD" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt "0" ]; then
  touch "$LOCK_FILE"
  echo "{\"decision\": \"block\", \"reason\": \"커밋되지 않은 변경사항이 ${CHANGES}개 파일에 있습니다. /session-wrap을 실행하여 세션을 정리하세요.\"}"
fi
