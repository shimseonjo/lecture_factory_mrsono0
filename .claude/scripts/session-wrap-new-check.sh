#!/bin/bash
# SessionStart hook: 새 세션 시작 시 커밋되지 않은 변경사항이 있으면
# additionalContext로 에이전트에 전달 → /session-wrap 자동 실행 유도

INPUT=$(cat)

# git 변경사항 체크
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
CHANGES=$(cd "$CWD" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt "0" ]; then
  jq -n \
    --arg ctx "⚠️ 이전 세션에서 커밋되지 않은 변경사항이 ${CHANGES}개 파일에 있습니다. /session-wrap을 실행하여 세션을 정리하세요." \
    '{
      "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": $ctx
      }
    }'
fi
