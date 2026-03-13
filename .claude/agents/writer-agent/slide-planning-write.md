# 슬라이드 기획안 작성 (Phase 4) 세부 워크플로우

### 설계 원칙

| 차원 | 교안 Phase 6 | 슬라이드 기획 Phase 4 |
|------|------------|---------------------|
| 산출물 성격 | 실행 문서 (강사 대본) | **제작 지시서** (슬라이드 제작 명세) |
| 핵심 단위 | 차시 (50분) | 슬라이드 (1.5~2.5분) |
| 입력 | architecture + brainstorm + research + context7 | architecture §3(슬라이드 구조) + brainstorm + **session 파일** |
| 상세도 | 차시당 80~120줄 | **슬라이드당 25~55줄** (4레이어: CONTENT+VISUAL+SPEAKER_NOTE+IMPL_HINT) |
| 고유 요소 | 발화문, Think-Aloud, 행동지시 | **AE 명세, 시각자료 지시, IMPL_HINT, SPEAKER_NOTE** |
| 분할 | 블록(AM/PM) → 차시별 파일 | **세션별 파일** (`slides_D{day}-{num}.md`) |
| 소비자 | 강사 | `/slide-generation` 워크플로우 |

**5대 핵심 원칙**:

1. **GAIDE 5단계 적용**: Setup(Step 0) → Draft(Step 1~2) → Core Draft(Step 3) → Macro Refinement(Step 4) → Micro Refinement(Step 5)
2. **변환자 역할**: Architecture의 슬라이드 골격과 Session 파일의 콘텐츠를 **4레이어 슬라이드 명세**로 변환
3. **4레이어 분리**: CONTENT(콘텐츠) / VISUAL(시각) / SPEAKER_NOTE(발표자 노트) / IMPL_HINT(구현 힌트) 시각 구분
4. **입력 충실성**: 11개 데이터 소스의 데이터만 사용, 콘텐츠 창작 금지
5. **1:1 매핑**: architecture.md §3의 각 슬라이드 행을 정확히 1:1로 25~55줄 명세로 확장

### 전체 흐름

```
Step 0: 입력 로드 + 검증 (GAIDE Setup)
  │     architecture.md(§3 핵심) + brainstorm_result.md + input_data.json
  │     + session 파일들 + slide-plan-template.md
  │
  ├── Step 1: §1 기획 개요 + §2 공통 가이드 (GAIDE Draft-1)
  │   └── 기본 정보, 도구 설정, AE 규칙, GRR 시각 밀도, Mayer 원칙
  │
  ├── Step 2: §3 표기법 + 12유형별 레이아웃 가이드 (GAIDE Draft-2)
  │   └── 명세 표기법, 유형별 필수/선택/레이아웃/구현/금지 패턴
  │
  ├── Step 3: §4 세션별 슬라이드 명세 (GAIDE Core Draft) ★ 핵심 (75~80%)
  │   └── architecture.md §3 각 행을 1:1로 25~55줄 명세로 확장
  │       session 파일에서 콘텐츠 추출 → 4레이어 변환
  │
  ├── Step 4: §5 유형 분포 집계 + §6 인터랙션 목록 (GAIDE Macro Refinement)
  │   └── Step 3 내용을 Quick Reference로 집계
  │
  └── Step 5: §7 코드 워크스루 가이드 + §8 제작 참고 (GAIDE Micro Refinement)
      └── 에셋 목록, 디렉티브 레퍼런스, 디자인 톤 가이드
```

### 산출물 목록 (Bottom-Up)

```
{output_dir}/
├── _plan_header.md                    # Phase 4: §1~§3 (Part 0)
├── slides_D1-1.md ~ D{N}-{M}.md      # Phase 4: 세션별 슬라이드 명세 ★
├── _plan_footer.md                    # Phase 4: §5~§8 (Part N)
└── slide_plan.md                      # Phase 4: 오케스트레이터 병합 최종 ★
```

### 분할 작업 모드 (Part Mode)

**분할 판단 기준**: `total_slides` (총 슬라이드 수)

| 조건 | 모드 | Part 수 |
|------|------|---------|
| `total_slides ≤ 80` | 단일 모드 | 1 |
| `total_slides > 80` | 세션별 분할 | sessions + 2 |

#### 세션별 분할 모드

| Part | 범위 | Step | 산출물 |
|------|------|------|--------|
| Part 0/{N} | §1~§3 | Step 0~2 | `_plan_header.md` (Write 신규) |
| Part 1/{N} | §4 세션 1 | Step 3 (해당 세션만) | `slides_D{day}-{num}.md` (Write 신규) |
| ... | §4 세션 K | Step 3 (해당 세션만) | `slides_D{day}-{num}.md` (Write 신규) |
| Part S/{N} | §4 세션 S | Step 3 (마지막 세션) | `slides_D{day}-{num}.md` (Write 신규) |
| Part {N}/{N} | §5~§8 | Step 4~5 | `_plan_footer.md` (Write 신규) |

**예시: 3일×8시간 (24세션 → 26 Part)**

| Part | 범위 | 산출물 |
|------|------|--------|
| Part 0/26 | §1~§3 | `_plan_header.md` |
| Part 1/26 | §4 D1-1 | `slides_D1-1.md` |
| Part 2/26 | §4 D1-2 | `slides_D1-2.md` |
| ... | ... | ... |
| Part 24/26 | §4 D3-8 | `slides_D3-8.md` |
| Part 25/26 | §5~§8 | `_plan_footer.md` |

#### 단일 모드 (total_slides ≤ 80)

모든 세션을 한 번의 호출로 작성. 산출물은 동일하게 `_plan_header.md` + `slides_*.md` + `_plan_footer.md`로 분리.

#### Overlap 컨텍스트 수신 규칙

세션 호출 시 이전 세션의 마지막 슬라이드 내용을 참조하여 전환 일관성을 보장한다.

| 세션 순서 | Overlap 입력 |
|-----------|-------------|
| 첫 번째 세션 | 없음 |
| 두 번째 이후 | 이전 세션 `slides_*.md`의 **마지막 슬라이드 명세** (SLIDE 블록 1개, ~50줄) |

**Overlap 사용 방법**:
- 제목 슬라이드의 SPEAKER_NOTE에 이전 세션 요약 반영
- 도입 슬라이드의 CONTENT에 이전 세션 핵심 연결
- Overlap이 추출 실패하거나 빈 경우: 일반적인 전환 문구로 작성

#### `_plan_header.md` 포함 범위

Part 0에서 Write하는 `_plan_header.md`에는 다음이 포함된다:
- §1 기획 개요 (기본 정보, 세션 매니페스트, 도구 설정)
- §2 공통 가이드 (AE 규칙, GRR 시각 밀도, Mayer 원칙, One Idea Rule)
- §3 표기법 + 12유형별 레이아웃 가이드

#### `_plan_footer.md` 포함 범위

Part {N}에서 Write하는 `_plan_footer.md`에는 다음이 포함된다:
- §5 유형 분포 집계 (전체 유형별, GRR 구간별, 텍스트 전용 비율)
- §6 인터랙션 목록 (세션×슬라이드×Bloom's 집계)
- §7 코드 워크스루 가이드 (코드 슬라이드 목록, 분절 계획)
- §8 제작 참고 (에셋 목록, 디렉티브, 디자인 톤, 검증 체크리스트)

`_plan_footer.md` 작성 시 모든 `slides_*.md` 파일을 Read하여 §4 내용에서 §5~§8을 집계한다.

#### 분할 모드 공통 규칙

- 각 Part는 다른 Part가 작성한 파일을 수정하지 않는다
- 각 `slides_*.md`는 완전한 단일 세션의 슬라이드 명세를 담는 독립 파일이다
- 오케스트레이터가 prompt에 `세션 정보`를 전달하므로, 해당 세션만 작성한다
- **통합(병합)은 writer-agent가 수행하지 않는다** — 오케스트레이터(SKILL.md)가 담당

#### revision 모드 (세션 재작성)

Phase 5 REVISION_REQUIRED 판정 시, 해당 세션 `slides_*.md`를 재작성하는 모드.

| 항목 | 내용 |
|------|------|
| 입력 | `slides_D{day}-{num}.md` (해당 세션 파일), `_review_session_{session_id}.md` (위반 목록 + 수정 가이드) |
| 도구 | Read, Write |
| 산출물 | `slides_D{day}-{num}.md` (해당 세션 파일 전체 Write로 교체) |

**동작**:
1. `_review_session_{session_id}.md` Read → Major 위반 사항 + 수정 가이드 추출
2. 해당 세션의 `slides_*.md` Read → 현재 내용 파악
3. 위반 사항이 있는 슬라이드만 재작성 (다른 세션 파일은 **절대 수정하지 않는다**)
4. Write 도구로 해당 `slides_*.md` 파일 전체를 교체 (Edit가 아닌 **Write**)
5. 재작성 시에도 슬라이드 수·유형·시간 배분 유지, AE 적용률 준수

---

### 금지 사항

**공통**: `shared/prohibited-rules.md`를 Read하여 따른다.

**슬라이드 기획 추가**:
- **슬라이드 수 변경 금지**: architecture.md §3의 슬라이드 수·유형·시간 배분을 변경하지 않는다
- **콘텐츠 창작 금지**: 입력 파일에 없는 내용을 새로 만들지 않는다. session 파일의 발화문·코드·발문을 **변환**만 한다
- **6×6 규칙 위반 금지**: 슬라이드당 시각 요소 6개 이내, 텍스트 6줄 × 6단어 이내
- **유형 변경 금지**: architecture.md §3에서 배정한 슬라이드 유형(12유형)을 변경하지 않는다
- **코드 15줄 초과 금지**: 초과 시 반드시 분절 또는 확대경 패턴 적용

---

### Step 0: 입력 로드 + 검증

| 항목 | 내용 |
|------|------|
| 입력 | `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/input_data.json`, session 파일들 |
| 도구 | Read |
| 산출물 | (내부 컨텍스트 — `_plan_header.md` 또는 `slides_*.md` 또는 `_plan_footer.md`에 반영) |

**동작**:

0. `.claude/templates/input-schema-slide-planning.json` 읽기 — slide_config 필드 구조, session_manifest 스키마 사전 이해

1. 4개 소스를 순서대로 Read:

| 파일 | 핵심 소비 섹션 | 역할 |
|------|-------------|------|
| `architecture.md` | §3(세션별 슬라이드 구조 ★), §5(인터랙션), §7(시간 배분) | 슬라이드 골격 — **변경 불가** |
| `brainstorm_result.md` | §1(AE 구조), §2(시각화), §3(레이아웃), §4(인터랙션), §5(코드 워크스루), §6(Mayer) | 시각화·레이아웃·인터랙션 소재 |
| `input_data.json` | `slide_config` (slide_tool, design_tone), `session_manifest`, `source_script` | 설정값 + 세션 목록 |
| session 파일들 | `{source_script.lecture_root}/02_script/session_D{day}-{num}.md` | 콘텐츠 소스 (발화문, 코드, 발문, 활동, 전환, 비유) |

2. 템플릿 로드:
   - `.claude/templates/slide-plan-template.md` Read

3. 데이터 무결성 검증:
   - architecture.md §3의 전체 슬라이드 수 = session_manifest 기반 합계
   - architecture.md §8 검증 결과에서 7항목 모두 Pass 확인
   - brainstorm_result.md §1~§7 각 섹션 존재 확인
   - session_manifest의 모든 세션 파일이 존재하는지 확인
   - 파일 누락 시 → 해당 파일명 명시하고 중단

---

### Step 1: §1 기획 개요 + §2 공통 가이드

| 항목 | 내용 |
|------|------|
| 입력 | input_data.json, architecture.md §1~§2, brainstorm_result.md §6 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_plan_header.md`에 포함 |

**동작**:

#### 1-1. §1 기획 개요

- **§1-1 기본 정보**: input_data.json에서 강의명, 대상, 총 슬라이드 수, 총 시간, 도구, 톤 (7행 테이블)
- **§1-2 세션 매니페스트**: session_manifest를 테이블로 출력 (세션ID, 제목, 시간, 슬라이드 수, content_type, GRR)
- **§1-3 도구 설정**: slide_tool별 테마, 레이아웃 기본값, 코드 하이라이트 문법

#### 1-2. §2 공통 가이드

- **§2-1 AE 규칙**: AE 적용 대상 (GRR 구간별 적용률), 예외 (구조 슬라이드)
- **§2-2 GRR 시각 밀도**: I Do(풍부) / We Do(참여형) / You Do(최소) 밀도 표
- **§2-3 Mayer 원칙 (7개)**: brainstorm_result.md §6에서 기획 적용 원칙 추출
- **§2-4 One Idea Rule**: 6×6 규칙, 코드 15줄 제한

---

### Step 2: §3 표기법 + 12유형별 레이아웃 가이드

| 항목 | 내용 |
|------|------|
| 입력 | brainstorm_result.md §3(레이아웃), architecture.md §5(인터랙션) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_plan_header.md`에 포함 |

**동작**:

#### 2-1. §3-1 명세 표기법

4레이어 구조(CONTENT / VISUAL / SPEAKER_NOTE / IMPL_HINT)의 마크다운 표기법 정의.

#### 2-2. §3-2 12유형별 레이아웃 가이드

brainstorm_result.md §3의 레이아웃 후보를 12유형별로 정리:
- 각 유형별: 필수 요소, 선택 요소, 레이아웃 패턴, 구현 힌트(slide_tool별), 금지 패턴
- slide_tool에 따른 구현 차이 명시 (marp: `_class`, slidev: `layout`)

---

### Step 3: §4 세션별 슬라이드 명세 ★ 핵심 Step

| 항목 | 내용 |
|------|------|
| 입력 | architecture.md §3(슬라이드 구조), brainstorm_result.md §1~§5, session 파일, input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/slides_D{day}-{num}.md` (세션별 독립 파일) |

**이 Step이 기획안 분량의 75~80%를 차지한다.**

architecture.md §3의 각 슬라이드 행을 1:1로 4레이어 명세(25~55줄)로 확장한다.

#### 3-1. 슬라이드별 4레이어 명세

```markdown
### [SLIDE {seq}] {유형} — {제목} ({GRR}, {시간}분)

**CONTENT**
- AE Assertion: "{완전한 주장 문장}" ← architecture §3 + session 파일 핵심 발화
- AE Evidence: {시각 증거 설명} ← session 파일 코드/다이어그램/예시
- 핵심 텍스트: {6×6 이내}
- 코드: (코드 슬라이드 시) ← session 파일 fenced code block (15줄 이내)

**VISUAL**
- 레이아웃: {12유형별 레이아웃} ← §3-2 가이드
- 다이어그램: {Mermaid 타입 + 주요 노드} ← brainstorm §2 시각화 아이디어
- 색상/아이콘: {강조 색상, 아이콘} ← design_tone + brainstorm §2
- 이미지: {이미지 설명} (해당 시)

**SPEAKER_NOTE**
- 발화 큐: "{발표 시 핵심 멘트}" ← session 파일 `> "..."` 핵심 문장 (50단어 이내)
- 시간 큐: {체류 시간}분
- 전환: "{다음 슬라이드 연결}" ← session 파일 `🔄` 전환 문구
- 데모 체크리스트: {체크리스트} (코드/실습 슬라이드 시) ← session 파일 `📋`
- 발문: "{질문}" (퀴즈/발문 슬라이드 시) ← session 파일 `❓`

**IMPL_HINT**
- frontmatter: {slide_tool별 메타데이터}
- layout: {slide_tool별 레이아웃 값} ← brainstorm §3 + architecture §5
- directive: {slide_tool별 디렉티브}
- interaction: {v-click/fragment/분절} ← brainstorm §4 인터랙션 설계
```

#### 3-2. Session 파일 콘텐츠 추출 매핑

| session 요소 | 추출 패턴 | 슬라이드 레이어 | 변환 방법 |
|-------------|----------|-------------|---------|
| `> "..."` 발화문 | 인용 블록 | SPEAKER_NOTE 발화 큐 | GRR 구간별 핵심 문장 추출, 50단어 이내 요약 |
| ` ```...``` ` 코드 | fenced code block | CONTENT 코드 | 15줄 이내로 발췌, 하이라이트 줄 번호 지정 |
| `❓ [LN]` 발문 | Bloom's 태그 + 텍스트 | SPEAKER_NOTE 발문 + CONTENT 인터랙션 | 발문 텍스트 → 슬라이드 질문, 예상 답변 → 노트 |
| `📋` 활동 지시 | 체크리스트/과제 | CONTENT 실습 슬라이드 | 과제 지시 + 성공 기준 (3항목 이내) |
| `🔄` 전환 문구 | 전환 발화 | SPEAKER_NOTE 전환 지시 | 이전→다음 연결 문구 |
| 비유/메타포 | 비유 포함 문장 | VISUAL 시각화 변환 | 비유를 다이어그램/아이콘으로 변환 |
| `[코드 시연]` 행동 지시 | 시연 지시 + 코드 | CONTENT 코드 + SPEAKER_NOTE 데모 체크리스트 | 코드 블록 + 강사 설명 큐 |
| `⏱️` 시간 큐 | 시간 정보 | SPEAKER_NOTE 시간 큐 | 체류 시간으로 변환 |

#### 3-3. 데이터 소스 우선순위 (11단계)

| # | 소스 | 적용 대상 |
|---|------|----------|
| 1 | architecture.md §3 | 슬라이드 골격 (유형, GRR, AE, 시간) — **변경 불가** |
| 2 | session 파일 발화문 `> "..."` | SPEAKER_NOTE 발화 큐, CONTENT 핵심 텍스트 |
| 3 | session 파일 코드 블록 | 코드 슬라이드 CONTENT |
| 4 | session 파일 발문 `❓` | SPEAKER_NOTE 발문 큐, 인터랙션 슬라이드 CONTENT |
| 5 | session 파일 활동 지시 `📋` | 실습/활동 슬라이드 CONTENT |
| 6 | brainstorm §1 (AE 구조) | AE Assertion 보강 |
| 7 | brainstorm §3 (레이아웃) | VISUAL 레이아웃 패턴 |
| 8 | brainstorm §4 (인터랙션) | IMPL_HINT Progressive Disclosure |
| 9 | brainstorm §5 (코드 워크스루) | 코드 하이라이트 줄 범위, 워크스루 패턴 |
| 10 | brainstorm §2 (시각화) | VISUAL 다이어그램, 아이콘 |
| 11 | input_data.json tone_examples | 비유 시각화 |

#### 3-4. 세션별 파일 구조

```markdown
# 세션 D{day}-{num}: {제목} ({duration_min}분, {slides}장)

## 세션 메타

| 항목 | 내용 |
|------|------|
| SLO | {slo} (Bloom's: {level}) |
| content_type | {content_type} |
| GRR 배분 | I Do {i_do}분 / We Do {we_do}분 / YDT {ydt}분 / YDA {yda}분 |
| 슬라이드 수 | {slides}장 |
| AE 적용 | {ae_count}/{ae_target}장 ({ae_rate}%) |

## 슬라이드 명세

### [SLIDE 1] 제목 — {세션 제목}
(4레이어 명세)

### [SLIDE 2] 아젠다 — {세션 아젠다}
(4레이어 명세)

### [SLIDE 3~N] {유형} — {제목}
(4레이어 명세 반복)

### [SLIDE N] 핵심요약 — {세션 요약}
(4레이어 명세)
```

#### 3-5. GRR 구간별 슬라이드 특성

| GRR 구간 | CONTENT 특성 | VISUAL 특성 | SPEAKER_NOTE 특성 | IMPL_HINT 특성 |
|---------|------------|-----------|-----------------|--------------|
| 도입 | Hook 문장, SLO 1줄 요약 | 풍부 (이미지/아이콘) | 흥미 유발 발화 | `_paginate: false` |
| I Do | AE 필수, 코드 완성형 | 풍부 (다이어그램/코드) | Think-Aloud 큐, 비유 설명 | 하이라이트 줄 지정 |
| We Do | AE 권장, 스캐폴드 코드 | 참여형 (빈칸/TODO 강조) | 안내 발화, 단계별 지시 | `v-click` / 분절 |
| You Do | 과제 명세, 성공 기준 | 최소 (지시 중심) | 순회 피드백 큐 | 체크리스트 레이아웃 |
| 정리 | 핵심 3~5개, 전이 | 요약형 (아이콘+키워드) | 다음 세션 연결 | — |

#### 3-6. 코드 슬라이드 작성 규칙

| 코드 규모 | 배치 방법 | IMPL_HINT |
|-----------|----------|----------|
| 짧은 코드 (≤10줄) | CONTENT에 전체 코드 | `highlight: {줄 번호}` |
| 중간 코드 (11~15줄) | CONTENT에 전체 코드 + 설명 분리 | `highlight: {줄 번호}`, `layout: two-cols` |
| 긴 코드 (>15줄) | 분절: 핵심 부분만 CONTENT + §7에 전체 참조 | 확대경 또는 빌드업 패턴 |

---

### Step 4: §5 유형 분포 집계 + §6 인터랙션 목록 (Quick Reference)

| 항목 | 내용 |
|------|------|
| 입력 | Step 3(§4)에서 작성된 세션별 슬라이드 명세 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_plan_footer.md`에 포함 |

**동작**:

#### 4-1. §5 유형 분포 집계

- **§5-1 전체 유형별 분포**: §4의 모든 슬라이드를 12유형별로 카운트 (수량, 비율)
- **§5-2 GRR 구간별 분포**: GRR 구간별 슬라이드 수, AE 적용 수, AE 적용률
- **§5-3 텍스트 전용 비율**: 시각 요소가 없는 슬라이드 비율 (≤10% 확인)

#### 4-2. §6 인터랙션 목록

§4에서 인터랙션이 포함된 슬라이드(퀴즈/발문, 실습, v-click 등)를 집계한다:
- 컬럼: 세션 | 슬라이드 # | 유형 | 인터랙션 내용 | 구현 방법 | Bloom's
- 슬라이드 제작 시 인터랙션 구현 빠뜨림을 방지하는 레퍼런스 용도

---

### Step 5: §7 코드 워크스루 가이드 + §8 제작 참고

| 항목 | 내용 |
|------|------|
| 입력 | brainstorm §5(코드 워크스루), §4 전체, input_data.json(design_tone) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_plan_footer.md` |

**동작**:

#### 5-1. §7 코드 워크스루 가이드

- **§7-1 코드 슬라이드 목록**: 세션, 슬라이드 #, 파일명, 줄 수, 하이라이트 범위, 워크스루 패턴(5패턴 중)
- **§7-2 코드 분절 계획**: 15줄 초과 코드의 분절 계획 (확대경/빌드업/시퀀스)

#### 5-2. §8 제작 참고

- **§8-1 에셋 목록**: 다이어그램(Mermaid 자동), 이미지(수동 준비), 아이콘 등
- **§8-2 디렉티브 레퍼런스**: slide_tool별 디렉티브 사용 슬라이드 목록
- **§8-3 디자인 톤 가이드**: 폰트, 색상, 배경 등 기본 스타일
- **§8-4 검증 체크리스트**: 6항목 (슬라이드 수 일치, 시간 합산, AE 적용률, 6×6, 코드 줄 수, 텍스트 전용)
