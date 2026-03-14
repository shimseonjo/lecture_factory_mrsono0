---
name: lecture-script
description: 강의교안 생성 - 10단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 구조설계 → 교안작성 → 교안검토 → 대본생성 → 대본검토 → 블록통합)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion, TodoWrite, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# 강의교안 생성 워크플로우

## 작업 지시

$ARGUMENTS

## 오케스트레이터 실행 로직

**당신은 10단계 파이프라인의 오케스트레이터다.** 직접 콘텐츠를 작성하지 않는다. 각 Phase를 Agent 도구로 전담 에이전트에 위임하고, Phase 간 데이터 흐름을 관리한다.

### Step 0: 초기화

1. `today` = 오늘 날짜 (YYYY-MM-DD 형식)
2. `project_root` = 현재 작업 디렉토리
3. `output_dir` = Phase 1 완료 후 결정
4. TodoWrite로 Phase 1~10을 pending 등록

### Phase 1~10 공통 실행 규칙

각 Phase 실행 시 반드시:
1. TodoWrite로 현재 Phase를 `in_progress` 표시
2. Agent 도구로 해당 에이전트 호출 (아래 Phase별 템플릿 사용)
3. 에이전트 반환 후 **필수 산출물 존재 확인** (Glob 또는 Read)
4. 산출물 확인 성공 → TodoWrite로 `completed`, 다음 Phase 진행
5. 산출물 확인 실패 → 사용자에게 보고 후 **중단**

---

### [CRITICAL] 필수 실행 규칙

> **이 규칙은 Phase 1~10 전체에 적용되며, 어떠한 예외도 허용하지 않는다.**

1. **순차 실행 필수**: Phase N이 완료(GATE 통과)되기 전에 Phase N+1을 시작할 수 없다.
2. **Phase 병합 금지**: 두 개 이상의 Phase를 하나의 Agent 호출로 합쳐서 실행하지 않는다.
   - 금지 예: "Phase 7과 8을 한 번에 처리", "검토와 병합을 동시에"
3. **Sub-step 생략 금지**: Phase 내의 번호가 매겨진 Step(예: Step 7-1, 7-2, 7-3)은 모두 실행한다.
   - 금지 예: "블록이 1개이므로 검토 생략", "이전에 확인했으므로 GATE 스킵"
4. **GATE CHECK 필수**: GATE 테이블이 있는 Phase는 모든 항목이 PASS여야 다음으로 진행한다.
   - GATE 실패 시: 해당 Phase에서 중단하고 실패 원인을 사용자에게 보고한다.
   - GATE를 "대략 확인" 또는 "요약 확인"으로 대체할 수 없다 — 각 항목을 개별 검증한다.
5. **블록 전수 처리**: `blocks[]` 배열의 모든 블록에 대해 동일한 처리를 수행한다.
   - 금지 예: "대표 블록 1개만 검토", "나머지는 유사하므로 생략"

**GATE CHECK 프로토콜**:
```
for each gate_item in GATE_TABLE:
    result = 검증 실행 (Glob / Read / Grep)
    if result == FAIL:
        → 실패 항목·원인 출력
        → 해당 Phase 중단
        → 사용자에게 보고
if all gate_items == PASS:
    → 다음 Phase 진행 허용
```

---

### Phase 1: 입력 수집

**Agent 호출**:
- **subagent_type**: `input-agent`
- **prompt**:

```
강의교안 워크플로우의 입력을 수집하세요.

**지시사항**: `.claude/agents/input-agent/AGENT.md`를 읽고 라우팅에 따라 `script-input.md`를 로드하여 따르세요.

**핵심 원칙**:
- Step 0: lectures/ 스캔 → 구성안 폴더 선택 → 3개 파일 로드
- Step 1: S0~S6 전체 자동 결정 (질문 없음)
  - S0: 기본값 "전체 차시" (Day 목록 파싱)
  - S1a: architecture.md 활동 유형 키워드 분석 → 교수 모델 자동 추론
  - S1b: architecture.md 활동 유형 키워드 분석 → 활동 전략 자동 추론
  - S2: full_script 고정 (초보 강사가 교안+대본만 보고 강의 가능)
  - S3: architecture.md 형성평가 계획에서 자동 추출
  - S4: 교수 모델에서 시간 비율 자동 파생
  - S5: 구성안 참고자료 상속 + 인터넷 리서치 기본 활성화
  - S6: Bloom's 발문 자동 매핑 + Gagne 체크리스트 고정
- Step 2: 전체 설정 요약 + AskUserQuestion **반드시 1회** (확인/변경)
  - S0~S6 전체를 요약 출력 후 "이 설정으로 진행할까요?" 확인
  - "변경 필요" 선택 시 해당 항목만 갱신 (예: "S0: Day 1만", "S1a: PBL")
- Step 3: input_data.json 생성

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

**지시사항**: `.claude/agents/research-agent/AGENT.md`를 읽고 라우팅에 따라 `script-exploration.md`를 로드하여 따르세요.

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

**사전 처리** (오케스트레이터 수행):

1. `{output_dir}/input_data.json`을 Read하여 추출:
   - `script_config.teaching_model` → 한글 변환: `direct_instruction`→"직접교수법", `pbl`→"PBL", `flipped`→"플립러닝", `mixed`→"혼합"
   - `script_config.activity_strategies` → 한글 변환: `individual_practice`→"개인 실습", `group_activity`→"그룹 활동", `discussion`→"토론·발문", `project`→"프로젝트"
   - `source_outline.outline_path`, `source_outline.architecture_path` 추출
2. `{output_dir}/research_exploration.md` 존재 확인

**Agent 호출**:

```
- subagent_type: brainstorm-agent
- prompt:

탐색적 리서치 결과를 기반으로 교안에 필요한 발문, 학습활동, 실생활 사례, Gagne 9사태 구현 방안을 브레인스토밍하세요.

**지시사항**: `.claude/agents/brainstorm-agent/AGENT.md`를 읽고 라우팅에 따라 `script-brainstorm.md`를 로드하여 따르세요.

**스키마 참조**: `.claude/templates/input-schema-script.json` (필드 의미·유효값·관계 이해용)
**입력**:
- `{output_dir}/input_data.json`
- `{output_dir}/research_exploration.md`
**구성안 참조**: `{source_outline.outline_path}`, `{source_outline.architecture_path}`
**산출물 위치**: `{output_dir}/`
**교수 모델**: {teaching_model_한글}
**활동 전략**: {activity_strategies_한글}
**제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**완료 확인**: `{output_dir}/brainstorm_result.md` 존재 확인

### Phase 4: 심화 리서치 → research-agent (브레인스토밍 기반 교수법 검증·활동 보충)

**사전 처리** (오케스트레이터 수행):
1. `{output_dir}/input_data.json` Read:
   - `script_config.teaching_model` → 한글 변환 (direct_instruction→직접교수법, pbl→PBL, flipped→플립러닝, mixed→혼합)
   - `script_config.reference_sources` → local_folders, notebooklm_urls, web_research 추출
   - `script_config.instructional_model_map` → primary_model, grr_focus 추출
   - `script_config.formative_assessment` → primary_type, assessment_plan 추출
   - `source_outline.outline_path`, `source_outline.architecture_path` 추출
2. `{output_dir}/brainstorm_result.md` 존재 확인 (Phase 3 산출물)
3. `brainstorm_result.md` §7 테이블 파악: 요청 건수, 유형별 분포, 높음 우선순위 비율

**Agent 호출**:

```
subagent_type: research-agent
prompt: |
  당신은 교안 심화 리서치 에이전트입니다.
  `.claude/agents/research-agent/AGENT.md`를 읽고 라우팅에 따라 `script-deep.md`를 로드하여 Step 0~2를 실행하세요.

  **입력 파일**:
  - brainstorm_result.md: `{output_dir}/brainstorm_result.md` (§1·§2·§5·§7 참조)
  - input_data.json: `{output_dir}/input_data.json`
  - 스키마 참조: `.claude/templates/input-schema-script.json`
  - 구성안 참조: `{source_outline.outline_path}`, `{source_outline.architecture_path}` (변경 불가 기준)

  **교수 모델**: {teaching_model_한글} ({script_config.teaching_model})
  **검증 초점**: 교수법 효과성 검증 (효과 크기 + 맥락 전이 + SLO 측정 타당성)
  **산출물 위치**: `{output_dir}/`

  **제약**:
  - 웹 검색: 25회 이내
  - NBLM 쿼리: 5회 이내
  - 삼각검증 추가 검색: 5회 이내
  - 3자료원(로컬·NBLM·웹) 모두 순차 실행 필수
  - Anti-Hallucination Protocol 필수 적용
```

**완료 확인**: `{output_dir}/research_deep.md` 존재 확인

### Phase 5: 교안 구조 설계 → architecture-agent (도입-전개-정리, Gagne 9사태)

**사전 처리** (오케스트레이터 수행):

1. `{output_dir}/input_data.json` Read:
   - `script_config.teaching_model` → 한글 변환: `direct_instruction`→"직접교수법", `pbl`→"PBL", `flipped`→"플립러닝", `mixed`→"혼합"
   - `script_config.time_ratio` → intro, main, wrap 비율 추출
   - `script_config.bloom_question_map` → 차시별 발문 수준 매핑 추출
   - `script_config.formative_assessment` → 형성평가 계획 추출
   - `script_config.instructional_model_map` → primary_model, grr_focus 추출
   - `source_outline.outline_path`, `source_outline.architecture_path`, `source_outline.outline_input_path` 추출
2. `{output_dir}/brainstorm_result.md` 존재 확인
3. `{output_dir}/research_deep.md` 존재 확인
4. **content_type 기반 context7 필수 판별**:
   - 구성안 `architecture.md` §4-2에서 모든 차시의 content_type 추출
   - **폴백**: §4-2에 content_type 열이 없으면 → `keywords[]`의 각 키워드에 대해 기술 라이브러리 여부 판별 후, 실습/활동 비율 50%+ 차시를 `hands-on`으로, 나머지를 `concept`으로 추론하고 경고 출력
   - `hands_on_count` = content_type == "hands-on"인 차시 수
   - `has_tech_keywords` = `input_data.json`의 `keywords[]`에 기술 라이브러리 1개 이상
   - **context7 필수**: `hands_on_count >= 1 AND has_tech_keywords == true`
   - **context7 선택**: `hands_on_count == 0 AND has_tech_keywords == true`
   - **context7 불필요**: `has_tech_keywords == false`

5. **Context7 기술 문서 수집** (context7 필수/선택 시):
   - `input_data.json`의 `keywords[]` + `topic`에서 기술 키워드 추출
   - 구성안 `architecture.md` §4-2의 content_type == "hands-on" 차시의 하위 주제명에서 라이브러리/도구 이름 추출
   - 추출된 각 라이브러리에 대해:
     a. `resolve-library-id`(libraryName=라이브러리명)로 Context7 ID 조회
     b. 유효한 ID가 있으면 `query-docs`(libraryId=Context7_ID, query=영어_기술_키워드)로 문서 수집
        - **query 작성 가이드**: hands-on 차시별 하위 주제에서 핵심 기술 키워드를 영어로 추출
        - 좋은 예: `"dependency injection @Autowired configuration"`, `"REST controller request mapping"`
        - 나쁜 예: `"스프링부트 의존성 주입"` (한국어), `"setup"` (너무 짧음)
        - 차시별로 다른 query를 사용하여 세부 주제에 맞는 문서를 정밀 수집
     c. **실패 시 폴백 (최대 2회 retry)**:
        - 1차 실패: 동일 라이브러리에 대해 query를 단순화하여 재시도
        - 2차 실패: WebSearch + WebFetch로 공식 문서 직접 수집 (핵심 API 3~5개)
        - 폴백 결과도 context7_reference.md에 `[폴백: 웹 검색]` 태그와 함께 기록
   - 수집 결과를 `{output_dir}/context7_reference.md`에 저장:
     - **§1 Library ID Cache**: `| 라이브러리 | Context7 ID | 버전 |` 테이블 (Phase 6, 7에서 재사용)
     - **§2 라이브러리별 문서**: API 목록, 코드 예제, 버전 정보, 관련 차시 태깅
   - Context7에 미등록 라이브러리(`resolve-library-id` 결과 없음)는 WebSearch + WebFetch로 공식 문서 직접 수집 (핵심 3~5개)
   - **제약**: 라이브러리 최대 5개, 라이브러리당 `query-docs` 최대 5회, WebSearch 폴백 최대 5회

6. **context7 필수인데 수집 전체 실패 시** (파이프라인 중단 방지):
   - `hands_on_count >= 1`인데 context7 + 웹 폴백 모두 실패하여 기술 문서 0건인 경우:
   - `context7_reference.md`를 최소 골격으로 생성:
     ```
     # Context7 Reference (폴백)
     ## §1 Library ID Cache
     | 라이브러리 | Context7 ID | 상태 |
     | {라이브러리명} | — | 수집 실패 |
     ## §2 수집 결과
     수집 실패. writer-agent는 공식 문서 URL을 기반으로 코드를 작성해야 한다.
     ## §3 폴백 지침
     - hands-on 차시 목록: {D1-2, D1-4, ...}
     ```

**Agent 호출**:

```
subagent_type: architecture-agent
prompt: |
  당신은 교안 구조 설계 에이전트입니다.
  `.claude/agents/architecture-agent/AGENT.md`를 읽고 라우팅에 따라 `script-architecture.md`를 로드하여 Step 0~4를 실행하세요.

  **입력 파일**:
  - input_data.json: `{output_dir}/input_data.json`
  - brainstorm_result.md: `{output_dir}/brainstorm_result.md` (§1 발문, §2 활동, §3 사례, §4 설명 전략, §5 Gagne, §6 오개념)
  - research_deep.md: `{output_dir}/research_deep.md` (확정된 전제, 확보된 소재, 미해결 항목)
  - context7_reference.md: `{output_dir}/context7_reference.md` (존재 시 — 기술 문서/코드 예제)
  - 스키마 참조: `.claude/templates/input-schema-script.json`

  **구성안 참조** (변경 불가):
  - architecture.md: `{source_outline.architecture_path}`
  - lecture_outline.md: `{source_outline.outline_path}`
  - input_data.json: `{source_outline.outline_input_path}`

  **교수 모델**: {teaching_model_한글} ({script_config.teaching_model})
  **시간 비율**: 도입 {time_ratio.intro}% / 전개 {time_ratio.main}% / 정리 {time_ratio.wrap}%
  **산출물 위치**: `{output_dir}/`
  **산출물 파일**: `architecture.md`

  **제약**: 도구 Read, Write만 사용. Agent 중첩 금지.
```

**완료 확인** (3단계 검증):
1. `{output_dir}/architecture.md` 존재 확인 (Glob)
2. Read로 architecture.md 로드 → §8 검증 결과 섹션에서 6항목 모두 "Pass" 확인
3. §3 차시별 내부 구조에서 Gagne 체크 값이 모든 차시에서 7/9 이상인지 확인

**GATE-5** (모든 항목 PASS 시에만 Phase 6 진행):

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G5-1 | `architecture.md` 존재 | Glob `{output_dir}/architecture.md` | 1개 | 중단 |
| G5-2 | §8 검증 결과 6항목 Pass | Read architecture.md §8 | 전체 Pass | 중단 |
| G5-3 | Gagne 체크 ≥ 7/9 | Read architecture.md §3 | 모든 차시 ≥ 7/9 | 중단 |
| G5-4 | content_type 필수 context7 검증 | 아래 로직 | 조건부 | 조건부 중단 |

**G5-4 상세 로직**:
```
hands_on_sessions = architecture.md §4-2에서 content_type == "hands-on"인 차시 목록
if len(hands_on_sessions) >= 1:
    if NOT Glob("{output_dir}/context7_reference.md"):
        → G5-4 FAIL: "hands-on 차시 {N}개 존재하나 context7_reference.md 미생성"
        → 중단
    else:
        context7 = Read context7_reference.md
        if "수집 실패" in context7 §2:
            → G5-4 CONDITIONAL PASS: "context7 수집 실패 — 폴백 모드"
        else:
            → G5-4 PASS
else:
    → G5-4 PASS (자동 — hands-on 없음)
```

**GATE-5 전체 통과 → Phase 6 진행 허용**

### Phase 6: 강의교안 콘텐츠 작성 → writer-agent (학습 콘텐츠 전용)

**사전 처리** (오케스트레이터 수행):

1. `{output_dir}/input_data.json` Read:
   - `script_config.teaching_model` 추출
   - schedule에서 `total_sessions`, `days` 계산
2. `{output_dir}/architecture.md` Read → **블록 경계 동적 결정**:
   - 시간표에서 Day별 세션 목록 + 시간 정보 추출
   - 각 Day에 대해 30분 이상 공백(점심 등) 탐색
   - `sessions_in_day ≥ 6 AND 공백 존재` → AM/PM 2블록 분할
   - 그 외 → Day 전체 1블록
   - 결과: `blocks[]` 배열 (각 블록에 `{block_id, day, half, sessions}` 포함)
   - 블록 ID: `D{day}_{AM|PM}` (분할 시) 또는 `D{day}` (미분할 시)
   - `sessions[]` 배열 생성: 전체 교시 목록 (각 세션에 `{session_id, day, num, block_id}` 포함)
   - 세션 ID: `D{day}-{num}` (예: D1-1, D1-2, ..., D3-8)
3. **분할 판단**:
   - `total_sessions ≤ 10` → 단일 모드 (writer-agent 1회 호출, 산출물 형식은 블록 모드와 동일)
   - `total_sessions > 10` → 블록별 분할 (`total_parts = len(blocks) + 2`)
   - **공통**: 두 모드 모두 `_header.md` + `session_D*.md` + `_footer.md` 생성. GATE-6 → Phase 7 → Phase 8 동일 적용.
4. `{output_dir}/architecture.md` Read → §8 검증 결과 6항목 Pass 재확인

**단일 모드 Agent 호출** (total_sessions ≤ 10):

```
subagent_type: writer-agent
prompt: |
  이전 Phase 산출물을 통합하여 강의교안 콘텐츠를 작성하세요.
  ★ 이 Phase에서는 학습 콘텐츠만 작성합니다. 강사 발화문(> "...")은 작성하지 않습니다.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-content.md`를 로드하여 Step 0~5를 실행하세요.

  **입력**:
  - {output_dir}/architecture.md
  - {output_dir}/brainstorm_result.md
  - {output_dir}/research_deep.md
  - {output_dir}/input_data.json
  - {output_dir}/context7_reference.md (존재 시)

  **content_type 정보**:
  - hands-on 차시: {hands_on_sessions 목록}
  - concept 차시: {concept_sessions 목록}
  - activity 차시: {activity_sessions 목록}
  - **hands-on 차시에서는 I Do에 fenced code block 필수**

  **스키마 참조**: `.claude/templates/input-schema-script.json` (script_config 필드 의미·유효값 이해용)
  **템플릿**: `.claude/templates/script-content-template.md`
  **모드**: single (전체 차시 1회 호출)
  **산출물 방식**: 차시별 독립 파일 Write (Bottom-Up 3계층 — 블록 모드와 동일)
  **산출물**: `{output_dir}/_header.md`, `{output_dir}/session_D{day}-{num}.md` × 세션 수, `{output_dir}/_footer.md`

  **제약**: 도구 Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**세션별 분할 모드** (total_sessions > 10):

오케스트레이터가 세션별로 writer-agent를 순차 호출한다.
**1회 호출에 1개 session 파일만 Write한다** — 콘텐츠 생성 집중도 확보.

- Part 0/{N}: `범위: §1~§3`, `산출물: _header.md` (Write 신규)
- Part 1~{S}/{N}: `범위: §4 세션 {session_id} (1교시)`, `산출물: session_D{day}-{num}.md` (Write 신규)
- Part {N}/{N}: `범위: §5~§8`, `산출물: _footer.md` (Write 신규)

**세션별 Context7 보강 쿼리** (세션별 분할 모드):

각 세션 writer-agent 호출 **직전에** 오케스트레이터가 수행 (해당 세션이 content_type == "hands-on"인 경우만):

1. `context7_reference.md` §1 Library ID Cache에서 캐시된 libraryId 조회
   - `context7_reference.md` 미존재 시: 해당 세션이 hands-on이면 경고 출력 후 WebSearch 폴백으로 진행
2. `architecture.md` §3에서 해당 세션의 기술 키워드 추출 (하위 주제명, 다루는 API/도구)
3. 각 키워드에 대해 `query-docs`(libraryId, query=영어_기술_키워드) 호출
   - query 작성: Phase 5와 동일 가이드 — 구체적 영어 기술 키워드
   - 예: 세션 D1-1에 "Spring Boot project setup" 주제가 있으면 `query="spring initializr project structure dependencies"`
4. 수집 결과를 `{output_dir}/context7_session_{session_id}.md`에 저장
   - 구조: 세션 ID, 라이브러리별 쿼리 결과 (API 시그니처, 코드 스니펫, 관련 문서)
5. writer-agent 호출 prompt의 입력에 추가

**제약**:
- 세션당 `query-docs` 최대 2회, Phase 6 전체 최대 12회
- 해당 세션이 content_type == "hands-on"이 아니면 스킵
- 단일 모드(`total_sessions ≤ 10`)에서는 Phase 5의 `context7_reference.md`로 충분하므로 스킵

```
subagent_type: writer-agent
prompt: |
  이전 Phase 산출물을 통합하여 강의교안 콘텐츠를 작성하세요.
  ★ 이 Phase에서는 학습 콘텐츠만 작성합니다. 강사 발화문(> "...")은 작성하지 않습니다.
  ★ 이 호출에서는 1개 교시만 작성합니다.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-content.md`를 로드하여 따르세요.

  **모드**: part ({K}/{N})
  **범위**: §4 세션 {session_id} (1교시)
  **산출물 방식**: 1개 차시 독립 파일 Write
  **Overlap 컨텍스트**: {이전 세션의 정리 섹션 30~50줄, 첫 세션이면 "없음"}

  **이 교시의 입력 (발췌)** — 오케스트레이터가 해당 교시 관련 부분만 추출:
  - architecture §3에서 {session_id} 차시 구조: {오케스트레이터가 발췌 삽입}
  - brainstorm §2에서 {session_id} 관련 활동: {오케스트레이터가 발췌 삽입}
  - brainstorm §3에서 {session_id} 관련 훅/사례: {오케스트레이터가 발췌 삽입}
  - brainstorm §4에서 {session_id} 관련 설명전략: {오케스트레이터가 발췌 삽입}
  - brainstorm §6에서 {session_id} 관련 오개념: {오케스트레이터가 발췌 삽입}
  - context7 관련 코드: {오케스트레이터가 발췌 삽입}

  **참조 파일** (전체 파일 — 발췌로 부족할 때 직접 Read):
  - {output_dir}/architecture.md
  - {output_dir}/brainstorm_result.md
  - {output_dir}/research_deep.md
  - {output_dir}/input_data.json
  - {output_dir}/context7_reference.md (존재 시)

  **이 교시의 content_type**: {content_type}
  - **hands-on**: I Do에 fenced code block 필수, 코드 블록 ≥ 3쌍
  - **concept**: 설명문 ≥ 15줄, ★ 예시 ≥ 2개
  - **activity**: 활동 지시문 ≥ 5줄, 성공 기준 명시

  **[CRITICAL] 금지 패턴 — 산출물에 포함되면 GATE-6 FAIL**:
  - "구성안 비유 체계 참조."
  - "선수 확인 질문"
  - "강사 시연을 따라 코드 작성"
  - "다음 차시 주제와의 연결점을 안내합니다."
  - "해당 SLO 달성 여부 확인"
  - 모든 차시에 동일한 "필요 자료" 또는 "흔한 실수"

  **[CRITICAL] 필수 포함 — 없으면 GATE-6 FAIL**:
  - hands-on: 코드 블록(```) ≥ 3쌍, ★ 예시 ≥ 2개, ≥ 150줄
  - concept: ★ 예시 ≥ 2개, ≥ 120줄
  - activity: ≥ 100줄

  **스키마 참조**: `.claude/templates/input-schema-script.json`
  **템플릿**: `.claude/templates/script-content-template.md`
  **산출물**: `{output_dir}/session_D{day}-{num}.md` (1파일 Write)

  **제약**: 도구 Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**세션별 미니 검증** (각 세션 Part 완료 후 오케스트레이터 수행):
1. `{output_dir}/session_D{day}-{num}.md` 존재 확인
2. `session_*.md` Read → 도입/I Do/We Do/You Do/정리 5구간 존재 확인
3. 시간 합산이 배정 시간과 일치 확인
4. **[신규] Bash로 GATE 검증 스크립트 실행**:
   ```
   bash .claude/scripts/gate-check-session.sh {output_dir}/session_D{day}-{num}.md {content_type}
   ```
   - 스크립트 반환값 0이면 PASS, 1이면 FAIL → 해당 교시 재작성 1회 시도

**GATE-6** (전체 Part 완료 후 — 모든 항목 PASS 시에만 Phase 7 진행):

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G6-1 | `_header.md` 존재 | Glob `{output_dir}/_header.md` | 1개 | 중단 |
| G6-2 | `_footer.md` 존재 | Glob `{output_dir}/_footer.md` | 1개 | 중단 |
| G6-3 | `session_D*.md` 파일 수 == len(sessions[]) | Glob `{output_dir}/session_D*.md` + 카운트 | 일치 | 중단 |
| G6-4 | 각 session에 도입/I Do/We Do/You Do/정리 5구간 존재 | Read 각 `session_*.md` | 5구간 | 중단 |
| G6-5 | 각 session 시간 합산 == 배정 시간 | Read 각 `session_*.md` | 일치 | 중단 |
| G6-6 | ★ 핵심 예시 최소 2개 존재 (hands-on/concept 차시) | Read 각 해당 `session_*.md` | ≥ 2개 | 중단 |
| G6-7 | 금지 문구 미존재 | Bash: gate-check-session.sh | 0건 | 해당 교시 재작성 |
| G6-8 | hands-on 코드 블록 ≥ 3쌍 | Bash: gate-check-session.sh | ≥ 6 fence | 해당 교시 재작성 |
| G6-9 | session 줄 수 하한 | Bash: gate-check-session.sh | ≥ 120줄 | 해당 교시 재작성 |

**GATE-6 전체 통과 → Phase 7 진행 허용**

### Phase 7: 교안 콘텐츠 검토 → review-agent (교안 범위 검증 + 재작성 루프)

> **[MANDATORY] `blocks[]` 배열의 모든 블록에 대해 Step 7-1 → 7-2 → 7-3을 전수 실행한다. 블록 생략 불가.**

**사전 처리** (오케스트레이터 수행):

1. Glob `{output_dir}/session_D*.md` → 차시 파일들 존재 확인 (Phase 6 산출물)
2. `{output_dir}/_header.md`, `{output_dir}/_footer.md` 존재 확인
3. `{output_dir}/input_data.json` Read → `source_outline.outline_path`, `source_outline.architecture_path` 추출
4. Phase 6에서 결정한 `blocks[]`, `sessions[]` 배열 재사용

**블록별 검토 루프** (오케스트레이터가 `blocks[]`의 **각 블록**에 대해 순차 실행):

#### Step 7-1: 블록별 사전 처리 (Context7 코드 정확성 검증 기준 수집)

해당 블록에 content_type == "hands-on" 차시가 1개 이상인 경우 (코드 정확성은 교안 단계에서 검증):
1. 해당 블록의 hands-on `session_D{day}-{num}.md` 파일들에서 코드 블록(``` 구간) 추출
   - **코드 블록 0개인 hands-on 차시 발견 시**: 즉시 경고 플래그 설정 (Step 7-2 review-agent에 전달)
2. 코드에 사용된 주요 API/함수명 식별 (import문, 함수 호출, 클래스명 등)
3. `context7_reference.md` §1 Library ID Cache에서 대응 libraryId 조회
4. `query-docs`(libraryId, query="함수명 signature parameters usage") 호출
5. 결과를 `{output_dir}/context7_verify_{block_id}.md`에 저장:
   - 검증 대상 코드 블록 목록
   - API별 공식 시그니처 (파라미터 타입, 반환 타입)
   - 불일치 플래그 (있으면)
6. **제약**: 블록당 `query-docs` 최대 1회, Phase 7 전체 최대 6회

해당 블록에 content_type == "hands-on" 차시가 0개이면 Step 7-1 스킵 → Step 7-2로 직행.
`context7_reference.md` 미존재 + hands-on 차시 있음: `context7_verify_{block_id}.md`에 "검증 기준 없음" 기록 후 Step 7-2 진행.

#### Step 7-2: review-agent 호출 + 산출물 즉시 확인

review-agent를 호출하고, 반환 후 `_review_content_{block_id}.md` 존재를 **즉시** Glob으로 확인한다.
파일이 없으면 해당 블록에서 중단하고 사용자에게 보고한다.

```
subagent_type: review-agent
prompt: |
  블록 {block_id} 교안 콘텐츠의 품질을 검토하세요.

  **지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-review.md`를 로드하여
  **교안 검토 모드**를 따르세요.

  **검증 대상**: `{output_dir}/session_D{day}-{num}.md` (해당 블록의 차시 파일들: {session_list})
  **검증 범위**: {block_id} ({session_count}개 세션)

  **검증 기준 (교안)**:
  - `{output_dir}/architecture.md` (GRR/전환 설계 기준)
  - `{output_dir}/brainstorm_result.md` (활동/사례/오개념 원본)
  - `{output_dir}/research_deep.md` (확보된 소재, 미해결 항목)
  - `{output_dir}/input_data.json` (교수 모델, 시간 비율, 설정값)
  - `{output_dir}/context7_verify_{block_id}.md` (존재 시 — 코드 API 공식 시그니처 검증 기준)

  **검증 기준 (구성안)**:
  - `{source_outline.outline_path}` (CLO/SLO 원본)
  - `{source_outline.architecture_path}` (정렬 맵, 평가, 시간 예산 원본)

  **스키마 참조**: `.claude/templates/input-schema-script.json` (script_config 필드 의미·유효값 이해용)

  **산출물**: `{output_dir}/_review_content_{block_id}.md`

  **검증 영역 (교안 범위)**:
  1. 교수설계 프레임워크 (G-1~G-6): GRR 4단계, 2-레이어, 15분 분절, 도입/I Do/We Do/You Do/정리 5구간
  2. 학습활동/흐름 (P-1~P-5): CMU 3점, 차시 간 전환, You Do 완전성
  3. 시간 배분 (T-1~T-8): 교시 시간 합산, 비율 준수, GRR 시간, 시간큐
  4. 콘텐츠 정확성 (C-1~C-12): Anti-Hallucination, CLO/SLO 일치, 소재 근거, 코드 API 정확성(C-10), 다중 예시 완전성(C-11), 플레이스홀더 잔존(C-12)
  5. 교안 콘텐츠 품질 (N-1~N-6): 활동 3요소, You Do 완전성, 핵심 예시 충분성

  **판정 기준**: PASS (Major=0, Minor≤3) / CONDITIONAL PASS (Major=0, Minor≥4) / REVISION REQUIRED (Major≥1)

  **[CRITICAL] 검증 항목 29개(G:5, T:8, C:12, EX:4) 전수 수행 필수.**
  - Step 2~5의 모든 항목을 각각 개별 검증하고 결과를 산출물에 기록한다
  - 산출물의 검증 상세 테이블에 29행 이상이 포함되어야 한다
  - 항목을 그룹으로 묶거나 "Pass"로 일괄 처리하지 않는다
  - 항목 수 < 29이면 GATE-7 FAIL로 처리되어 재호출된다

  **제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

#### Step 7-3: 판정 분기

1. `_review_content_{block_id}.md` Read → 판정 결과 추출
2. **PASS 또는 CONDITIONAL PASS** → 다음 블록으로 진행
3. **REVISION_REQUIRED** → writer-agent 재작성 1회 → review-agent 재검토 1회:
   - 재검토 후에도 REVISION_REQUIRED → 사용자에게 보고 후 **중단**

**REVISION_REQUIRED 시 재작성 호출**:

```
subagent_type: writer-agent
prompt: |
  블록 {block_id}의 Major 위반을 수정하여 해당 세션만 재작성하세요.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-content.md`를 로드하여 **revision 모드**를 따르세요.

  **모드**: revision
  **범위**: 블록 {block_id} ({session_list})
  **수정 가이드**: `{output_dir}/_review_content_{block_id}.md`

  **입력**:
  - {output_dir}/session_D{day}-{num}.md (해당 블록의 차시 파일들)
  - {output_dir}/_review_content_{block_id}.md (Major 위반 목록 + 수정 가이드)
  - {output_dir}/architecture.md
  - {output_dir}/brainstorm_result.md
  - {output_dir}/input_data.json

  **산출물**: `{output_dir}/session_D{day}-{num}.md` (위반 차시만 전체 Write로 교체)

  **제약**: 해당 블록의 위반 차시만 수정. 다른 차시 파일 수정 금지. Agent 중첩 금지.
```

#### GATE-7 (모든 블록 완료 후 — 전체 통과 시에만 Phase 8 진행)

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G7-1 | `_review_content_*.md` 파일 수 == len(blocks[]) | Glob + 카운트 | 일치 | 중단 |
| G7-2 | 각 판정 != REVISION_REQUIRED | Read 각 `_review_content_*.md` | 전체 PASS 또는 CONDITIONAL | 중단 |
| G7-3 | blocks[] 전체 블록 ID가 파일명에 매칭 | Glob 패턴 대조 | 전체 일치 | 중단 |
| G7-4 | review 검증 항목 수 ≥ 29 | Read `_review_content_*.md` → 검증 ID 행 카운트 | ≥ 29 | review-agent 재호출 |

**GATE-7 전체 통과 → Phase 8 진행 허용**

---

### Phase 8: 강사대본 생성 → writer-agent (교안 기반 전달 스크립트)

> **[MANDATORY] Phase 7(교안 검토) GATE-7 통과 후 실행. blocks[] 배열의 모든 블록에 대해 전수 실행한다.**

**사전 처리** (오케스트레이터 수행):
1. Phase 7(교안 검토)에서 PASS/CONDITIONAL PASS 확인
2. 모든 `session_D*.md` 파일 목록 확보
3. `architecture.md` §3에서 시간 배분 정보 추출
4. `blocks[]` 배열 재사용 (Phase 6과 동일 분할)

**단일/블록별 Agent 호출**:

```
subagent_type: writer-agent
prompt: |
  강의교안 콘텐츠를 기반으로 **강사대본**을 생성하세요.
  ★ 교안의 학습 콘텐츠를 강사가 실제 말할 발화문으로 변환합니다.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-narration.md`를 로드하여 따르세요.

  **모드**: {single 또는 part (K/N)}
  **범위**: {해당 블록/전체}

  **입력**:
  - {output_dir}/session_D{day}-{num}.md (교안 콘텐츠 — Phase 6 산출물)
  - {output_dir}/architecture.md (시간 배분)
  - {output_dir}/brainstorm_result.md §1(발문), §3(훅/사례)
  - {output_dir}/input_data.json (tone, 교수 모델)
  - {output_dir}/code_examples_D{day}-{num}.md (존재 시)

  **Overlap 컨텍스트**: {이전 블록 마지막 narration 정리 섹션, 첫 블록이면 "없음"}

  **스키마 참조**: `.claude/templates/input-schema-script.json`
  **템플릿**: `.claude/templates/script-narration-template.md`
  **산출물**: `{output_dir}/narration_D{day}-{num}.md` × 세션 수

  **[CRITICAL] 금지 패턴 — 산출물에 포함되면 GATE-8 FAIL**:
  - "___" 빈칸 (학습목표, 핵심 요약 등 미완성)
  - "(강사가 핵심 개념을 설명하고 코드를 시연하는 구간)" 같은 범용 지시문
  - "(선수지식 확인 발문)", "(학습목표 안내)", "(핵심 3가지 요약)" 같은 placeholder
  - 40개 파일이 동일한 발화문 (차시별 고유 내용 필수)

  **[CRITICAL] 필수 조건**:
  - 최소 분량: 80줄 이상
  - 교안 session_D*.md의 I Do/We Do/You Do 내용을 구어체 발화문으로 변환
  - 발화문(> ") ≥ 5개, 발문(❓) ≥ 2개

  **제약**: Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**세션별 미니 검증** (각 세션 완료 후):
1. `narration_D{day}-{num}.md` 존재 확인
2. narration 파일에 도입/전개/정리 3구간 존재 확인
3. **[신규] Bash로 GATE 검증 스크립트 실행**:
   ```
   bash .claude/scripts/gate-check-narration.sh {output_dir}/narration_D{day}-{num}.md
   ```
   - 스크립트 반환값 0이면 PASS, 1이면 FAIL → 해당 교시 재작성 1회 시도

**GATE-8**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G8-1 | narration_D*.md 파일 수 == len(sessions[]) | Glob + 카운트 | 일치 | 중단 |
| G8-2 | 각 narration에 도입/전개/정리 존재 | Read 각 narration | 3구간 | 중단 |
| G8-3 | narration `___` 빈칸 0개 | Bash: gate-check-narration.sh | 0건 | 해당 교시 재작성 |
| G8-4 | narration 줄 수 ≥ 80 | Bash: gate-check-narration.sh | ≥ 80 | 해당 교시 재작성 |

**GATE-8 전체 통과 → Phase 9 진행 허용**

---

### Phase 9: 대본 품질 검토 → review-agent (대본 검토)

> **[MANDATORY] `blocks[]` 배열의 모든 블록에 대해 전수 실행한다. 블록 생략 불가.**

**블록별 검토 루프** (blocks[] 각 블록에 대해 순차):

```
subagent_type: review-agent
prompt: |
  블록 {block_id} 대본의 품질을 검토하세요.

  **지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-review.md`를 로드하여
  **대본 검토 모드**를 따르세요.

  **검증 대상**: `{output_dir}/narration_D{day}-{num}.md` (해당 블록 차시들)
  **교안 기준**: `{output_dir}/session_D{day}-{num}.md` (교안 참조 정합 확인용)
  **검증 기준**: `{output_dir}/architecture.md`, `{output_dir}/input_data.json`

  **산출물**: `{output_dir}/_review_narration_{block_id}.md`

  **제약**: Read, Write만 사용. Agent 중첩 금지.
```

**판정 분기**:
- PASS/CONDITIONAL PASS → 다음 블록
- REVISION_REQUIRED → writer-agent 재작성 1회 → 재검토 1회
  - 재검토 후에도 REVISION_REQUIRED → 사용자 보고 + 중단

**GATE-9**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G9-1 | `_review_narration_*.md` 파일 수 == len(blocks[]) | Glob + 카운트 | 일치 | 중단 |
| G9-2 | 각 판정 != REVISION_REQUIRED | Read 각 `_review_narration_*.md` | 전체 PASS/CONDITIONAL | 중단 |

**GATE-9 전체 통과 → Phase 10 진행 허용**

---

### Phase 10: 블록 통합 + 최종 검토 → review-agent (구조 완전성 + 블록 간 일관성)

> **[MANDATORY] Step 10-1 → 10-2 순서 실행, 생략 불가. 각 Step의 GATE를 통과해야 다음 Step 진행.**

**사전 처리** (오케스트레이터 수행):
- 모든 `_review_content_*.md` Read → 블록별 판정 요약 수집

#### Step 10-1: 블록 병합 (session + narration → block)

오케스트레이터가 직접 Read+Write로 수행:
1. 각 블록에 대해 해당 `session_D{day}-{num}.md` (교안) 파일들을 Read
2. 해당 블록의 `narration_D{day}-{num}.md` (대본) 파일들을 Read
3. 교안 본문에 대본을 `> 🎤 대본` 인용 블록으로 삽입하여 통합
4. Day 헤딩(`### Day {N}: {테마}`)을 삽입하고 세션들을 순서대로 결합
5. `block_D{day}_{AM|PM}.md`로 Write (블록 헤더 + 교안+대본 통합 내용 + 블록 요약)

**GATE-10-1**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G10-1a | `block_*.md` 파일 수 == len(blocks[]) | Glob + 카운트 | 일치 | 중단 |
| G10-1b | 각 block 파일 비어있지 않음 | Read 각 `block_*.md` | 내용 존재 | 중단 |

**GATE-10-1 실패 → Step 10-2 진행 불가**

#### Step 10-2: 통합 검토 (review-agent)

```
subagent_type: review-agent
prompt: |
  block_D*.md 파일들의 전체 통합 품질을 최종 검토하세요.

  **지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-review.md`를 로드하여
  **통합 검토 모드**를 따르세요.

  **검증 대상**: `{output_dir}/block_D*.md` (전체 블록 파일들)
  **교안 검토 결과**: `{output_dir}/_review_content_*.md`
  **대본 검토 결과**: `{output_dir}/_review_narration_*.md`

  **검증 기준 (교안)**:
  - `{output_dir}/architecture.md`
  - `{output_dir}/brainstorm_result.md`
  - `{output_dir}/research_deep.md`
  - `{output_dir}/input_data.json`

  **검증 기준 (구성안)**:
  - `{source_outline.outline_path}` (CLO/SLO 원본)
  - `{source_outline.architecture_path}` (정렬 맵, 평가, 시간 예산 원본)

  **스키마 참조**: `.claude/templates/input-schema-script.json` (script_config 필드 의미·유효값 이해용)

  **산출물**: `{output_dir}/quality_review.md`

  **통합 검증 영역 (~15항목)**:
  1. 구조 완전성 (S-1~S-5): 블록 파일 전체 존재, 표기법, 서브섹션, 차시 커버리지
  2. 블록 간 전환 일관성: AM→PM, Day간 전환 문구 자연스러움
  3. SLO 커버리지 전체 확인: 모든 SLO가 블록 파일에서 다뤄지는지
  4. 교안-대본 정합성: 교안 콘텐츠와 대본 발화문의 내용 일관성
  5. 용어/표기 통일: 전체 문서 일관성

  **판정 기준**: PASS (Major=0, Minor≤3) / CONDITIONAL PASS (Major=0, Minor≥4) / REVISION REQUIRED (Major≥1)

  **제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**GATE-10-2**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G10-2a | `quality_review.md` 존재 | Glob `{output_dir}/quality_review.md` | 1개 | 중단 |
| G10-2b | 판정 결과 추출 가능 | Read `quality_review.md` → 판정 추출 | PASS/CONDITIONAL/REVISION 중 하나 | 중단 |
| G10-2c | `block_*.md` 파일 존재 유지 | Glob `{output_dir}/block_*.md` | len(blocks[])개 | 중단 |

**GATE-10-2 통과 후 판정에 따라 후속 조치 안내**:
- **PASS**: "교안+대본 품질 검토 통과. block_D*.md 파일들이 확정되었습니다."
- **CONDITIONAL PASS**: "Minor 위반 {N}개 발견. quality_review.md를 확인하여 부분 수정을 권고합니다."
- **REVISION REQUIRED**: "Major 위반 {N}개 발견. quality_review.md의 수정 가이드에 따라 해당 섹션을 재작성해야 합니다."

## 산출물 (02_script/)

```
lectures/YYYY-MM-DD_{강의명}/02_script/
├── input_data.json                      # Phase 1: 구성안 로드 + 교수법 선택 + 자동 결정
├── research_exploration.md              # Phase 2: 탐색적 리서치
├── brainstorm_result.md                 # Phase 3: 브레인스토밍
├── research_deep.md                     # Phase 4: 심화 리서치
├── context7_reference.md                # Phase 5: 기술 문서 참조 (기술 교육 시)
├── architecture.md                      # Phase 5: 교안 구조 설계
├── _header.md                           # Phase 6: §1~§3 머리말 (Part 0)
├── session_D1-1.md ~ D{N}-{M}.md       # Phase 6: 차시별 독립 교안 콘텐츠 ★ (Part 1~B)
├── _footer.md                           # Phase 6: §5~§8 꼬리말 (Part N)
├── code_examples_D{day}-{num}.md        # Phase 6: 50줄+ 코드 모음 [신규, 선택]
├── context7_block_{block_id}.md         # Phase 6: 블록별 정밀 기술 문서 (기술 교육 시)
├── context7_verify_{block_id}.md        # Phase 7: 블록별 코드 검증 기준 (기술 교육 시)
├── _review_content_{block_id}.md        # Phase 7: 교안 검토 결과 [변경]
├── narration_D1-1.md ~ D{N}-{M}.md     # Phase 8: 차시별 강사대본 ★ [신규]
├── _review_narration_{block_id}.md      # Phase 9: 대본 검토 결과 [신규]
├── block_D{day}_{AM|PM}.md             # Phase 10: 교안+대본 통합 ★ 최종 [변경]
└── quality_review.md                    # Phase 10: 최종 품질 검토 ★
```
