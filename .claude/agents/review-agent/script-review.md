# 강의교안 품질 검토 (Phase 7/9/10) 세부 워크플로우

### 설계 원칙

1. **구성안 Phase 7 패턴 재사용**: 점진적 Write(중간 파일 → 통합), 인용 규칙(기대값/실제값/수정가이드), 3단계 판정(PASS/CONDITIONAL PASS/REVISION REQUIRED)
2. **교안 고유 검증 영역 독립 분리**: 구조 완전성, GRR 4단계, 형성평가 배치, 예시 완전성, 교안 콘텐츠 품질
3. **대본 고유 검증 영역 독립 분리**: 교안 참조 정합, 발화문 구어체, 발문/전환 존재, 팩트 창작 검출
4. **자동 판별 기준**: "도입/I Do/We Do/You Do/정리 5구간 존재", "time_ratio ±5%" 등 정량적 기준 최대화
5. **가중치 미적용**: 각 영역 모두 "강사가 수업 진행 가능한가"에 수렴. Major/Minor 분류로 충분
6. **3단계 판정**: `shared/judgment-criteria.md` 참조

### 검토 모드 개요

| 모드 | Phase | 범위 | 검증 영역 | 산출물 |
|------|-------|------|----------|--------|
| **교안 검토** | Phase 7 | `session_D{day}-{num}.md` (교안 콘텐츠) | G+T+C+EX (~35항목) | `_review_content_{block_id}.md` |
| **대본 검토** | Phase 9 | `narration_D{day}-{num}.md` (강사 대본) | NR (8항목) | `_review_narration_{block_id}.md` |
| **통합 검토** | Phase 10 | `block_D{day}_{AM\|PM}.md` (블록 단위) | S+블록간일관성 (~15항목) | `quality_review.md` |

**모드 판별**: prompt에 "교안 검토 모드" 키워드가 있으면 교안 검토, "대본 검토 모드" 키워드가 있으면 대본 검토, "통합 검토 모드" 키워드가 있으면 통합 검토를 수행한다.

---

## 교안 검토 모드 (Phase 7)

### 전체 흐름

```
Step 0: 입력 로드
  │     session_D{day}-{num}.md 파일들 (검증 대상)
  │     + 02_script/architecture.md + brainstorm_result.md + research_deep.md + input_data.json (검증 기준-교안)
  │     + 01_outline/lecture_outline.md + 01_outline/architecture.md (검증 기준-구성안)
  │
  ├── Step 2: 구조 완전성 검증 — 5구간/GRR/확인활동 (G-1~G-4, G-7: 5항목)
  │
  ├── Step 3: 시간 배분 현실성 검증 (T-1~T-8: 8항목)
  │
  ├── Step 4: 콘텐츠 정확성 검증 — Anti-Hallucination (C-1~C-12: 12항목)
  │
  ├── Step 5: 교안 예시 품질 검증 (EX-1~EX-4: 4항목)
  │
  └── Step 6: 블록 판정 통합 → _review_content_{block_id}.md Write
```

**단일 파일 Write 패턴**: 중간 파일 없이 `_review_content_{block_id}.md`에 단계별 결과를 순차 Write한다.

### Step 0: 입력 로드

| 항목 | 내용 |
|------|------|
| 입력 | 해당 블록의 `session_D{day}-{num}.md` 파일들 + 6개 기준 파일 |
| 도구 | Read |
| 산출물 | (내부 컨텍스트) |

**동작**:

0. `.claude/templates/input-schema-script.json` 읽기 — script_config 각 필드의 enum 값, 유효 범위를 사전 이해
1. 검증 대상 로드 — 해당 블록의 `session_D{day}-{num}.md` 파일들을 Read
2. 교안 검증 기준 4개 파일 Read:
   - `{output_dir}/architecture.md`: 차시 내부 구조(GRR/시간 블록), 형성평가 배치
   - `{output_dir}/brainstorm_result.md`: 활동 아이디어, 사례/훅, 오개념
   - `{output_dir}/research_deep.md`: 확정된 전제, 확보된 소재, 미해결 항목
   - `{output_dir}/input_data.json`: teaching_model, time_ratio, formative_assessment
3. 구성안 검증 기준 2개 파일 Read:
   - `{outline_dir}/lecture_outline.md`: CLO/SLO 원본, 차시 배치 원본
   - `{outline_dir}/architecture.md`: 정렬 맵 원본, 평가 체계 원본, 시간 예산 원본

**파일별 역할**:

| # | 파일 | 역할 | 검증 단계 |
|---|------|------|----------|
| 1 | `session_D{day}-{num}.md` (블록별 묶음) | **검증 대상** | Step 2~5 |
| 2 | `02_script/architecture.md` | GRR/시간/전환 기준 | Step 2, 3, 4 |
| 3 | `02_script/brainstorm_result.md` | 활동/사례/오개념 원본 | Step 4, 5 |
| 4 | `02_script/research_deep.md` | 소재/미해결 항목 기준 | Step 4 |
| 5 | `02_script/input_data.json` | 설정값/교수 모델 기준 | Step 2, 3, 4 |
| 6 | `01_outline/lecture_outline.md` | CLO/SLO 원본 기준 | Step 4 |
| 7 | `01_outline/architecture.md` | 정렬 맵/평가/시간 원본 기준 | Step 3, 4 |

---

### Step 2: 구조 완전성 검증 (G-1~G-4, G-7)

| 항목 | 내용 |
|------|------|
| 입력 | session_D{day}-{num}.md, input_data.json, 02_script/architecture.md |
| 도구 | Read, Write |
| 산출물 | `_review_content_{block_id}.md` (누적 Write) |

이 Step은 교안 콘텐츠의 **수업 구조 완전성**을 검증한다.

**체크리스트**:

#### 2-1. 5구간 구조 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | G-1 | 5구간 완전성 | 모든 차시에 도입 / I Do / We Do / You Do / 정리 5구간 모두 존재 | Major (구간 누락 차시 존재), Minor (구간 헤딩 명칭 불일치) |
| 2 | G-2 | GRR 4단계 순차성 | 전개부에서 I Do → We Do → You Do Together → You Do Alone 순서 준수. "I Do → You Do 점프" (We Do 생략) 검출 | Major (We Do 생략), Minor (You Do Together/Alone 구분 미명시) |

#### 2-2. GRR 시간 배분 및 확인 활동 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 3 | G-3 | GRR 시간 배분 일치 | 각 교시의 I Do/We Do/You Do 시간이 architecture.md §2-3 GRR 배분표와 ±3분 이내 일치 | Major (5분+ 차이), Minor (3~5분 차이) |
| 4 | G-4 | GRR 시간 비율 현실성 | 직접교수법 기준: I Do ≤22%, We Do 22~28%, You Do ≥28%. 교수 모델별 기준 적용 | Minor (기준 범위 소폭 이탈) |
| 5 | G-7 | 확인 활동 삽입 여부 | I Do 세그먼트 내 15분 초과 시 확인 활동(Think-Pair-Share, 확인 발문, 마이크로 실습) 삽입 존재 여부 | Major (15분 초과 + 확인 활동 미삽입), Minor (14~15분 경계 — 확인 활동 권장) |

**동작**: G-1~G-4, G-7 검증 결과를 `_review_content_{block_id}.md`에 Write한다.

---

### Step 3: 시간 배분 현실성 검증 (T-1~T-8)

| 항목 | 내용 |
|------|------|
| 입력 | session_D{day}-{num}.md, 02_script/architecture.md, input_data.json, 01_outline/architecture.md |
| 도구 | Read, Write |
| 산출물 | `_review_content_{block_id}.md` (누적 Write) |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | T-1 | 교시 시간 합산 | 각 교시의 도입+전개+정리 시간 합 = session_minutes. 각 단계 헤딩의 `({분}분)` 값 합산으로 검증 | Major (5분+ 차이), Minor (1~4분 차이) |
| 2 | T-2 | 도입:전개:정리 비율 준수 | input_data.json의 time_ratio (예: 16:70:14) 대비 각 교시의 실제 비율이 ±5% 이내 | Major (10%+ 차이), Minor (5~10% 차이) |
| 3 | T-3 | GRR 시간 비율 현실성 | 직접교수법 기준: I Do ≤22%, We Do 22~28%, You Do ≥28%. 교수 모델별 기준 적용 (PBL: We Do 중심, 플립: You Do 중심) | Minor (기준 범위 소폭 이탈) |
| 4 | T-4 | 일일 교시 수 | 각 Day의 교시 수 × session_minutes ≤ hours_per_day × 60. 검증 공식: `일일 최대 교시 = (hours_per_day × 60) ÷ (session_minutes + break_minutes)` | Major (초과 10%+), Minor (초과 5% 미만) |
| 5 | T-5 | 15분 분절 준수 | I Do 세그먼트에서 15분 초과 연속 설명 없이 확인 활동 삽입 여부 확인 | Minor (15분 초과 연속 설명) |
| 6 | T-6 | 활동 시간 명시 | 모든 활동 지시(`📋`)에 소요 시간 명시 (`(N분)` 형태) | Minor (시간 미명시 활동) |
| 7 | T-7 | 시간 예산 일치 | 교시 헤더의 교수 모델 및 시간 구조 값이 input_data.json의 teaching_model, time_ratio와 일치 | Major (불일치) |
| 8 | T-8 | 시간큐 연속성 | `⏱️` 경과/잔여 시간큐가 교시 내에서 시간 순서대로 증가하며, 마지막 시간큐의 경과 시간이 session_minutes와 ±2분 이내 | Minor (시간큐 역행 또는 누락) |

**동작**: T-1~T-8 검증 결과를 `_review_content_{block_id}.md`에 누적 Write한다.

---

### Step 4: 콘텐츠 정확성 검증 — Anti-Hallucination (C-1~C-12)

| 항목 | 내용 |
|------|------|
| 입력 | session_D{day}-{num}.md, 02_script/architecture.md, 02_script/brainstorm_result.md, 02_script/research_deep.md, 02_script/input_data.json, 01_outline/lecture_outline.md, 01_outline/architecture.md, context7_verify_{block_id}.md (존재 시) |
| 도구 | Read, Write |
| 산출물 | `_review_content_{block_id}.md` (누적 Write) |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | C-1 | CLO/SLO 원본 일치 | 교시 헤더의 SLO 텍스트가 구성안 `01_outline/architecture.md` §2-1, §2-2와 동일 | Major (변경됨) |
| 2 | C-2 | 차시 배치 원본 일치 | 교시 순서, 하위 주제 배정이 교안 `02_script/architecture.md` §3 차시별 내부 구조의 교시 순서와 동일 | Major (변경됨) |
| 3 | C-3 | GRR 배정 원본 일치 | 각 교시의 GRR 단계(I Do/We Do/You Do)와 배정이 교안 architecture.md §3의 설계와 일치 | Major (변경됨) |
| 4 | C-4 | 활동 소재 근거 존재 | 학습활동 내 구체적 사례/수치/코드가 brainstorm §2(활동), research_deep §3-2(확보된 소재), 또는 input_data.json에 근거 | Major (근거 없는 팩트 창작) |
| 5 | C-5 | 오개념 대응 일치 | 교안 §오개념 교정 항목이 brainstorm §6(오개념) 목록을 빠짐없이 반영 | Major (brainstorm §6 오개념 누락), Minor (추가 오개념 신규 생성) |
| 6 | C-6 | 미해결 항목 반영 | research_deep §3-3의 미해결 항목이 해당 교시의 사전 확인 항목에 반영 | Minor (누락) |
| 7 | C-7 | 참고자료 출처 일치 | 인용된 출처가 research_deep 또는 brainstorm_result의 출처 목록에 존재 | Minor (새로 추가된 출처) |
| 8 | C-8 | 실습 환경 반영 | input_data.json lab_environment가 non-null일 때: 실습 교시의 필요 자료에 해당 도구/환경 명시 | Major (lab_environment 존재 시 도구 미명시), Minor (환경 설정 절차 누락) |
| 9 | C-9 | 코드 예제 API 정확성 | `context7_verify_{block_id}.md` 존재 시만 적용. 코드 블록의 함수명·파라미터·반환 타입이 공식 문서와 일치. 비기술 교육: 자동 Pass | Major (존재하지 않는 API 호출), Minor (파라미터 순서/타입 차이, deprecated API 사용) |
| 10 | C-10 | 코드 콘텐츠 밀도 (기술 교육 시 필수) | 각 차시의 I Do 세그먼트에 최소 1개 이상의 fenced code block(``` ```) 존재. 비기술 교육: 자동 Pass | Major (I Do에 코드 블록 0개 — 기술 교육 차시), Minor (코드 블록에 언어 미지정, 파일명 주석 누락) |
| 11 | C-11 | 플레이스홀더 잔존 검출 | `[코드 시연: ...]`, `[코드 예시]`, `[데모: ...]` 같은 코드 대체 플레이스홀더 존재 여부 | Major (코드 블록 없이 플레이스홀더만 있는 경우), Minor (플레이스홀더 + 코드 블록 병존) |
| 12 | C-12 | `{중괄호}` 플레이스홀더 검출 | `{중괄호}` 플레이스홀더 잔존 검출. 학습자 실습용 양식 내부의 `[직접 입력]`은 제외 | Major (5개+), Minor (1~4개) |

**동작**: C-1~C-12 검증 결과를 `_review_content_{block_id}.md`에 누적 Write한다.

---

### Step 5: 교안 예시 품질 검증 (EX-1~EX-4)

| 항목 | 내용 |
|------|------|
| 입력 | session_D{day}-{num}.md, 02_script/brainstorm_result.md, 02_script/input_data.json |
| 도구 | Read, Write |
| 산출물 | `_review_content_{block_id}.md` (누적 Write) |

이 Step은 교안 콘텐츠의 **예시 완전성과 오개념 교정** 품질을 검증한다.

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | EX-1 | 다중 예시 충족 | ★ 표기된 핵심 예시가 각 교시당 최소 2개 존재 | Major (핵심 예시 1개 이하 — 기술 교육 차시), Minor (핵심 예시 ★ 표기 누락) |
| 2 | EX-2 | You Do 완전성 | You Do 구간에 시작 코드 + 완성 코드 + 예상 결과 + 흔한 실수 시나리오 4요소 모두 존재 | Major (시작 코드 또는 완성 코드 누락), Minor (예상 결과 또는 흔한 실수 시나리오 누락) |
| 3 | EX-3 | 코드 예제 완전성 | 50줄 이상 코드 블록이 있을 때 `code_examples_D*.md` 별도 파일 존재 및 해당 교시에 참조 링크 존재 | Minor (50줄+ 코드가 인라인에만 존재 — 별도 파일 없음) |
| 4 | EX-4 | 오개념 교정 반영 | brainstorm §6 오개념 항목이 교안의 해당 차시 오개념 교정 섹션에 반영되었는지 | Major (brainstorm §6 오개념이 교안에 미반영), Minor (오개념 교정 설명 미흡) |

**동작**: EX-1~EX-4 검증 결과를 `_review_content_{block_id}.md`에 누적 Write한다.

---

### Step 6: 블록 판정 통합

| 항목 | 내용 |
|------|------|
| 입력 | `_review_content_{block_id}.md` (Step 2~5 결과 누적본) |
| 도구 | Read, Write |
| 산출물 | `_review_content_{block_id}.md` (판정 섹션 추가 Write) |

**동작**:

1. 누적된 검증 결과에서 Major/Minor 위반 수 집계
2. **판정 결정**: `shared/judgment-criteria.md`의 판정 기준에 따라 판정
3. `_review_content_{block_id}.md`에 판정 섹션 추가 Write

---

### 교안 검토 산출물 구조

`_review_content_{block_id}.md` 파일 구조:

```markdown
# 교안 블록 검토 결과 — {block_id}

## 메타데이터

| 항목 | 값 |
|------|-----|
| 검토 일자 | {date} |
| 검토 대상 | session_D{day}-{num}.md (블록: {block_id}) |
| 검증 항목 수 | ~29개 (G:5 + T:8 + C:12 + EX:4) |
| 판정 | {PASS / CONDITIONAL PASS / REVISION REQUIRED} |

---

## 1. 검토 요약

| 영역 | 검증 항목 수 | Pass | Fail (Major) | Fail (Minor) |
|------|------------|------|-------------|-------------|
| 구조 완전성 (G) | 5 | {N} | {N} | {N} |
| 시간 배분 현실성 (T) | 8 | {N} | {N} | {N} |
| 콘텐츠 정확성 (C) | 12 | {N} | {N} | {N} |
| 교안 예시 품질 (EX) | 4 | {N} | {N} | {N} |
| **합계** | **29** | {N} | {N} | {N} |

---

## 2. 검증 상세

| # | 검증 ID | 영역 | 결과 | 상세 |
|---|---------|------|------|------|
| 1 | G-1 | 구조 완전성 | {Pass/Major/Minor} | {검증 결과 요약} |
...

---

## 3. Major 위반 사항

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (교안) | 해당 교시/섹션 | 수정 가이드 |
|---|---------|------|----------|-------------|--------------|-------------|-----------|

---

## 4. Minor 위반 사항

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (교안) | 해당 교시/섹션 | 수정 권고 |
|---|---------|------|----------|-------------|--------------|-------------|----------|

---

## 5. 최종 판정

**판정**: {PASS / CONDITIONAL PASS / REVISION REQUIRED}

**판정 근거**:
- Major 위반: {N}개
- Minor 위반: {N}개
- 총 검증 항목: 29개 중 Pass {N}개
```

---

## 대본 검토 모드 (Phase 9)

**검증 대상**: `narration_D{day}-{num}.md` (강사 대본 파일)

### 전체 흐름

```
Step 0: 입력 로드
  │     narration_D{day}-{num}.md 파일들 (검증 대상)
  │     + session_D{day}-{num}.md (교안 참조용)
  │     + 02_script/input_data.json
  │
  ├── Step 1: 대본 검증 (NR-1~NR-8, 8항목)
  │
  └── Step 2: 판정 통합 → _review_narration_{block_id}.md Write
```

**단일 파일 Write 패턴**: `_review_narration_{block_id}.md`에 순차 Write한다.

### Step 0: 입력 로드

**동작**:

1. 해당 블록의 `narration_D{day}-{num}.md` 파일들을 Read
2. 동일 블록의 `session_D{day}-{num}.md` 파일들을 Read (교안 참조 정합 검증에 필요)
3. `{output_dir}/input_data.json` Read

### Step 1: 대본 검증 (NR-1~NR-8)

| 항목 | 내용 |
|------|------|
| 입력 | narration_D{day}-{num}.md, session_D{day}-{num}.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `_review_narration_{block_id}.md` |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | NR-1 | 교안 참조 정합 | 대본의 `[교안 §... 참조]` 표기가 실제 교안(`session_D{day}-{num}.md`) 섹션과 일치 | Major (참조 섹션이 교안에 존재하지 않음), Minor (참조 표기 누락) |
| 2 | NR-2 | 발화문 구어체 | 문어체(~한다, ~이다, ~였다) 사용 여부 검출. 강사 발화는 반드시 ~해요/~입니다/~할게요 구어체 | Major (I Do/We Do 발화의 50%+ 문어체), Minor (산발적 1~3건 문어체) |
| 3 | NR-3 | 시간 배분 | 도입+전개+정리 시간 합산 = session_minutes (±2분 이내) | Major (5분+ 차이), Minor (2~5분 차이) |
| 4 | NR-4 | 발문 존재 | 도입/전개/정리 구간에 각각 최소 1개 이상 발문(`❓`) 존재 | Major (전개 발문 전무), Minor (도입 또는 정리 발문 누락) |
| 5 | NR-5 | 예상 반응 | 각 발문(`❓`)에 `💬` 예상 반응 1개 이상 존재 | Minor (예상 반응 누락 발문당) |
| 6 | NR-6 | 전환 문구 존재 | 도입→전개, I Do→We Do, We Do→You Do, 전개→정리 전환 멘트 존재 (`🔄` 표기) | Major (도입→전개 또는 전개→정리 전환 누락), Minor (I Do↔We Do 또는 We Do↔You Do 전환 누락) |
| 7 | NR-7 | ★ 핵심 예시 참조 | 교안의 ★ 표기 핵심 예시가 대본에서 반드시 언급되거나 참조 | Major (교안 ★ 핵심 예시가 대본에 전혀 등장하지 않음), Minor (참조 표기 없이 내용만 반영) |
| 8 | NR-8 | 팩트 창작 검출 | 교안(`session_D{day}-{num}.md`)에 없는 새로운 사실/수치/사례가 대본에 신규 등장하는지 | Major (근거 없는 팩트 창작 — 교안에도 brainstorm에도 없는 내용), Minor (교안에 없으나 brainstorm에 근거 있는 소재) |

**동작**: NR-1~NR-8 검증 결과를 `_review_narration_{block_id}.md`에 Write한다.

### Step 2: 판정 통합

**동작**:

1. NR-1~NR-8 위반 수 집계
2. `shared/judgment-criteria.md`의 판정 기준에 따라 판정
3. `_review_narration_{block_id}.md`에 판정 섹션 추가 Write

### 대본 검토 산출물 구조

`_review_narration_{block_id}.md` 파일 구조:

```markdown
# 대본 검토 결과 — {block_id}

## 메타데이터

| 항목 | 값 |
|------|-----|
| 검토 일자 | {date} |
| 검토 대상 | narration_D{day}-{num}.md (블록: {block_id}) |
| 검증 항목 수 | 8개 (NR-1~NR-8) |
| 판정 | {PASS / CONDITIONAL PASS / REVISION REQUIRED} |

---

## 1. 검토 요약

| 영역 | 검증 항목 수 | Pass | Fail (Major) | Fail (Minor) |
|------|------------|------|-------------|-------------|
| 대본 품질 (NR) | 8 | {N} | {N} | {N} |

---

## 2. 검증 상세

| # | 검증 ID | 결과 | 상세 |
|---|---------|------|------|
| 1 | NR-1 | {Pass/Major/Minor} | {검증 결과 요약} |
...

---

## 3. Major 위반 사항

| # | 검증 ID | 위반 내용 | 기대값 (교안) | 실제값 (대본) | 해당 교시/위치 | 수정 가이드 |
|---|---------|----------|-------------|--------------|-------------|-----------|

---

## 4. Minor 위반 사항

| # | 검증 ID | 위반 내용 | 기대값 (교안) | 실제값 (대본) | 해당 교시/위치 | 수정 권고 |
|---|---------|----------|-------------|--------------|-------------|----------|

---

## 5. 최종 판정

**판정**: {PASS / CONDITIONAL PASS / REVISION REQUIRED}

**판정 근거**:
- Major 위반: {N}개
- Minor 위반: {N}개
- 총 검증 항목: 8개 중 Pass {N}개
```

---

## 통합 검토 모드 (Phase 10)

**검증 대상**: `block_D{day}_{AM|PM}.md` (블록 단위 통합 파일)

블록별 교안/대본 검토 완료 후, 전체 문서의 교차 일관성을 검증한다.

### 전체 흐름

```
Step 0: 입력 로드
  │     block_D{day}_{AM|PM}.md 파일들 (검증 대상)
  │     + _review_content_*.md 전부
  │     + _review_narration_*.md 전부 (존재 시)
  │     + 기준 파일들
  │
  ├── Step 1: 구조 완전성 검증 (S-1~S-7, 7항목)
  │
  ├── Step 2: 블록 간 전환 일관성 검증
  │
  ├── Step 3: SLO 커버리지 전체 확인
  │
  ├── Step 4: 집계 정합 검증
  │
  ├── Step 5: 용어/표기 통일 검증
  │
  └── Step 6: 블록별 검토 결과 통합 + 최종 판정 → quality_review.md Write
```

### Step 0: 입력 로드

**동작**:

1. 전체 `block_D{day}_{AM|PM}.md` 파일들을 Read
2. `_review_content_*.md` 전부 Read
3. `_review_narration_*.md` 전부 Read (존재 시)
4. 기준 파일 Read: `02_script/architecture.md`, `02_script/input_data.json`, `01_outline/lecture_outline.md`, `01_outline/architecture.md`

### Step 1: 구조 완전성 검증 (S-1~S-7)

| 항목 | 내용 |
|------|------|
| 입력 | block_D{day}_{AM|PM}.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step1.md` |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | S-1 | 8개 섹션 존재 | §1~§8 헤딩 모두 존재 (강의 개요, 학습 목표 요약, 공통 교안 구조, 차시별 교안, 형성평가 집계, 발문 모음, 교재/참고자료, 강사 가이드) | Major (누락 섹션당) |
| 2 | S-2 | 메타데이터 완전성 | 작성일자, 입력소스, 교수 모델, 적용 프레임워크 모두 기재 | Minor |
| 3 | S-3 | 필수 테이블 존재 | §1-1 기본정보, §2-1 CLO-SLO매핑, §2-2 차시-SLO매트릭스, §5-1 형성평가일람, §6-1~6-3 발문모음, §8-1 오개념카드 | Major (누락 테이블당) |
| 4 | S-4 | 빈 셀/플레이스홀더 | `{중괄호}` 플레이스홀더 잔존 검출. 학습자 실습용 양식 내부의 `[직접 입력]`은 제외 | Major (5개+), Minor (1~4개) |
| 5 | S-5 | 표기법 안내 존재 | §1-3에 표기법 정의 존재 (발화문 `> "..."`, 행동지시 `[...]`, 발문 `❓ [Ln]`, 활동 `📋`, 시간큐 `⏱️`, 전환 `🔄`, 예상반응 `💬`) | Major (§1-3 누락), Minor (일부 표기 정의 누락) |
| 6 | S-6 | 서브섹션 완전성 | §1(1-1~1-3), §2(2-1~2-2), §3(3-1~3-3), §5(5-1~5-3), §6(6-1~6-3), §7(7-1~7-3), §8(8-1~8-5) 총 22개 서브섹션 모두 존재 | Major (누락 서브섹션당) |
| 7 | S-7 | 차시 교안 커버리지 | §4에서 input_data.json schedule 기반 전체 Day/교시가 빠짐없이 존재. 검증 공식: `total_sessions = Σ(sessions_per_day[])` → §4에 D1-1 ~ D{N}-{M} 모두 존재 | Major (누락 차시당) |

**동작**: S-1~S-7 검증 결과를 `{output_dir}/_review_step1.md`에 Write한다.

### Step 2: 블록 간 전환 일관성 검증

- AM→PM, Day 간 전환 문구 자연스러움 검증
- 전환 멘트 유무 및 내용 적절성 확인

### Step 3: SLO 커버리지 전체 확인

- 모든 SLO가 블록 파일들에서 다뤄지는지 확인
- `01_outline/architecture.md`의 SLO 목록과 대조

### Step 4: 집계 정합 검증

- §5 형성평가 집계 = §4 인라인 합계
- §6 발문 모음 = §4 인라인 발문

### Step 5: 용어/표기 통일 검증

- 블록 간 동일 개념에 다른 용어 사용 여부
- 코드 예제 네이밍 컨벤션 일관성

### Step 6: 최종 판정 + quality_review.md 작성

| 항목 | 내용 |
|------|------|
| 입력 | `_review_step1.md`, `_review_content_*.md`, `_review_narration_*.md` |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/quality_review.md` ★ |

**동작**:

1. 모든 중간 검토 파일 Read
2. Major/Minor 위반 수 집계 (블록별 검토 + 대본 검토 포함)
3. `shared/judgment-criteria.md`의 판정 기준에 따라 최종 판정
4. `quality_review.md` 작성

---

### 통합 검토 산출물 구조

```markdown
# 교안 최종 품질 검토 결과

## 메타데이터

| 항목 | 값 |
|------|-----|
| 검토 일자 | {date} |
| 검토 대상 | block_D{day}_{AM\|PM}.md (블록 단위 통합) |
| 검토 기준 | 구조 완전성 + 블록 간 일관성 + SLO 커버리지 + 집계 정합 + 용어 통일 |
| 검증 항목 수 | ~15개 (S:7 + 블록간일관성·커버리지·집계·용어) |
| 참조 블록 검토 수 | {N}개 블록 (_review_content_*.md) |
| 참조 대본 검토 수 | {N}개 블록 (_review_narration_*.md) |
| 판정 | {PASS / CONDITIONAL PASS / REVISION REQUIRED} |

---

## 1. 검토 요약

| 영역 | 검증 항목 수 | Pass | Fail (Major) | Fail (Minor) |
|------|------------|------|-------------|-------------|
| 구조 완전성 (S) | 7 | {N} | {N} | {N} |
| 블록 간 일관성 | {N} | {N} | {N} | {N} |
| SLO 커버리지 | {N} | {N} | {N} | {N} |
| 집계 정합 | {N} | {N} | {N} | {N} |
| 용어/표기 통일 | {N} | {N} | {N} | {N} |
| **합계** | **~15** | {N} | {N} | {N} |

---

## 2. 블록별 검토 요약 (참조)

| 블록 | 산출물 파일 | 판정 | Major | Minor |
|------|-----------|------|-------|-------|
| {block_id} | _review_content_{block_id}.md | {판정} | {N} | {N} |

---

## 3. 대본 검토 요약 (참조, 존재 시)

| 블록 | 산출물 파일 | 판정 | Major | Minor |
|------|-----------|------|-------|-------|
| {block_id} | _review_narration_{block_id}.md | {판정} | {N} | {N} |

---

## 4. Major 위반 사항 (통합 검토)

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (블록) | 해당 위치 | 수정 가이드 |
|---|---------|------|----------|-------------|--------------|----------|-----------|

---

## 5. Minor 위반 사항 (통합 검토)

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (블록) | 해당 위치 | 수정 권고 |
|---|---------|------|----------|-------------|--------------|----------|----------|

---

## 6. 수정 우선순위

{PASS인 경우: 이 섹션 생략}

| 순위 | 검증 ID | 위반 유형 | 이유 | 예상 영향 범위 |
|------|---------|----------|------|-------------|

---

## 7. 최종 판정

**판정**: {PASS / CONDITIONAL PASS / REVISION REQUIRED}

**판정 근거**:
- 통합 검토 Major 위반: {N}개
- 통합 검토 Minor 위반: {N}개
- 블록별 교안 검토 미해결 Major: {N}개
- 대본 검토 미해결 Major: {N}개

{CONDITIONAL PASS인 경우}:
**권고 수정 사항**: §6 수정 우선순위 순서대로 Minor 위반을 수정한 뒤 재검토 권장.

{REVISION REQUIRED인 경우}:
**필수 수정 사항**: §6 수정 우선순위 순서대로 Major 위반의 수정 가이드를 따라 해당 교시/섹션을 재작성해야 합니다.
```

---

## 전체 산출물 목록

```
{output_dir}/
├── _review_content_{block_id}.md      # 교안 검토 (블록 수만큼)
├── _review_narration_{block_id}.md  # 대본 검토 (블록 수만큼, Phase 9)
├── _review_step1.md                 # 통합 검토 시: 구조 완전성 결과 (중간)
└── quality_review.md                # 최종 품질 검토 결과 ★
```

---

## 위반 분류

| 유형 | 기준 | 예시 |
|------|------|------|
| **Major** | 교수 설계의 핵심 무결성을 손상하거나, 강사가 교안/대본만으로 수업 진행 불가능 | 5구간 누락, GRR 순서 위반(I Do→You Do 점프), CLO/SLO 변경, 차시 교안 누락, 근거 없는 팩트 창작, 교안 ★ 핵심 예시 대본 미반영 |
| **Minor** | 품질에 영향을 주나 핵심 설계와 수업 진행은 가능 | 시간큐 역행, 발화문 문어체, 확인 활동 누락(경계값), 예상 반응 누락, 활동 성공기준 미명시 |

## 인용 규칙

`shared/judgment-criteria.md`의 인용 규칙을 따른다.

**예시**:

```
| G-1 | 5구간 완전성 | D2-3에서 You Do 구간 누락 | architecture §3 D2-3: I Do/We Do/You Do/정리 | session_D2-3.md: I Do/We Do/정리만 존재 | You Do 구간 추가 — 학습자 독립 실습 파트 작성 필요 |
```
