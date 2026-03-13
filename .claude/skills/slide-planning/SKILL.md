---
name: slide-planning
description: 슬라이드 기획 - 5단계 파이프라인 (입력수집 → 브레인스토밍 → 구조설계 → 기획안작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, AskUserQuestion
---

# 슬라이드 기획 워크플로우

## 작업 지시

$ARGUMENTS

## 오케스트레이터 실행 로직

**당신은 5단계 파이프라인의 오케스트레이터다.** 직접 콘텐츠를 작성하지 않는다. 각 Phase를 Agent 도구로 전담 에이전트에 위임하고, Phase 간 데이터 흐름을 관리한다.

### Step 0: 초기화

1. `today` = 오늘 날짜 (YYYY-MM-DD 형식)
2. `project_root` = 현재 작업 디렉토리
3. `output_dir` = Phase 1 완료 후 결정

### Phase 1~5 공통 실행 규칙

각 Phase 실행 시 반드시:
1. Agent 도구로 해당 에이전트 호출 (아래 Phase별 템플릿 사용)
2. 에이전트 반환 후 **필수 산출물 존재 확인** (Glob 또는 Read)
3. 산출물 확인 성공 → 다음 Phase 진행
4. 산출물 확인 실패 → 사용자에게 보고 후 **중단**

---

## 파이프라인 (5단계)

### Phase 1: 입력 수집

**Agent 호출**:
- **subagent_type**: `input-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 입력을 수집하세요.

**지시사항**: `.claude/agents/input-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-input.md`를 로드하여 따르세요.

**핵심 원칙**:
- Step 0: lectures/ 스캔 → 교안 폴더 선택 → 3개 파일 로드 → session 매니페스트 생성
- Step 1: P1~P5 전체 자동 결정 (질문 없음)
  - P1: content_type + lab_environment 분석 → 슬라이드 도구 (marp/slidev)
  - P2: tone/tone_examples 분석 → 디자인 톤 (friendly_visual/professional)
  - P3: 기본값 "전체" (Day 목록 파싱)
  - P4: standard (25-55줄/장) 고정
  - P5: GRR 기반 1차 슬라이드 수 동적 산출
- Step 2: 전체 설정 요약 + AskUserQuestion **반드시 1회** (확인/변경)
  - P1~P5 전체를 요약 + session 매니페스트 출력 후 "이 설정으로 진행할까요?" 확인
  - "변경 필요" 선택 시 해당 항목만 갱신 (예: "P1: slidev", "P3: Day 1만")
- Step 3: input_data.json 생성

**폴더 생성**: 선택된 강의 루트 폴더 아래 `03_slide_plan/` 생성
**산출물**: `03_slide_plan/input_data.json` — 스키마: `.claude/templates/input-schema-slide-planning.json`

**사용자 인자**: {$ARGUMENTS 내용이 있으면 여기에 포함}
```

**완료 확인**:
1. Glob `lectures/*_*/03_slide_plan/input_data.json`으로 생성된 파일 경로 찾기 → `output_dir` 확정
2. Read로 `input_data.json` 로드 → `slide_config` 객체 존재 확인
3. `slide_config.slide_tool`이 유효한 enum 값인지 검증
4. `session_manifest` 배열이 1개 이상 항목 포함 확인

---

### Phase 2: 브레인스토밍 → brainstorm-agent (시각화 아이디어, 레이아웃 구상)

<!-- TODO: Phase 2 오케스트레이터 로직 구현 예정 -->

### Phase 3: 슬라이드 구조 설계 → architecture-agent (슬라이드 수, 유형, 순서, 시간 배분)

<!-- TODO: Phase 3 오케스트레이터 로직 구현 예정 -->

### Phase 4: 기획안 작성 → writer-agent (슬라이드별 목적, 레이아웃, 핵심 콘텐츠)

<!-- TODO: Phase 4 오케스트레이터 로직 구현 예정 -->

### Phase 5: 품질 검토 → review-agent (정보 밀도, 시각 계층, 학습목표 정렬)

<!-- TODO: Phase 5 오케스트레이터 로직 구현 예정 -->

## 산출물 (03_slide_plan/)

```
lectures/YYYY-MM-DD_{강의명}/03_slide_plan/
├── input_data.json              # Phase 1: 교안 로드 + 도구/형식 선택
├── brainstorm_result.md         # Phase 2: 브레인스토밍
├── architecture.md              # Phase 3: 슬라이드 구조 설계
├── slide_plan.md                # Phase 4: 최종 기획안 ★
└── quality_review.md            # Phase 5: 품질 검토
```
