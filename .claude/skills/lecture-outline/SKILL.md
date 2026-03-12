---
name: lecture-outline
description: 강의구성안 생성 - 7단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 아키텍처 → 작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion, TodoWrite
---

# 강의구성안 생성 워크플로우

## 작업 지시

$ARGUMENTS

## 오케스트레이터 실행 로직

**당신은 7단계 파이프라인의 오케스트레이터다.** 직접 콘텐츠를 작성하지 않는다. 각 Phase를 Agent 도구로 전담 에이전트에 위임하고, Phase 간 데이터 흐름을 관리한다.

### Step 0: 초기화

1. `today` = 오늘 날짜 (YYYY-MM-DD 형식)
2. `project_root` = 현재 작업 디렉토리
3. `output_dir` = Phase 1 완료 후 결정
4. TodoWrite로 Phase 1~7을 pending 등록

### Phase 1~7 공통 실행 규칙

각 Phase 실행 시 반드시:
1. TodoWrite로 현재 Phase를 `in_progress` 표시
2. Agent 도구로 해당 에이전트 호출 (아래 Phase별 템플릿 사용)
3. 에이전트 반환 후 **필수 산출물 존재 확인** (Glob 또는 Read)
4. 산출물 확인 성공 → TodoWrite로 `completed`, 다음 Phase 진행
5. 산출물 확인 실패 → 사용자에게 보고 후 **중단**

---

### Phase 1: 입력 수집

**Agent 호출**:
- **subagent_type**: `input-agent`
- **prompt**:

```
강의구성안 워크플로우의 입력을 수집하세요.

**지시사항**: `.claude/agents/input-agent/AGENT.md`를 읽고 "강의구성안 입력 수집 (Q1~Q14)" 섹션을 따르세요.

**폴더 생성**: Q1 응답을 받은 즉시 다음 폴더를 생성하세요:
- `lectures/{today}_{강의명}/01_outline/`
- 강의명: Q1 핵심 주제에서 추출, 공백은 하이픈(`-`)으로 대체

**산출물**: 위 폴더에 `input_data.json` 저장

**사용자 인자**: {$ARGUMENTS 내용이 있으면 여기에 포함}
```

**완료 확인**: Glob `lectures/{today}_*/01_outline/input_data.json`으로 생성된 파일 경로를 찾아 `output_dir`을 확정한다. (예: `lectures/2026-03-10_claude-code-활용/01_outline/`)

---

### Phase 2: 탐색적 리서치

**Agent 호출**:
- **subagent_type**: `research-agent`
- **prompt**:

```
강의구성안을 위한 탐색적 리서치를 수행하세요.

**지시사항**: `.claude/agents/research-agent/AGENT.md`를 읽고 "강의구성안 탐색적 리서치 (Phase 2) 세부 워크플로우" 섹션을 따르세요.

**입력**: `{output_dir}/input_data.json`
**산출물 위치**: `{output_dir}/`
**모드**: 탐색적 (orientation) — 고착 효과 방지 필터 적용
**제약**: 웹 검색 15회, NBLM 쿼리 노트북당 5회 이내
```

**완료 확인**: `{output_dir}/research_exploration.md` 존재 확인

---

### Phase 3: 브레인스토밍

**Agent 호출**:
- **subagent_type**: `brainstorm-agent`
- **prompt**:

```
탐색적 리서치 결과를 기반으로 강의 하위 주제를 발산적으로 도출하고, 다관점 검증을 거쳐 우선순위를 분류하세요.

**지시사항**: `.claude/agents/brainstorm-agent/AGENT.md`를 읽고 "강의구성안 브레인스토밍 (Phase 3) 세부 워크플로우" 섹션을 따르세요.

**입력**: `{output_dir}/input_data.json`, `{output_dir}/research_exploration.md`
**산출물 위치**: `{output_dir}/`
**제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**완료 확인**: `{output_dir}/brainstorm_result.md` 존재 확인

---

### Phase 4: 심화 리서치

**Agent 호출**:
- **subagent_type**: `research-agent`
- **prompt**:

```
브레인스토밍 결과의 심화 리서치 요청 사항(§7)을 검증하고 자료를 보충하세요.

**지시사항**: `.claude/agents/research-agent/AGENT.md`를 읽고 "강의구성안 심화 리서치 (Phase 4) 세부 워크플로우" 섹션을 따르세요. deep-research 스킬의 8단계 파이프라인을 따릅니다.

**입력**: `{output_dir}/brainstorm_result.md`, `{output_dir}/input_data.json`
**참조 지침**: `.claude/skills/deep-research/SKILL.md`
**산출물 위치**: `{output_dir}/`
**모드**: 심화 (deep) — 고착 효과 필터 미적용
**제약**: 웹 검색 25회, NBLM 쿼리 5회, 삼각검증 추가 5회 이내
```

**완료 확인**: `{output_dir}/research_deep.md` 존재 확인

---

### Phase 5: 아키텍처 설계

**Agent 호출**:
- **subagent_type**: `architecture-agent`
- **prompt**:

```
Backward Design 3단계를 역순 적용하여 강의 아키텍처를 설계하세요.

**지시사항**: `.claude/agents/architecture-agent/AGENT.md`를 읽고 "강의구성안 아키텍처 설계 (Phase 5) 세부 워크플로우" 섹션을 따르세요.

**입력**: `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**산출물**: `{output_dir}/architecture.md`
**제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**완료 확인**: `{output_dir}/architecture.md` 존재 확인

---

### Phase 6: 구성안 작성

**분할 판단** (오케스트레이터 수행):

1. `{output_dir}/architecture.md`를 Read하여 §1 시간 예산에서 총 일수(`days`)를 파악한다
2. 분할 기준:
   - 총 일수 ≤ 2: 분할 없음 → 아래 **단일 호출** 사용
   - 총 일수 > 2 (3일 이상): 3-Part 분할 → 아래 **Part 1/2/3 순차 호출** 사용

#### 단일 호출 (총 일수 ≤ 2)

**Agent 호출**:
- **subagent_type**: `writer-agent`
- **prompt**:

```
이전 Phase 산출물을 통합하여 최종 강의구성안을 작성하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 "강의구성안 작성 (Phase 6) 세부 워크플로우" 섹션을 따르세요.

**입력**: `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**템플릿**: `.claude/templates/outline-template.md`
**산출물**: `{output_dir}/lecture_outline.md`
**제약**: 도구 Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
**금지**: architecture.md의 차시 배치 변경 금지. 새 학습 목표/하위 주제 추가 금지. 입력에 없는 팩트 창작 금지.
```

**완료 확인**: `{output_dir}/lecture_outline.md` 존재 확인

#### 3-Part 분할 호출 (총 일수 > 2)

`days` 값에서 `mid = ceil(days / 2)`를 계산한다.

**Part 1 호출** — §1~§4 작성:
- **subagent_type**: `writer-agent`
- **prompt**:

```
이전 Phase 산출물을 기반으로 lecture_outline.md의 **§1~§4만** 작성하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 "강의구성안 작성 (Phase 6) 세부 워크플로우" 섹션을 따르되, **Step 0 + Step 1 + Step 2만 실행**하세요.

**입력**: `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**템플릿**: `.claude/templates/outline-template.md`
**산출물**: `{output_dir}/lecture_outline.md` (§1~§4 + 메타데이터)
**모드**: part (1/3)
**금지**: architecture.md의 차시 배치 변경 금지. 새 학습 목표/하위 주제 추가 금지. 입력에 없는 팩트 창작 금지.
```

- **완료 확인**: `{output_dir}/lecture_outline.md` 존재 + §4 핵심 질문 섹션 포함 확인

**Part 2 호출** — §5 전반부 append:
- **subagent_type**: `writer-agent`
- **prompt**:

```
lecture_outline.md에 **§5 전반부**(§5-1 일별 테마 + §5-2 공통 가이드 + §5-3 Day 1~Day {mid})를 이어서 작성하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 "강의구성안 작성 (Phase 6) 세부 워크플로우" 섹션을 따르되, **Step 3의 §5-1, §5-2, §5-3 중 Day 1~Day {mid}만 실행**하세요.

**입력**: `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**기존 산출물**: `{output_dir}/lecture_outline.md` (Part 1 결과 — Read 후 끝에 이어쓰기)
**모드**: part (2/3)
**범위**: Day 1 ~ Day {mid}
**금지**: architecture.md의 차시 배치 변경 금지. 새 학습 목표/하위 주제 추가 금지. 입력에 없는 팩트 창작 금지.
```

- **완료 확인**: `{output_dir}/lecture_outline.md`에 §5-1, §5-2, Day {mid} 차시 상세 존재 확인

**Part 3 호출** — §5 후반부 + §6~§9 append:
- **subagent_type**: `writer-agent`
- **prompt**:

```
lecture_outline.md에 **§5 후반부**(§5-3 Day {mid+1}~Day {days})와 **§6~§9**를 이어서 작성하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 "강의구성안 작성 (Phase 6) 세부 워크플로우" 섹션을 따르되, **Step 3의 §5-3 중 Day {mid+1}~Day {days} + Step 4 + Step 5를 실행**하세요.

**입력**: `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**기존 산출물**: `{output_dir}/lecture_outline.md` (Part 1+2 결과 — Read 후 끝에 이어쓰기)
**모드**: part (3/3)
**범위**: Day {mid+1} ~ Day {days} + §6~§9
**금지**: architecture.md의 차시 배치 변경 금지. 새 학습 목표/하위 주제 추가 금지. 입력에 없는 팩트 창작 금지.
```

- **완료 확인**: `{output_dir}/lecture_outline.md`에 §9 강사 가이드 섹션 존재 확인

**최종 검증**: Grep으로 `lecture_outline.md`에 §1~§9 전체 섹션 헤더 존재 여부를 확인한다

---

### Phase 7: 품질 검토

**Agent 호출**:
- **subagent_type**: `review-agent`
- **prompt**:

```
최종 구성안의 품질을 QM Rubric 기반 체크리스트(38개 항목)로 검증하고 판정하세요.

**지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고 "강의구성안 품질 검토 (Phase 7) 세부 워크플로우" 섹션을 따르세요.

**입력**: `{output_dir}/lecture_outline.md`, `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`
**산출물**: `{output_dir}/quality_review.md` (중간: `_review_step1~4.md`)
**제약**: 도구 Read, Write만 사용. Agent 중첩 금지.
```

**완료 확인**: `{output_dir}/quality_review.md` 존재 확인

---

### Phase 7 후속 처리

`quality_review.md`를 Read하여 **§7 최종 판정** 섹션에서 판정 결과를 추출한다.

#### PASS인 경우

Phase 7 종료. 사용자에게 검토 요약을 보고한다:
- 판정: PASS
- Pass/Fail 통계 (Major/Minor 위반 수)
- 우수 사항 (§5에서 추출)
- 최종 산출물 경로: `{output_dir}/lecture_outline.md`

#### CONDITIONAL PASS인 경우

1. `quality_review.md` §4(Minor 위반)와 §6(수정 우선순위)를 사용자에게 제시
2. AskUserQuestion으로 확인:
   - 선택지 1: "Minor 위반을 수정합니다"
   - 선택지 2: "현재 상태로 확정합니다"
3. 수정 선택 시 → writer-agent 재호출:
   - **subagent_type**: `writer-agent`
   - **prompt**: `quality_review.md`의 Minor 위반 목록 + 수정 권고를 포함하여 `{output_dir}/lecture_outline.md` 부분 수정 지시. `.claude/agents/writer-agent/AGENT.md`를 읽고 지시를 따르되, 수정 범위는 위반 항목에 한정.
4. 수정 완료 후 → review-agent 재호출 (Phase 7 재실행, **최대 1회**)
5. 재검토 결과를 사용자에게 보고 (재검토 후에는 판정과 무관하게 종료)

#### REVISION REQUIRED인 경우

1. `quality_review.md` §3(Major 위반)와 §6(수정 우선순위)를 사용자에게 제시
2. AskUserQuestion으로 확인:
   - 선택지 1: "Major 위반을 수정합니다"
   - 선택지 2: "현재 상태로 보존합니다"
3. 수정 선택 시 → writer-agent 재호출:
   - **subagent_type**: `writer-agent`
   - **prompt**: `quality_review.md`의 Major 위반 수정 가이드를 포함하여 `{output_dir}/lecture_outline.md` 해당 섹션 재작성 지시. `.claude/agents/writer-agent/AGENT.md`를 읽고 지시를 따르되, 수정 범위는 위반 항목에 한정.
4. 재작성 완료 후 → review-agent 재호출 (Phase 7 재실행, **최대 1회**)
5. 재검토 결과를 사용자에게 보고 (재검토 후에는 판정과 무관하게 종료)

---

## Phase별 상세 사양 참조

> 아래는 각 Phase의 상세 사양이다. 에이전트의 AGENT.md에 세부 워크플로우가 정의되어 있으므로, 오케스트레이터는 위 실행 로직을 따르고 아래는 맥락 참조용으로 활용한다.

### Phase 1: 입력 수집 → input-agent

**상세**: `.claude/agents/input-agent/AGENT.md`의 "강의구성안 입력 수집 (Q1~Q14)" 섹션 참조

### Phase 2: 탐색적 리서치 → research-agent

**상세**: `.claude/agents/research-agent/AGENT.md`의 "강의구성안 탐색적 리서치 (Phase 2) 세부 워크플로우" 섹션 참조

### Phase 3: 브레인스토밍 → brainstorm-agent

**상세**: `.claude/agents/brainstorm-agent/AGENT.md`의 "강의구성안 브레인스토밍 (Phase 3) 세부 워크플로우" 섹션 참조

### Phase 4: 심화 리서치 → research-agent

**상세**: `.claude/agents/research-agent/AGENT.md`의 "강의구성안 심화 리서치 (Phase 4) 세부 워크플로우" 섹션 참조

### Phase 5: 아키텍처 설계 → architecture-agent

**상세**: `.claude/agents/architecture-agent/AGENT.md`의 "강의구성안 아키텍처 설계 (Phase 5) 세부 워크플로우" 섹션 참조

### Phase 6: 구성안 작성 → writer-agent

**상세**: `.claude/agents/writer-agent/AGENT.md`의 "강의구성안 작성 (Phase 6) 세부 워크플로우" 섹션 참조

### Phase 7: 품질 검토 → review-agent

**상세**: `.claude/agents/review-agent/AGENT.md`의 "강의구성안 품질 검토 (Phase 7) 세부 워크플로우" 섹션 참조

## 산출물 (01_outline/)

### 명명 규칙

| 유형 | 패턴 | 예시 |
|------|------|------|
| 워크플로우 폴더 | `{단계번호}_{단계이름}/` | `01_outline/` |
| 최종 산출물 | `{워크플로우}_{유형}.md` | `lecture_outline.md` |
| 중간 산출물 | `{Phase역할}_{내용}.md` | `research_exploration.md`, `brainstorm_result.md` |
| 검토 중간 | `_review_step{N}.md` | `_review_step1.md` ~ `_review_step4.md` |
| 입력 데이터 | `input_data.json` | (고정 이름) |

### 파일 목록

```
lectures/YYYY-MM-DD_{강의명}/01_outline/
├── input_data.json              # Phase 1: 사용자 입력 (Q1~Q14)
├── research_plan.md             # Phase 2: 리서치 계획
├── local_findings.md            # Phase 2: 로컬 참고자료 분석
├── nblm_findings.md             # Phase 2: NotebookLM 쿼리 결과
├── web_findings.md              # Phase 2: 인터넷 리서치 결과
├── research_exploration.md      # Phase 2: 4자료원 통합 최종 ★
├── brainstorm_plan.md           # Phase 3: 브레인스토밍 계획
├── divergent_ideas.md           # Phase 3: 발산 아이디어 원시 목록
├── idea_clusters.md             # Phase 3: 클러스터링 + 페르소나
├── review_result.md             # Phase 3: 다관점 검증 + Decision Log
├── brainstorm_result.md         # Phase 3: 브레인스토밍 최종 ★
├── deep_research_plan.md        # Phase 4: 심화 리서치 계획 (입력 변환)
├── verification_results.md      # Phase 4: 검증 유형 수집 결과
├── supplement_results.md        # Phase 4: 보충 유형 수집 결과
├── research_deep.md             # Phase 4: 심화 리서치 최종 ★
├── architecture.md              # Phase 5: 아키텍처 설계
├── lecture_outline.md           # Phase 6: 최종 구성안 ★
├── _review_step1.md             # Phase 7: 구조 완전성 검증 (중간)
├── _review_step2.md             # Phase 7: 교수설계 정렬 검증 (중간)
├── _review_step3.md             # Phase 7: 시간 배분 검증 (중간)
├── _review_step4.md             # Phase 7: 콘텐츠 정확성 검증 (중간)
└── quality_review.md            # Phase 7: 품질 검토 ★
```
