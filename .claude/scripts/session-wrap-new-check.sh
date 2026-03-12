#!/bin/bash
# UserPromptSubmit hook: /new 입력 시 커밋되지 않은 변경사항이 있으면 block
# /session-wrap 실행을 먼저 유도

INPUT=$(cat)

PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# /new 명령이 아니면 통과
if [ "$PROMPT" != "/new" ]; then
  exit 0
fi

# git 변경사항 체크
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
CHANGES=$(cd "$CWD" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

if [ "$CHANGES" -gt "0" ]; then
  echo "{\"decision\": \"block\", \"reason\": \"커밋되지 않은 변경사항이 ${CHANGES}개 파일에 있습니다. /new 전에 /session-wrap을 실행하여 세션을 정리하세요.\"}"
fi
