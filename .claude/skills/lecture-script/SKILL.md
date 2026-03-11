---
name: lecture-script
description: 강의교안 생성 - 7단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 구조설계 → 작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion, TodoWrite
---

# 강의교안 생성 워크플로우

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
강의교안 워크플로우의 입력을 수집하세요.

**지시사항**: `.claude/agents/input-agent/AGENT.md`를 읽고 "강의교안 입력 수집 (S0~S6)" 섹션을 따르세요.

**핵심 원칙**:
- Step 0: lectures/ 스캔 → 구성안 폴더 선택 → 3개 파일 로드
- Step 1: AskUserQuestion 1회 (S0 작성범위 + S1a 교수모델 + S1b 활동전략)
  - S1a/S1b는 architecture.md 분석으로 자동 추론 후 "(추천)" 표시
- Step 2: S2~S6 자동 결정 (질문 없음)
  - S2: full_script 고정 (초보 강사가 교안+대본만 보고 강의 가능)
  - S3: architecture.md 형성평가 계획에서 자동 추출
  - S4: 교수 모델에서 시간 비율 자동 파생
  - S5: 구성안 참고자료 상속 + 인터넷 리서치 기본 활성화
  - S6: Bloom's 발문 자동 매핑 + Gagne 체크리스트 고정
- Step 3: 자동 결정 요약 출력
- Step 4: input_data.json 생성

**폴더 생성**: 선택된 강의 루트 폴더 아래 `02_script/` 생성
**산출물**: `02_script/input_data.json` — 스키마: `.claude/templates/input-schema-script.json`

**사용자 인자**: {$ARGUMENTS 내용이 있으면 여기에 포함}
```

**완료 확인**:
1. Glob `lectures/*_*/02_script/input_data.json`으로 생성된 파일 경로 찾기 → `output_dir` 확정
2. Read로 `input_data.json` 로드 → `script_config` 객체 존재 확인
3. `script_config.teaching_model`이 유효한 enum 값인지 검증
4. `script_config.time_ratio.intro + main + wrap == 100` 검증

---

### Phase 2: 탐색적 리서치

**사전 처리** (오케스트레이터 수행):

1. `{output_dir}/input_data.json`을 Read하여 `script_config.teaching_model`과 `script_config.reference_sources`, `script_config.activity_strategies` 추출
2. `teaching_model` 값을 한글 변환: `direct_instruction`→"직접교수법", `pbl`→"PBL", `flipped`→"플립러닝", `mixed`→"혼합"
3. `script_config.activity_strategies`를 한글 변환: `individual_practice`→"개인 실습", `group_activity`→"그룹 활동", `discussion`→"토론·발문", `project`→"프로젝트"

**Agent 호출**:

```
- subagent_type: research-agent
- prompt:

강의교안을 위한 탐색적 리서치를 수행하세요.

**지시사항**: `.claude/agents/research-agent/AGENT.md`를 읽고 "강의교안 탐색적 리서치 (Phase 2) 세부 워크플로우" 섹션을 따르세요.

**스키마 참조**: `.claude/templates/input-schema-script.json` (필드 의미·유효값·관계 이해용)
**입력**: `{output_dir}/input_data.json`
**구성안 참조**: `{source_outline.outline_path}`, `{source_outline.architecture_path}`
**산출물 위치**: `{output_dir}/`
**모드**: 탐색적 (orientation) — 고착 효과 방지 필터 적용
**교수 모델**: {teaching_model_한글} (검색 키워드에 반영)
**활동 전략**: {activity_strategies_한글} (검색 키워드에 반영)
**제약**: 웹 검색 15회, NBLM 쿼리 노트북당 5회 이내
```

**완료 확인**: `{output_dir}/research_exploration.md` 존재 확인

### Phase 3: 브레인스토밍 → brainstorm-agent (발문, 활동, 사례 구상)

<!-- TODO: Phase 3 프롬프트 구현 예정 -->

### Phase 4: 심화 리서치 → research-agent (브레인스토밍 기반 예시·보충 콘텐츠 수집)

<!-- TODO: Phase 4 프롬프트 구현 예정 -->

### Phase 5: 교안 구조 설계 → architecture-agent (도입-전개-정리, Gagne 9사태)

<!-- TODO: Phase 5 프롬프트 구현 예정 -->

### Phase 6: 교안 작성 → writer-agent (섹션별 스크립트, 발문, 활동, 평가문항)

<!-- TODO: Phase 6 프롬프트 구현 예정 -->

### Phase 7: 품질 검토 → review-agent (목표-활동-평가 정렬, 시간 배분)

<!-- TODO: Phase 7 프롬프트 구현 예정 -->

## 산출물 (02_script/)

```
lectures/YYYY-MM-DD_{강의명}/02_script/
├── input_data.json              # Phase 1: 구성안 로드 + 교수법 선택 + 자동 결정
├── research_exploration.md      # Phase 2: 탐색적 리서치
├── brainstorm_result.md         # Phase 3: 브레인스토밍
├── research_deep.md             # Phase 4: 심화 리서치
├── architecture.md              # Phase 5: 교안 구조 설계
├── lecture_script.md            # Phase 6: 최종 교안 (교안+강사대본) ★
└── quality_review.md            # Phase 7: 품질 검토
```
