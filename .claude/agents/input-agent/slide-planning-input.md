# 슬라이드 기획 입력 수집 (Step 0~3)

### 질문 흐름

```
[시작]
  │
  ├── Step 0: 이전 산출물 탐색 + 로드
  │     ├─ lectures/*/02_script/lecture_script.md 스캔 → 교안 완료 폴더 목록
  │     ├─ 폴더 1개: 자동 선택 확인 / 2개+: 사용자 선택
  │     ├─ architecture.md(02_script) + input_data.json(02_script) 로드
  │     ├─ 01_outline/input_data.json 로드 (존재 시, tone_examples 등)
  │     ├─ architecture.md §1-2 차시 테이블 + §2-3 GRR 배분 파싱 → session 매니페스트
  │     ├─ session_D{day}-{session_num}.md 파일 존재 검증 (Glob)
  │     └─ 03_slide_plan/ 폴더 생성
  │
  ├── Step 1: 자동 결정 (P1~P5 — 질문 없음, 전부 자동 추론)
  │     ├─ P1: 슬라이드 도구 → content_type + lab_environment 분석
  │     ├─ P2: 디자인 톤 → tone 상속
  │     ├─ P3: 기획 범위 → 기본값 "all"
  │     ├─ P4: 정보 밀도 → "standard" (25-55줄) 고정
  │     └─ P5: 슬라이드 수 → GRR 기반 1차 동적 산출 (session 매니페스트에 포함)
  │
  ├── Step 2: 전체 설정 요약 + AskUserQuestion 1회
  │     └─ P1~P5 요약 + session 매니페스트(예상 장수 포함) 출력 → 확인/변경
  │
  └── Step 3: input_data.json 생성 → Phase 2로 전달
```

**총 AskUserQuestion 호출**: 1회 확인용 (폴더 선택 포함 시 최대 2회)

### Step 0: 이전 산출물 탐색 + 로드

#### 탐색 로직

```
1. Glob으로 `lectures/*/02_script/lecture_script.md` 패턴 검색
2. 결과 0개 → 에러: "교안이 없습니다. /lecture-script를 먼저 실행하세요." → 중단
3. 결과 1개 → 자동 선택 후 확인:
   "'{폴더명}'의 교안을 사용합니다. 맞습니까?"
   → Yes: 진행 / No: Other로 경로 직접 입력
4. 결과 2개+ → 선택 질문:
   "어떤 강의의 슬라이드를 기획하시겠습니까?"
   → 폴더명 목록 (최신순 정렬)
```

#### 로드 대상

| 파일 | 용도 | 실패 시 |
|------|------|---------|
| `02_script/architecture.md` | 차시 구조, GRR 배분, content_type → session 매니페스트 | 에러 → 중단 |
| `02_script/input_data.json` | 기존 설정 복사 기반 | 에러 → 중단 |
| `01_outline/input_data.json` | tone_examples, lab_environment 원본 참조 | 경고 → 계속 |

#### Session 매니페스트 생성

1. `architecture.md` §1-2 차시 테이블 파싱 → (day, session_num, title, slo, blooms, content_type) 추출
2. `architecture.md` §2-3 GRR 배분 테이블 파싱 → (i_do, we_do, ydt, yda) 시간(분) 추출
3. 파일 경로: `02_script/session_D{day}-{session_num}.md` → Glob으로 존재 확인
4. GRR 기반 1차 슬라이드 수 산출 (P5 알고리즘 적용)
5. 매니페스트 배열: 각 session에 `(session_id, file_path, title, duration_min, slo, blooms_level, content_type, grr, estimated_slides_grr)` 저장

#### 폴더 생성

선택된 강의 루트 폴더 아래 `03_slide_plan/` 폴더를 생성한다.

### Step 1: 전체 자동 결정 (P1~P5 — 질문 없음)

Step 0에서 로드한 데이터를 기반으로 P1~P5 전부를 자동 결정한다. 사용자 질문 없음.

#### P1. 슬라이드 도구 → content_type + lab_environment 분석

```
hands_on_sessions = session 매니페스트에서 content_type == "hands-on" 세션 수
total_sessions = 전체 세션 수
hands_on_ratio = hands_on_sessions / total_sessions

lab_environment = 01_outline/input_data.json의 lab_environment 필드

IF lab_environment != null AND hands_on_ratio >= 0.30:
  → "slidev" (코드 하이라이트, 라이브 코딩 지원)
ELSE:
  → "marp" (범용, AI 생성 용이)
```

추론 근거를 `slide_tool_reasoning`에 기록한다.

#### P2. 디자인 톤 → tone 상속

```
tone_examples = 01_outline/input_data.json의 tone_examples 필드
tone = 02_script/input_data.json의 tone 필드

IF tone_examples 존재 OR (tone에 "비유" 포함):
  → "friendly_visual" (친근한 시각 중심)
ELSE:
  → "professional" (전문적)
```

`01_outline/input_data.json` 로드 실패 시 → `02_script/input_data.json`의 tone만으로 판단.

#### P3. 기획 범위 → `all` (기본값)

교안의 모든 Day에 대해 슬라이드를 기획한다. 기본값: `"all"`.

- session 매니페스트에서 Day 목록과 세션 수를 파싱하여 `scope.days` 배열에 저장
- 예: `["Day 1", "Day 2", "Day 3"]`

#### P4. 정보 밀도 → `standard` (25-55줄) 고정

슬라이드 기획 명세의 기본 상세도. 고정값.

#### P5. 슬라이드 수 — GRR 기반 1차 동적 산출

session 매니페스트의 각 세션에 대해 GRR 구간별 슬라이드 밀도를 적용하여 1차 예상 장수를 산출한다.

##### GRR 구간별 슬라이드 밀도 (장/분)

| GRR 구간 | concept | hands-on | activity |
|----------|---------|----------|----------|
| 도입 (5분) | 0.8 | 0.8 | 0.8 |
| I Do | 1.2 | 1.0 | 0.8 |
| We Do | 0.6 | 0.7 | 0.6 |
| You Do Together | 0.3 | 0.3 | 0.4 |
| You Do Alone | 0.2 | 0.3 | 0.3 |
| 정리 (15분) | 0.5 | 0.5 | 0.5 |

##### 산출 공식

```
estimated_slides_grr = round(
    도입_시간(5) × 도입_밀도[content_type]
  + i_do × i_do_밀도[content_type]
  + we_do × we_do_밀도[content_type]
  + ydt × ydt_밀도[content_type]
  + yda × yda_밀도[content_type]
  + 정리_시간(15) × 정리_밀도[content_type]
)
```

- 도입/정리 시간은 architecture.md에서 파싱 가능 시 실제 값 사용, 불가 시 기본값(도입 5분, 정리 15분)
- content_type이 매니페스트에 없으면 `concept` 기본값 적용
- 각 session의 `estimated_slides_grr`을 매니페스트에 저장
- 전체 합계를 `slide_config.estimated_slides.total`에 저장

##### 2단계 병합 예측

1차 GRR 기반 예측은 Phase 1에서 산출. Phase 3(구조 설계)에서 콘텐츠 기반 2차 예측 후 가중 평균으로 최종 결정.

```
최종_슬라이드_수 = round(0.6 × GRR_estimate + 0.4 × Content_estimate)
```

Phase 1에서는 GRR 기반 1차 값만 기록하고, `merge_formula` 필드에 공식을 명시한다.

### Step 2: 전체 설정 요약 + 사용자 확인 — AskUserQuestion **반드시** 1회

**[MUST]** Step 1에서 자동 결정한 P1~P5 전체를 요약하여 사용자에게 **반드시** 확인받는다. 이 단계를 생략하면 안 된다.

#### 요약 형식

```
📋 슬라이드 기획 설정 요약 (교안 자동 분석 결과)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• 슬라이드 도구(P1): {결과} — 근거: {근거}
• 디자인 톤(P2): {결과} — 근거: {근거}
• 기획 범위(P3): 전체 ({Day 목록}, {N}개 session)
• 정보 밀도(P4): standard (25-55줄/장)
• 예상 슬라이드 수(P5): 총 {합계}장 (1차 GRR 기반, Phase 3에서 콘텐츠 기반 2차 보정)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📑 Session 매니페스트:
| # | Session | 제목 | 유형 | GRR(I/W/YT/YA) | 예상 장수 |
|---|---------|------|------|----------------|----------|
| 1 | D1-1 | 오리엔테이션... | activity | 12/10/5/3 | 30장 |
| ... |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

위 요약을 AskUserQuestion의 description에 포함하여 확인 질문을 보낸다.

#### 확인 질문 스키마

```json
{
  "question": "위 설정으로 슬라이드 기획을 진행할까요?",
  "header": "설정 확인",
  "multiSelect": false,
  "options": [
    { "label": "진행", "description": "위 설정 그대로 슬라이드 기획 시작" },
    { "label": "변경 필요", "description": "수정할 항목을 Other에 입력 (예: 'P1: slidev', 'P3: Day 1만')" }
  ]
}
```

- **"진행"** 선택 시 → Step 3으로 진행
- **"변경 필요"** 또는 **Other** 선택 시 → 입력된 변경 사항을 해당 항목에 반영 후 Step 3 진행
  - 변경 형식: `"항목: 값"` (예: `"P1: slidev"`, `"P3: Day 1, 3"`)
  - 변경된 항목만 갱신, 나머지는 자동 결정값 유지
  - P3 변경 시 → session 매니페스트 필터링 + P5 재계산

### Step 3: input_data.json 생성

1. `02_script/input_data.json`의 **기반 필드를 복사** (topic, target_learner, learning_goals, format, schedule, keywords 등)
2. `slide_config` 객체 추가 (P1~P5 결과)
3. `session_manifest` 배열 추가 (Step 0에서 생성한 매니페스트)
4. `source_script` 객체 추가 (교안 파일 경로)
5. `03_slide_plan/input_data.json`으로 Write

스키마 참조: `.claude/templates/input-schema-slide-planning.json`

### 엣지 케이스 처리

| 상황 | 처리 |
|------|------|
| 교안 0개 | 에러 + `/lecture-script` 먼저 실행 안내 → 중단 |
| `lecture_script.md` 없음 | 에러: "교안이 완성되지 않았습니다." → 중단 |
| `architecture.md` 없음 | 에러 → 중단 (매니페스트 생성 불가) |
| session 파일 일부 누락 | 경고 → 존재하는 session만 매니페스트 포함 |
| `03_slide_plan/` 이미 존재 | 덮어쓰기 확인 → Yes: 계속 / No: 중단 |
| P3 변경 (Day 지정) | 해당 Day session만 포함, P5 재계산 |
| `01_outline/input_data.json` 없음 | 경고 → `02_script/input_data.json`만으로 진행 |
| content_type 미식별 | `concept` 기본값 적용 |
| GRR 시간 파싱 실패 | 교수 모델별 기본 비율 적용 |
