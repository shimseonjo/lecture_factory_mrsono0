# 강의교안 입력 수집 (S0~S6)

### 질문 흐름

```
[시작]
  │
  ├── Step 0: 이전 산출물 탐색 + 로드
  │     ├─ lectures/ 스캔 → 구성안 완료 폴더 목록 추출
  │     ├─ 폴더 1개: 자동 선택 확인 / 2개+: 사용자 선택
  │     ├─ lecture_outline.md + input_data.json + architecture.md 로드
  │     └─ 02_script/ 폴더 생성
  │
  ├── Step 1: 자동 결정 (S0~S6 — 질문 없음, 전부 자동 추론)
  │     ├─ S0: 기본값 "전체 차시"
  │     ├─ S1a: architecture.md 활동 유형 키워드 분석 → 교수 모델 추론
  │     ├─ S1b: architecture.md 활동 유형 키워드 분석 → 활동 전략 추론
  │     ├─ S2~S4: 기존 자동 결정 로직
  │     ├─ S4b: teaching_model → instructional_model_map 자동 파생
  │     └─ S5~S6: 기존 자동 결정 로직
  │
  ├── Step 2: 전체 설정 요약 + 사용자 확인 — AskUserQuestion 1회
  │     └─ S0~S6 전체 요약 출력 → "이 설정으로 진행할까요?" 확인
  │
  └── Step 3: input_data.json 생성 → Phase 2로 전달
```

**총 AskUserQuestion 호출**: 1회 확인용 (폴더 선택 포함 시 최대 2회)

### Step 0: 이전 산출물 탐색 + 로드

#### 탐색 로직

```
1. Glob으로 `lectures/*/01_outline/lecture_outline.md` 패턴 검색
2. 결과 0개 → 에러: "구성안이 없습니다. /lecture-outline을 먼저 실행하세요." → 중단
3. 결과 1개 → 자동 선택 후 확인:
   "'{폴더명}'의 구성안을 사용합니다. 맞습니까?"
   → Yes: 진행 / No: Other로 경로 직접 입력
4. 결과 2개+ → 선택 질문:
   "어떤 강의의 교안을 작성하시겠습니까?"
   → 폴더명 목록 (최신순 정렬)
```

#### 로드 대상

| 파일 | 용도 | 실패 시 |
|------|------|---------|
| `01_outline/lecture_outline.md` | 차시 구조, SLO, 학습자 프로파일 참조 | 에러 → 중단 |
| `01_outline/input_data.json` | 기존 Q1~Q14 데이터 복사 기반 | 에러 → 중단 |
| `01_outline/architecture.md` | S1a/S1b 추론, S3 형성평가 추출, S6 Bloom's 매핑 | 경고 → 계속 (자동 추론 건너뜀) |

#### 폴더 생성

선택된 강의 루트 폴더 아래 `02_script/` 폴더를 생성한다.

### Step 1: 전체 자동 결정 (S0~S6 — 질문 없음)

Step 0에서 로드한 데이터를 기반으로 S0~S6 전부를 자동 결정한다. 사용자 질문 없음.

#### S0. 교안 작성 범위 → `all` (전체 차시) 기본값

구성안의 모든 Day에 대해 교안을 작성한다. 기본값: `"all"`.

- `lecture_outline.md`에서 Day 목록과 차시 수를 파싱하여 `scope.days` 배열에 저장
- 예: `["Day 1", "Day 2", "Day 3"]`

#### S1a. 교수 모델 → architecture.md 자동 추론 (§추론 알고리즘 참조)

`architecture.md` §4-2 활동 유형 키워드를 카운팅하여 교수 모델을 자동 결정한다.
추론 알고리즘은 아래 "S1a/S1b 자동 추론 알고리즘" 섹션을 따른다.

- 추론 성공 시: 결과를 `teaching_model`에 저장 + 추론 근거 기록
- 추론 실패 시 (architecture.md 없음 또는 스코어 0): pedagogy 폴백 → 그래도 실패 시 `"mixed"` 기본값

#### S1b. 활동 전략 → architecture.md 자동 추론 (§추론 알고리즘 참조)

`architecture.md` §4-2 활동 유형 키워드에서 활동 전략을 자동 추출한다.
추론 알고리즘은 아래 "S1a/S1b 자동 추론 알고리즘" 섹션을 따른다.

- 추출된 전략이 0개면 기본값 `["individual_practice", "group_activity"]`

#### S2~S6: 기존 자동 결정 로직

아래 항목을 구성안 데이터에서 자동 결정한다.

#### S2. 스크립트 상세도 → `full_script` (L5) 고정

초보 강사가 교안(강의 내용)과 대본(강사 발화)만 보면서 강의할 수 있도록 최대 상세도 고정.

#### S3. 형성평가 → architecture.md §3-2에서 자동 추출

```
추출 알고리즘:
1. architecture.md의 "형성평가 계획" 테이블 파싱
2. 각 행에서 (시점, 유형, 대상 SLO, 방법, 소요시간) 추출
3. 유형 분류:
   - "체크포인트", "점검표", "퀴즈" → sectional_check
   - "Exit Ticket", "에세이", "작문" → exit_ticket
   - "동료 비교", "피어 티칭", "데모" → practice_integrated
4. 가장 빈번한 유형을 primary_type으로 설정
5. SLO별 평가 커버리지 검증 (모든 SLO에 1개+ 평가)
```

architecture.md가 없으면 → `primary_type: "sectional_check"` 기본값 적용.

#### S4. 시간 비율 → S1a 교수 모델에서 자동 파생

| 교수 모델 | 도입 | 전개 | 정리 |
|----------|------|------|------|
| direct_instruction | 10 | 60 | 30 |
| pbl | 10 | 75 | 15 |
| flipped | 5 | 80 | 15 |
| mixed | 10 | 70 | 20 |

#### S4b. 교수설계 모델 매핑 → S1a 교수 모델에서 자동 파생

S1a에서 결정된 `teaching_model`을 기반으로 `instructional_model_map`을 자동 생성한다.

| teaching_model | primary_model | secondary_model | grr_focus | bloom_question_pattern |
|---------------|--------------|----------------|-----------|----------------------|
| direct_instruction | Hunter_6step | Gagne | i_do_we_do_you_do | L1-L2→L2-L3→L3-L4→L2-L3 |
| pbl | PBL_6step | Gagne | you_do_together | L4-L5→L3-L4→L5-L6→L5-L6 |
| flipped | Before_During_After | Gagne | we_do_you_do_together | L2-L3→L3-L4→L4-L5→L5 |
| mixed | Hunter_6step | Gagne | i_do_we_do_you_do | L1-L2→L2-L3→L3-L4→L2-L3 |

`mixed`일 경우 `mixed_model_map`의 Day별 모델에 따라 해당 Day의 매핑을 개별 적용한다. 기본 매핑은 `direct_instruction` 기준.

#### S5. 참고자료 → 구성안 상속 + 인터넷 리서치 기본

```
1. 구성안 input_data.json의 reference_sources.local_folders 복사
2. 구성안 input_data.json의 reference_sources.notebooklm_urls 복사
3. web_research = true (기본 활성화)
```

구성안에 참고자료가 없으면 인터넷 리서치만 활성화.

#### S6. Bloom's 발문 + Gagne 9사태 → 자동 적용

**Bloom's 발문**: architecture.md §4-2 차시 테이블의 "Bloom's" 열에서 차시별 수준 추출 → 교수 모델별 매핑 테이블 적용.

| 수업 단계 | direct_instruction | pbl | flipped |
|----------|-------------------|-----|---------|
| 도입 | L1~L2 | L4~L5 | L2~L3 |
| 전개 초반 | L2~L3 | L3~L4 | L3~L4 |
| 전개 후반 | L3~L4 | L5~L6 | L4~L5 |
| 정리 | L2~L3 | L5~L6 | L5 |

**Gagne 9사태**: `checklist` 고정 (Phase 7 review-agent가 누락 검증).

architecture.md가 없으면 → Bloom's 매핑 건너뜀, Phase 6 writer-agent가 SLO 기반 자체 판단.

### S1a/S1b 자동 추론 알고리즘

#### 1차: architecture.md 차시 테이블 분석 (우선)

`architecture.md` §4-2 차시별 상세 배치의 **"활동 유형"** 열에서 키워드를 카운팅한다.

**키워드 → 교수 모델 스코어**:

| 키워드 | 스코어 |
|--------|--------|
| `강의`, `시범`, `안내 실습`, `탐색 실습`, `비교 실험`, `비교 체험`, `비교 실습` | direct_instruction +1 |
| `문제 해결`, `탐구`, `미니 프로젝트`, `갤러리 워크`, `동료 평가`, `발표` | pbl +1 |
| `사전학습`, `반전`, `그룹 토론` | flipped +1 |
| `토론`, `체크리스트`, `Q&A`, `복습`, `정리` | 중립 (카운팅 제외) |

**결정 규칙**:
```
max_score = max(direct_score, pbl_score, flipped_score)
total = direct_score + pbl_score + flipped_score
ratio = max_score / total (total > 0일 때)

if total == 0: → 2차 추론(pedagogy)으로 폴백
elif ratio >= 0.50: → 최고 스코어 모델 결정
else: → "mixed" 결정
```

**키워드 → 활동 전략(S1b)**:

| 키워드 | 전략 |
|--------|------|
| `실습`, `안내 실습`, `탐색 실습` | individual_practice |
| `그룹`, `협업`, `페어`, `갤러리 워크` | group_activity |
| `토론`, `발문`, `Q&A` | discussion |
| `프로젝트`, `미니 프로젝트`, `산출물` | project |

추출된 전략이 0개면 기본값 `["individual_practice", "group_activity"]`.

#### 2차: pedagogy 텍스트 폴백

architecture.md가 없거나 1차 스코어가 모두 0일 때, `input_data.json`의 `pedagogy` 필드에서 추론:

| 우선순위 | 조건 | S1a |
|---------|------|-----|
| 1 | `"pbl"` 또는 `"문제기반"` 또는 `"프로젝트 기반"` | `pbl` |
| 2 | `"플립"` 또는 `"flipped"` 또는 `"사전학습"` | `flipped` |
| 3 | `"직접교수"` 또는 `"direct instruction"` 또는 `"강의식"` | `direct_instruction` |
| 4 | 위 모두 없음 | `mixed` 기본값 |

S1b pedagogy 폴백:

| 조건 | 전략 |
|------|------|
| `"실습"` 또는 `"hands-on"` | individual_practice |
| `"협업"` 또는 `"팀"` 또는 `"그룹"` | group_activity |
| `"토론"` 또는 `"발문"` | discussion |
| `"프로젝트"` 또는 `"산출물"` | project |

#### 추론 충돌 처리

1차(architecture.md)와 2차(pedagogy) 결과가 불일치하면:
- **1차 결과를 우선** 적용 (실제 차시 구조에 기반)
- Step 2 요약에 부기: "차시 구조 분석: {1차 결과} / 교수 전략 텍스트: {2차 참고}"

### Step 2: 전체 설정 요약 + 사용자 확인 — AskUserQuestion **반드시** 1회

**[MUST]** Step 1에서 자동 결정한 S0~S6 전체를 요약하여 사용자에게 **반드시** 확인받는다. 이 단계를 생략하면 안 된다.
사용자가 S0(작성 범위)를 변경하거나, S1a(교수 모델)를 수정할 수 있도록 "변경 필요" 옵션을 제공해야 한다.

#### 요약 형식

```
📋 교안 설정 요약 (구성안 자동 분석 결과)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• 작성 범위(S0): 전체 차시 ({Day 목록})
• 교수 모델(S1a): {추론 결과} — 근거: {추론 근거 요약}
• 활동 전략(S1b): {추론 결과 목록} — 근거: {키워드 요약}
• 스크립트 상세도(S2): 완전 스크립트 (L5) — 초보 강사용
• 형성평가(S3): {S3 결과} — architecture.md 기반
• 시간 비율(S4): 도입 {X}% / 전개 {Y}% / 정리 {Z}%
• 교수설계 모델(S4b): {primary_model} + {secondary_model} — GRR: {grr_focus}
• 참고자료(S5): 로컬({N}개) + NotebookLM({M}개) + 인터넷 리서치
• Bloom's 발문(S6): 차시별 자동 매핑
• Gagne 9사태(S6): 체크리스트 (Phase 7 검증)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

위 요약을 AskUserQuestion의 description에 포함하여 확인 질문을 보낸다.

#### 확인 질문 스키마

```json
{
  "question": "위 설정으로 교안 작성을 진행할까요?",
  "header": "설정 확인",
  "multiSelect": false,
  "options": [
    { "label": "진행", "description": "위 설정 그대로 교안 작성 시작" },
    { "label": "변경 필요", "description": "수정할 항목을 Other에 입력 (예: 'S0: Day 1만', 'S1a: PBL')" }
  ]
}
```

- **"진행"** 선택 시 → Step 3으로 진행
- **"변경 필요"** 또는 **Other** 선택 시 → 입력된 변경 사항을 해당 항목에 반영 후 Step 3 진행
  - 변경 형식: `"항목: 값"` (예: `"S0: Day 1, 3"`, `"S1a: PBL"`, `"S1b: 개인 실습, 프로젝트"`)
  - 변경된 항목만 갱신, 나머지는 자동 결정값 유지
  - S1a 변경 시 → S4(시간 비율), S4b(교수설계 모델 매핑), S6(Bloom's 매핑)도 연쇄 재계산

### Step 3: input_data.json 생성

1. 구성안 `01_outline/input_data.json`의 **전체 필드를 복사**
2. `script_config` 객체 추가 (S0~S6 결과)
3. `source_outline` 객체 추가 (구성안 파일 경로)
4. `02_script/input_data.json`으로 Write

스키마 참조: `.claude/templates/input-schema-script.json`

### 엣지 케이스 처리

| 상황 | 처리 |
|------|------|
| 구성안 0개 | 에러 + `/lecture-outline` 먼저 실행 안내 → 중단 |
| `lecture_outline.md` 없음 | 에러: "구성안이 완성되지 않았습니다." → 중단 |
| `architecture.md` 없음 | 경고 → S1a/S1b pedagogy 폴백 적용, S3 기본값 `sectional_check`, S6 Bloom's 건너뜀 |
| S1a 추론 실패 (1차+2차 모두) | `mixed` 기본값 적용 + Step 2 요약에 "추론 불가, 기본값 적용" 명시 |
| S1b 추론 결과 0개 | 기본값 `["individual_practice", "group_activity"]` 적용 |
| `02_script/` 이미 존재 | 덮어쓰기 확인 → Yes: 계속 / No: 중단 |
| architecture.md에 형성평가 섹션 없음 | S3 기본값 `sectional_check` 적용 |
| architecture.md에 Bloom's 열 없음 | S6 Bloom's 매핑 건너뜀 |
| Step 2에서 "변경 필요" 선택 | 변경 항목만 갱신, 연쇄 항목(S4/S6) 재계산 |
