---
name: lecture-script
description: 강의교안 생성 - 8단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 구조설계 → 블록별작성 → 블록별검토 → 통합)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion, TodoWrite
---

# 강의교안 생성 워크플로우

## 작업 지시

$ARGUMENTS

## 오케스트레이터 실행 로직

**당신은 8단계 파이프라인의 오케스트레이터다.** 직접 콘텐츠를 작성하지 않는다. 각 Phase를 Agent 도구로 전담 에이전트에 위임하고, Phase 간 데이터 흐름을 관리한다.

### Step 0: 초기화

1. `today` = 오늘 날짜 (YYYY-MM-DD 형식)
2. `project_root` = 현재 작업 디렉토리
3. `output_dir` = Phase 1 완료 후 결정
4. TodoWrite로 Phase 1~8을 pending 등록

### Phase 1~8 공통 실행 규칙

각 Phase 실행 시 반드시:
1. TodoWrite로 현재 Phase를 `in_progress` 표시
2. Agent 도구로 해당 에이전트 호출 (아래 Phase별 템플릿 사용)
3. 에이전트 반환 후 **필수 산출물 존재 확인** (Glob 또는 Read)
4. 산출물 확인 성공 → TodoWrite로 `completed`, 다음 Phase 진행
5. 산출물 확인 실패 → 사용자에게 보고 후 **중단**

---

### [CRITICAL] 필수 실행 규칙

> **이 규칙은 Phase 1~8 전체에 적용되며, 어떠한 예외도 허용하지 않는다.**

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
   - `script_config.teaching_model` → 한글 변환 (direct_instruction→직접교수, pbl→문제기반학습, flipped→거꾸로교실, mixed→혼합)
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

### Phase 6: 블록별 교안 작성 → writer-agent (full script + 강사대본)

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
  이전 Phase 산출물을 통합하여 강의교안(full script)을 작성하세요.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-write.md`를 로드하여 Step 0~5를 실행하세요.

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
  **템플릿**: `.claude/templates/script-template.md`
  **모드**: single (전체 차시 1회 호출)
  **산출물 방식**: 차시별 독립 파일 Write (Bottom-Up 3계층 — 블록 모드와 동일)
  **산출물**: `{output_dir}/_header.md`, `{output_dir}/session_D{day}-{num}.md` × 세션 수, `{output_dir}/_footer.md`

  **제약**: 도구 Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**블록별 분할 모드** (total_sessions > 10):

오케스트레이터가 Part별로 writer-agent를 순차 호출한다.
블록 수와 경계는 architecture.md 시간표에서 동적으로 결정된다.
**산출물은 차시별 독립 파일(`session_D{day}-{num}.md`)로 생성한다** (Bottom-Up 3계층).

- Part 0/{N}: `범위: §1~§3`, `산출물: _header.md` (Write 신규)
- Part 1~{B}/{N}: `범위: §4 블록 {block_id} ({session_list})`, `산출물: session_D{day}-{num}.md × 세션 수` (각각 Write 신규)
- Part {N}/{N}: `범위: §5~§8`, `산출물: _footer.md` (Write 신규)

**블록별 Context7 보강 쿼리** (블록별 분할 모드):

각 블록(Part 1~{B}) writer-agent 호출 **직전에** 오케스트레이터가 수행:

**스킵 판단**: 해당 블록에 content_type == "hands-on" 차시가 0개이면 이 블록의 context7 보강 스킵.

1. `context7_reference.md` §1 Library ID Cache에서 캐시된 libraryId 조회
   - `context7_reference.md` 미존재 시: 이 블록에 hands-on 차시가 있으면 경고 출력 후 WebSearch 폴백으로 진행
2. `architecture.md` §3에서 해당 블록의 **hands-on 세션들의** 기술 키워드 추출 (하위 주제명, 다루는 API/도구)
3. 각 키워드에 대해 `query-docs`(libraryId, query=영어_기술_키워드) 호출
   - query 작성: Phase 5와 동일 가이드 — 구체적 영어 기술 키워드
   - 예: 블록 D1_AM에 "Spring Boot project setup" 세션이 있으면 `query="spring initializr project structure dependencies"`
4. 수집 결과를 `{output_dir}/context7_block_{block_id}.md`에 저장
   - 구조: 블록 ID, 대상 세션 목록, 라이브러리별 쿼리 결과 (API 시그니처, 코드 스니펫, 관련 문서)
5. writer-agent 호출 prompt의 입력에 추가

**제약**:
- 블록당 `query-docs` 최대 2회, Phase 6 전체 최대 12회
- 해당 블록에 hands-on 차시 0개이면 스킵
- 단일 모드(`total_sessions ≤ 10`)에서는 Phase 5의 `context7_reference.md`로 충분하므로 스킵

```
subagent_type: writer-agent
prompt: |
  이전 Phase 산출물을 통합하여 강의교안(full script)을 작성하세요.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-write.md`를 로드하여 따르세요.

  **모드**: part ({K}/{N})
  **범위**: §4 블록 {block_id} ({session_list})
  **블록 세션**: {해당 블록의 세션 목록}
  **산출물 방식**: 차시별 독립 파일 Write (Bottom-Up 3계층)
  **Overlap 컨텍스트**: {이전 블록 마지막 차시의 정리 섹션 50~100줄, 첫 블록이면 "없음"}

  **입력**:
  - {output_dir}/architecture.md
  - {output_dir}/brainstorm_result.md
  - {output_dir}/research_deep.md
  - {output_dir}/input_data.json
  - {output_dir}/context7_reference.md (존재 시)
  - {output_dir}/context7_block_{block_id}.md (존재 시 — 블록별 정밀 기술 문서)

  **블록 내 content_type 분포**:
  - 이 블록의 hands-on 차시: {해당 블록의 hands-on 세션 목록}
  - 이 블록의 concept 차시: {해당 블록의 concept 세션 목록}
  - 이 블록의 activity 차시: {해당 블록의 activity 세션 목록}
  - **hands-on 차시에서는 I Do에 fenced code block 필수**

  **스키마 참조**: `.claude/templates/input-schema-script.json` (script_config 필드 의미·유효값 이해용)
  **템플릿**: `.claude/templates/script-template.md`
  **산출물**: `{output_dir}/session_D{day}-{num}.md` (블록 내 세션 수만큼 각각 Write)

  **제약**: 도구 Read, Write, Glob만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**블록별 미니 검증** (각 블록 Part 완료 후 오케스트레이터 수행):
1. Glob `{output_dir}/session_D{day}-*.md` → 해당 블록의 차시 파일들 존재 확인
2. 각 `session_*.md` Read → Gagne 체크 ≥ 7/9 확인
3. 각 `session_*.md`의 시간 합산이 배정 시간과 일치 확인

**GATE-6** (전체 Part 완료 후 — 모든 항목 PASS 시에만 Phase 7 진행):

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G6-1 | `_header.md` 존재 | Glob `{output_dir}/_header.md` | 1개 | 중단 |
| G6-2 | `_footer.md` 존재 | Glob `{output_dir}/_footer.md` | 1개 | 중단 |
| G6-3 | `session_D*.md` 파일 수 == len(sessions[]) | Glob `{output_dir}/session_D*.md` + 카운트 | 일치 | 중단 |
| G6-4 | 각 session Gagne 체크 ≥ 7/9 | Read 각 `session_*.md` | ≥ 7/9 | 중단 |
| G6-5 | 각 session 시간 합산 == 배정 시간 | Read 각 `session_*.md` | 일치 | 중단 |

**GATE-6 전체 통과 → Phase 7 진행 허용**

### Phase 7: 블록별 품질 검토 → review-agent (블록 범위 검증 + 재작성 루프)

> **[MANDATORY] `blocks[]` 배열의 모든 블록에 대해 Step 7-1 → 7-2 → 7-3을 전수 실행한다. 블록 생략 불가.**

**사전 처리** (오케스트레이터 수행):

1. Glob `{output_dir}/session_D*.md` → 차시 파일들 존재 확인 (Phase 6 산출물)
2. `{output_dir}/_header.md`, `{output_dir}/_footer.md` 존재 확인
3. `{output_dir}/input_data.json` Read → `source_outline.outline_path`, `source_outline.architecture_path` 추출
4. Phase 6에서 결정한 `blocks[]`, `sessions[]` 배열 재사용

**블록별 검토 루프** (오케스트레이터가 `blocks[]`의 **각 블록**에 대해 순차 실행):

#### Step 7-1: 블록별 사전 처리 (Context7 검증 기준 수집)

해당 블록에 content_type == "hands-on" 차시가 1개 이상인 경우:
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

review-agent를 호출하고, 반환 후 `_review_block_{block_id}.md` 존재를 **즉시** Glob으로 확인한다.
파일이 없으면 해당 블록에서 중단하고 사용자에게 보고한다.

```
subagent_type: review-agent
prompt: |
  블록 {block_id} 세션들의 품질을 검토하세요.

  **지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-review.md`를 로드하여
  **블록별 검토 모드**를 따르세요.

  **검증 대상**: `{output_dir}/session_D{day}-{num}.md` (해당 블록의 차시 파일들: {session_list})
  **검증 범위**: {block_id} ({session_count}개 세션)

  **검증 기준 (교안)**:
  - `{output_dir}/architecture.md` (Gagne/GRR/발문/전환 설계 기준)
  - `{output_dir}/brainstorm_result.md` (발문/활동/사례/오개념 원본)
  - `{output_dir}/research_deep.md` (확보된 소재, 미해결 항목)
  - `{output_dir}/input_data.json` (교수 모델, 시간 비율, 설정값)
  - `{output_dir}/context7_verify_{block_id}.md` (존재 시 — 코드 API 공식 시그니처 검증 기준)

  **검증 기준 (구성안)**:
  - `{source_outline.outline_path}` (CLO/SLO 원본)
  - `{source_outline.architecture_path}` (정렬 맵, 평가, 시간 예산 원본)

  **스키마 참조**: `.claude/templates/input-schema-script.json` (script_config 필드 의미·유효값 이해용)

  **산출물**: `{output_dir}/_review_block_{block_id}.md`

  **검증 영역 (블록 범위, ~44항목)**:
  1. 교수설계 프레임워크 (G-1~G-8): Gagne 9사태, GRR 4단계, 2-레이어, Think-Aloud, 15분 분절
  2. 발문/평가/흐름 (P-1~P-7): Bloom's 발문 수준, CMU 3점, 차시 간 전환
  3. 시간 배분 (T-1~T-8): 교시 시간 합산, 비율 준수, GRR 시간, 시간큐
  4. 콘텐츠 정확성 (C-1~C-12): Anti-Hallucination, CLO/SLO 일치, 소재 근거, 코드 API 정확성(C-10), 코드 콘텐츠 밀도(C-11), 플레이스홀더 잔존(C-12)
  5. 교안 실행 품질 (N-1~N-9): 발화문 자연성, 활동 3요소

  **판정 기준**: PASS (Major=0, Minor≤3) / CONDITIONAL PASS (Major=0, Minor≥4) / REVISION REQUIRED (Major≥1)

  **제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

#### Step 7-3: 판정 분기

1. `_review_block_{block_id}.md` Read → 판정 결과 추출
2. **PASS 또는 CONDITIONAL PASS** → 다음 블록으로 진행
3. **REVISION_REQUIRED** → writer-agent 재작성 1회 → review-agent 재검토 1회:
   - 재검토 후에도 REVISION_REQUIRED → 사용자에게 보고 후 **중단**

**REVISION_REQUIRED 시 재작성 호출**:

```
subagent_type: writer-agent
prompt: |
  블록 {block_id}의 Major 위반을 수정하여 해당 세션만 재작성하세요.

  **지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-write.md`를 로드하여 **revision 모드**를 따르세요.

  **모드**: revision
  **범위**: 블록 {block_id} ({session_list})
  **수정 가이드**: `{output_dir}/_review_block_{block_id}.md`

  **입력**:
  - {output_dir}/session_D{day}-{num}.md (해당 블록의 차시 파일들)
  - {output_dir}/_review_block_{block_id}.md (Major 위반 목록 + 수정 가이드)
  - {output_dir}/architecture.md
  - {output_dir}/brainstorm_result.md
  - {output_dir}/input_data.json

  **산출물**: `{output_dir}/session_D{day}-{num}.md` (위반 차시만 전체 Write로 교체)

  **제약**: 해당 블록의 위반 차시만 수정. 다른 차시 파일 수정 금지. Agent 중첩 금지.
```

#### GATE-7 (모든 블록 완료 후 — 전체 통과 시에만 Phase 8 진행)

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G7-1 | `_review_block_*.md` 파일 수 == len(blocks[]) | Glob + 카운트 | 일치 | 중단 |
| G7-2 | 각 판정 != REVISION_REQUIRED | Read 각 `_review_block_*.md` | 전체 PASS 또는 CONDITIONAL | 중단 |
| G7-3 | blocks[] 전체 블록 ID가 파일명에 매칭 | Glob 패턴 대조 | 전체 일치 | 중단 |

**GATE-7 전체 통과 → Phase 8 진행 허용**

---

### Phase 8: 통합 + 최종 검토 → review-agent (구조 완전성 + 블록 간 일관성)

> **[MANDATORY] Step 8-1 → 8-2 → 8-3 순서 실행, 생략 불가. 각 Step의 GATE를 통과해야 다음 Step 진행.**

**사전 처리** (오케스트레이터 수행):
- 모든 `_review_block_*.md` Read → 블록별 판정 요약 수집

#### Step 8-1: 1차 병합 (session → block)

오케스트레이터가 직접 Read+Write로 수행:
1. 각 블록에 대해 해당 `session_D{day}-{num}.md` 파일들을 Read
2. Day 헤딩(`### Day {N}: {테마}`)을 삽입하고 세션들을 순서대로 결합
3. `block_D{day}_{AM|PM}.md`로 Write (블록 헤더 + 세션 교안 + 블록 요약)

**GATE-8-1**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G8-1a | `block_*.md` 파일 수 == len(blocks[]) | Glob + 카운트 | 일치 | 중단 |
| G8-1b | 각 block 파일 비어있지 않음 | Read 각 `block_*.md` | 내용 존재 | 중단 |

**GATE-8-1 실패 → Step 8-2 진행 불가**

#### Step 8-2: 2차 병합 (block → lecture_script.md)

오케스트레이터가 직접 Read+Write로 수행:
1. `_header.md` Read → 상단 (메타데이터 + §1~§3 + §4 Day 헤딩 골격)
2. `block_*.md` 파일들을 블록 순서대로 Read → §4 본문
3. `_footer.md` Read → 하단 (§5~§8)
4. `lecture_script.md`에 Write — script-template.md 구조의 완전한 단일 문서

**GATE-8-2**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G8-2a | `lecture_script.md` 존재 | Glob `{output_dir}/lecture_script.md` | 1개 | 중단 |
| G8-2b | §1~§8 헤더 존재 | Grep `lecture_script.md`에서 `§1`~`§8` 패턴 | 8개 섹션 헤더 | 중단 |

**GATE-8-2 실패 → Step 8-3 진행 불가**

#### Step 8-3: 통합 검토 (review-agent)

```
subagent_type: review-agent
prompt: |
  lecture_script.md의 전체 통합 품질을 최종 검토하세요.

  **지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고
  라우팅에 따라 `script-review.md`를 로드하여
  **통합 검토 모드**를 따르세요.

  **검증 대상**: `{output_dir}/lecture_script.md` (전체)
  **블록별 검토 결과**: `{output_dir}/_review_block_*.md`

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
  1. 구조 완전성 (S-1~S-7): §1~§8 전체 존재, 표기법, 서브섹션, 차시 커버리지
  2. 블록 간 전환 일관성: AM→PM, Day간 전환 문구 자연스러움
  3. SLO 커버리지 전체 확인: 모든 SLO가 §4에서 다뤄지는지
  4. 형성평가 집계 정합: §5 집계 = §4 인라인 합계
  5. 발문 모음 정합: §6 발문 = §4 인라인 발문
  6. 용어/표기 통일: 전체 문서 일관성

  **판정 기준**: PASS (Major=0, Minor≤3) / CONDITIONAL PASS (Major=0, Minor≥4) / REVISION REQUIRED (Major≥1)

  **제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
```

**GATE-8-3**:

| ID | 검증 내용 | 방법 | 기준 | 실패 시 |
|----|----------|------|------|--------|
| G8-3a | `quality_review.md` 존재 | Glob `{output_dir}/quality_review.md` | 1개 | 중단 |
| G8-3b | 판정 결과 추출 가능 | Read `quality_review.md` → 판정 추출 | PASS/CONDITIONAL/REVISION 중 하나 | 중단 |
| G8-3c | `block_*.md` 파일 존재 유지 | Glob `{output_dir}/block_*.md` | len(blocks[])개 | 중단 |

**GATE-8-3 통과 후 판정에 따라 후속 조치 안내**:
- **PASS**: "교안 품질 검토 통과. lecture_script.md가 확정되었습니다."
- **CONDITIONAL PASS**: "Minor 위반 {N}개 발견. quality_review.md를 확인하여 부분 수정을 권고합니다."
- **REVISION REQUIRED**: "Major 위반 {N}개 발견. quality_review.md의 수정 가이드에 따라 해당 섹션을 재작성해야 합니다."

## 산출물 (02_script/)

```
lectures/YYYY-MM-DD_{강의명}/02_script/
├── input_data.json                 # Phase 1: 구성안 로드 + 교수법 선택 + 자동 결정
├── research_exploration.md         # Phase 2: 탐색적 리서치
├── brainstorm_result.md            # Phase 3: 브레인스토밍
├── research_deep.md                # Phase 4: 심화 리서치
├── context7_reference.md           # Phase 5: 기술 문서 참조 (기술 교육 시)
├── architecture.md                 # Phase 5: 교안 구조 설계
├── _header.md                      # Phase 6: §1~§3 머리말 (Part 0)
├── session_D1-1.md ~ D{N}-{M}.md  # Phase 6: 차시별 독립 교안 ★ (Part 1~B)
├── _footer.md                      # Phase 6: §5~§8 꼬리말 (Part N)
├── context7_block_{block_id}.md    # Phase 6: 블록별 정밀 기술 문서 (기술 교육 시)
├── context7_verify_{block_id}.md   # Phase 7: 블록별 코드 검증 기준 (기술 교육 시)
├── _review_block_{block_id}.md     # Phase 7: 블록별 검토 결과 (동적 생성)
├── block_D{day}_{AM|PM}.md        # Phase 8: 블록별 통합 (1차 병합) ★
├── lecture_script.md               # Phase 8: 최종 통합 (2차 병합) ★
└── quality_review.md               # Phase 8: 최종 품질 검토 ★
```
