# CLAUDE.md - Lectuer Factory Project

Lecture Factory agent team의 운영 규칙과 워크플로우 정의. 워크플로우 시스템 규칙은 `.claude/CLAUDE.md` 참조.

## Language Rule (MANDATORY)

**모든 최종 출력은 반드시 한국어(Korean)로 작성한다.**

- 사용자에게 보이는 모든 응답, 설명, 질문, 요약은 한국어로 출력
- 코드 주석, 커밋 메시지, PR 설명도 한국어 우선
- 코드 자체(변수명, 함수명 등)와 기술 용어(API, SDK 등)는 영문 허용
- 사용자가 영어로 질문해도 응답은 한국어로

## Project Structure

```
lectuer_factory/
├── CLAUDE.md                              # 이 파일 (프로젝트 규칙)
├── .claude/
│   ├── settings.json                      # 프로젝트 설정
│   ├── settings.local.json                # 로컬 설정
│   ├── skills/                            # Skill (워크플로우 진입점)
│   │   └── <skill-name>/SKILL.md
│   └── agents/                            # Agent (실제 작업자)
│       └── <agent-name>/AGENT.md
```

## Workflow Architecture

- **Skill**: 사용자가 `/command`로 실행하는 진입점
- **Agent**: Skill에서 `context: fork`로 위임받아 실제 작업을 수행
- Skill은 반드시 `context: fork` + `agent: <name>`으로 Agent에 위임
- Subagent 중첩 금지 (Subagent → Subagent 불가)

## Essential Rules

> 사소한 작업에는 판단에 따라 유연하게 적용.

### 1. Think Before Coding

**가정하지 말 것. 혼란을 숨기지 말 것. 트레이드오프를 드러낼 것.**

구현 전 반드시:
- 가정을 명시적으로 진술. 불확실하면 질문
- 여러 해석이 가능하면 제시 — 조용히 하나만 선택하지 말 것
- 더 단순한 방법이 있으면 말할 것. 필요하면 반론 제시
- 불명확하면 중단. 무엇이 혼란스러운지 명명하고 질문

**Context Analysis**: 폴더 경로 제공 시 반드시: 1) 파일 구조 분석 → 2) 핵심 파일 읽기 → 3) 컨텍스트 이해 후 진행.

### 2. Simplicity First

**문제를 해결하는 최소한의 코드. 추측적 구현 금지.**

- 요청된 것 이상의 기능 금지
- 단일 사용 코드에 추상화 금지
- 요청되지 않은 "유연성"이나 "설정 가능성" 금지
- 불가능한 시나리오에 대한 에러 핸들링 금지
- 200줄로 작성했는데 50줄로 가능하면 다시 작성

자문: "시니어 엔지니어가 이것이 과하다고 할까?" 그렇다면 단순화.

### 3. Surgical Changes

**필요한 것만 수정. 자기가 만든 문제만 정리.**

기존 코드 편집 시:
- 인접 코드, 주석, 포매팅을 "개선"하지 말 것
- 깨지지 않은 것을 리팩토링하지 말 것
- 다르게 하고 싶어도 기존 스타일을 따를 것
- 관련 없는 데드 코드를 발견하면 언급만 — 삭제하지 말 것

자신의 변경으로 인한 orphan 처리:
- 자신의 변경으로 사용되지 않게 된 import/변수/함수는 제거
- 기존에 있던 데드 코드는 요청 시에만 제거

검증: 변경된 모든 줄이 사용자 요청에 직접 연결되는가?

### 4. Goal-Driven Execution

**성공 기준을 정의하고 검증될 때까지 반복.**

작업을 검증 가능한 목표로 전환:
- "검증 추가" → "잘못된 입력에 대한 테스트 작성 후 통과시키기"
- "버그 수정" → "재현 테스트 작성 후 통과시키기"
- "리팩토링" → "리팩토링 전후 테스트 통과 확인"

멀티스텝 작업은 단계별 검증 계획 수립:
```
1. [단계] → 검증: [확인 방법]
2. [단계] → 검증: [확인 방법]
```

**Todo Protocol**: 즉시 생성 → `in_progress` 표시 → 완료 즉시 `completed` (batch 금지).

### STOP & Replan

스코프 변경, 패턴 충돌, 2+ 연속 실패, 설계 문제 발견 시 중단 → 대안 제안 → 확인 대기.

#### 3회 연속 실패 프로토콜 (Failure Recovery Protocol)

**발동 조건**: 동일 작업 3회 연속 실패

**금지 행위**: 4회 이상 시도, 무작위 변경(shotgun debugging), 테스트 삭제로 "통과" 처리

1. **STOP** - 모든 작업 즉시 중단
2. **REVERT** - 마지막 안정 상태로 복원 (`git checkout` 또는 수동 롤백)
3. **DOCUMENT** - 시도한 방법과 실패 원인을 `lessons.md`에 기록
4. **CONSULT** - Oracle 에이전트에 컨텍스트 제공 후 분석 요청
5. **ASK USER** - Oracle 해결 실패 시 사용자 승인 후 재시작
   - 시도한 접근법 3가지
   - 각 실패의 구체적 에러 메시지
   - 예상 원인과 실제 원인의 차이
   - 시도하지 않은 대안들

## Python Environment Rule (MANDATORY)

**파이썬 가상환경과 패키지 관리는 반드시 `uv`를 사용한다.**

- `.venv` 디렉토리가 이미 존재하면 해당 환경을 그대로 사용
- `.venv`가 없으면 `uv venv`로 새로 생성
- 패키지 설치/제거/동기화 등 모든 패키지 관리 작업은 `uv` 명령 사용 (`pip` 사용 금지)

```bash
# 가상환경 생성 (.venv가 없을 때)
uv venv

# 패키지 설치
uv pip install <package>

# requirements.txt로 설치
uv pip install -r requirements.txt

# 패키지 제거
uv pip uninstall <package>
```

## Skill Install Rule (MANDATORY)

**외부 스킬 설치 시 반드시 `--copy` 옵션을 사용한다. 심볼릭 링크 금지.**

`npx skills add` 명령은 기본적으로 `.agents/skills/`에 원본을 두고 `.claude/skills/`에 심볼릭 링크를 생성한다.
이 프로젝트에서는 **`--copy` 옵션**으로 `.claude/skills/` 하위에 실제 파일을 직접 복사하여 설치한다.

```bash
# 올바른 설치 (--copy 필수)
npx skills add <source> --copy -y

# 금지: 심볼릭 링크 설치 (--copy 없음)
npx skills add <source> -y
```

### skills-lock.json 관리

`npx skills add`는 프로젝트 루트에 `skills-lock.json`을 자동 생성한다. 이 파일은 설치된 외부 스킬의 소스·해시 메타데이터를 기록하며, 프로젝트에서는 `.claude/skills-lock.json`에서 관리한다.

- 스킬 설치 후 루트에 `skills-lock.json`이 생성되면 `.claude/skills-lock.json`에 **병합**(신규 항목 추가, 기존 항목 해시 갱신)한 뒤 루트 파일을 삭제
- `.claude/skills-lock.json`이 없으면 루트 파일을 그대로 `.claude/`로 이동

```bash
# 스킬 설치 후 lock 파일 병합 절차
npx skills add <source> --copy -y

# 루트에 skills-lock.json 생성 확인 → .claude/로 병합 후 삭제
# (기존 .claude/skills-lock.json이 있으면 항목 병합, 없으면 이동)
mv skills-lock.json .claude/skills-lock.json   # 또는 수동 병합 후 삭제
```

### 설치 후 정리

`npx skills add --copy`는 `.agent/`, `.agents/`, `.continue/`, `.kiro/`, `.windsurf/` 등 외부 에이전트 폴더도 자동 생성한다. 이 폴더들은 `.gitignore`에 등록되어 있으므로 커밋되지 않지만, 불필요 시 삭제해도 무방하다.

### 금지 패턴

- `--copy` 없이 스킬 설치 (심볼릭 링크 생성됨)
- `.claude/skills/` 외부 경로에 스킬을 수동 배치
- 심볼릭 링크로 스킬 연결

## Git Branching Rule (MANDATORY)

`.claude/` 파일 수정 시 필수 적용.

**Scope**: `.claude/agents/`, `.claude/scripts/`, `.claude/skills/`, `.claude/commands/`

### 실행 순서 (반드시 이 순서대로)

1. **브랜치 생성** — 파일 수정 **전에** 반드시 `feat/<설명>` 브랜치를 먼저 생성
2. **파일 수정** — 브랜치 안에서 edit/write 도구로 파일 수정
3. **커밋** — 변경사항을 커밋
4. **머지** — main으로 전환 후 `--no-ff` 머지
5. **푸시 & 정리** — 원격 푸시 후 feat 브랜치 삭제

```bash
# 1. 브랜치 생성 (파일 수정 전에 반드시 먼저 실행)
git checkout -b feat/update-writer-agent

# 2. 파일 수정 (edit/write 도구 사용) & 커밋
git add <수정된 파일> && git commit -m "설명"

# 3. main 머지 & 푸시 & 브랜치 삭제
git checkout main && git merge --no-ff feat/update-writer-agent
git push && git branch -d feat/update-writer-agent
```

### 금지 패턴

- main 브랜치에서 직접 파일 수정 후 브랜치 생성 (순서 위반)
- Scope 경로의 파일을 브랜치 없이 main에서 직접 커밋

> 별도 지시 없어도 AI 에이전트는 위 경로 수정 시 자동으로 이 워크플로를 수행합니다.
