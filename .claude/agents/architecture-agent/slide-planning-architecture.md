# 슬라이드 기획 아키텍처 설계 (Phase 3) 세부 워크플로우

### 설계 원칙

구성안 Phase 5가 **Top-down** 설계(학습 결과 → 평가 → 차시 배정), 교안 Phase 5가 **Bottom-up** 설계(확정된 차시 내부를 교수 모델별로 채움)라면, 슬라이드 기획 Phase 3은 **Middle-out** 설계(GRR 1차 추정 + 콘텐츠 2차 추정을 병합하여 슬라이드 구조 확정)이다.

**변경 불가 기준**: 교안 `architecture.md`의 차시 구조, SLO, GRR 배분과 `input_data.json`의 `session_manifest`(GRR 기반 1차 슬라이드 수)는 변경하지 않는다. Phase 3은 이 확정 구조 위에 **슬라이드 단위**를 설계한다.

**적용 프레임워크**:
- **Assertion-Evidence** (Michael Alley, Penn State): 주장 제목(12단어 이내) + 시각 증거, 불릿포인트 대체. Body slides에 적용 필수, 타이틀/아젠다/전환 슬라이드는 예외 (Garner & Alley, 2013, p<.01 유의)
- **One Idea Rule** (인지 부하 이론): 1슬라이드 1개념. 요소 6개 초과 시 인지 부하 ~500% 증가 (Naegle, 2021, PLOS Comp. Biol.)
- **Mayer 멀티미디어 8원칙**: Segmenting(d=0.79~0.98), Spatial Contiguity(g=0.63), Signaling, Pre-training 등 (Cromley & Chen, 2025; Mayer, 2020)
- **GRR 시각화 밀도 전략**: I Do→풍부 시각(개념·코드·다이어그램), We Do→참여형(발문·부분공개), You Do→최소(과제·체크리스트)
- **CLT 코드 슬라이드 기준**: 코드 10~15줄 이내, Split Attention 방지(코드+설명 동일 슬라이드), Worked Example 우선 (ACM TOCSE, 2022)
- **Presentation Zen SNR**: 신호 대 소음 비율 최대화, 학습 무관 장식 제거

### 전체 흐름

```
Step 0: 입력 로드 + 변경 불가 기준 확정
  │     input_data.json (session_manifest, slide_config)
  │     + brainstorm_result.md (§1~§7)
  │     + 교안 architecture.md (변경 불가)
  │
  ├── Step 1: 콘텐츠 기반 2차 슬라이드 수 산출 + GRR 병합
  │     AE 테이블 카운팅 + 구조 슬라이드 산출 → estimated_slides_content
  │     → final = round(0.6 × GRR + 0.4 × Content)
  │     → 1.5~2.5분/장 범위 clamp + content_type 보정
  │
  ├── Step 2: 슬라이드 유형 배정 (12유형) + GRR 단계별 배치
  │     AE 적용률 검증 (I Do≥80%, We Do≥60%, You Do≥30%)
  │     + 구조 슬라이드 자동 삽입 + 유형 분포 균형 검증
  │
  ├── Step 3: 슬라이드 시퀀스 + 전환 설계
  │     GRR 순서 배열 + Mayer 분절 + Progressive Disclosure
  │     + 사전훈련 슬라이드 배치 + 세션 간 전환
  │
  └── Step 4: 시간 배분 + 검증(7항목) + architecture.md 통합 작성
```

### 산출물 목록

```
{output_dir}/
└── architecture.md    # Phase 3: 슬라이드 아키텍처 설계 최종 산출물 ★
```

---

### Step 0: 입력 로드 + 변경 불가 기준 확정

| 항목 | 내용 |
|------|------|
| 입력 | 4개 파일 (아래 목록) |
| 도구 | Read |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

1. **스키마 사전 이해**: `.claude/templates/input-schema-slide-planning.json`을 읽고 slide_config 각 필드의 enum 값, 의미, 필드 간 관계를 이해한다.

2. **4개 파일 로드**:

| # | 파일 | 역할 | 변경 가능 |
|---|------|------|----------|
| 1 | `03_slide_plan/input_data.json` | session_manifest, slide_config, estimated_slides | ✗ 변경 불가 |
| 2 | `03_slide_plan/brainstorm_result.md` | §1 AE 구조, §2 시각화, §3 레이아웃, §4 인터랙션, §5 코드 워크스루, §6 Mayer, §7 Decision Log | 참조용 |
| 3 | 교안 `02_script/architecture.md` | 차시 구조, GRR 배분, SLO, 시간표 | ✗ 변경 불가 |
| 4 | `01_outline/input_data.json` | 원본 강의 입력 참조 (존재 시) | 참조용 |

3. **input_data.json에서 추출**:
   - `slide_config.slide_tool`: 슬라이드 도구 (marp/slidev/gamma/revealjs)
   - `slide_config.design_tone`: 디자인 톤 (friendly_visual/professional/minimal)
   - `slide_config.estimated_slides.total`: GRR 기반 1차 전체 예상 슬라이드 수
   - `slide_config.estimated_slides.merge_formula`: 병합 공식
   - `slide_config.slide_density_table`: GRR 구간별 밀도 테이블
   - `slide_config.info_density_lines`: 정보 밀도 줄 수 범위 (25~55줄)
   - `session_manifest[]`: 세션별 session_id, title, duration_min, slo, blooms_level, content_type, grr, estimated_slides_grr
   - `source_script.lecture_root`: 강의 루트 경로

4. **brainstorm_result.md에서 추출**:
   - §1: 세션별 AE 구조 (GRR 단계별 Assertion-Evidence 테이블) → Step 1 콘텐츠 카운팅의 기반
   - §3: 세션별 레이아웃 배정 요약 (12유형 × 세션 합계 테이블) → Step 2 유형 배정 기반
   - §4: 인터랙션 요소 목록 (도구별 구현 명세) → Step 3 시퀀스에 반영
   - §5: 코드 워크스루 계획 (5패턴 × 세션) → Step 2 코드 유형 배정
   - §7: Decision Log (ADOPT/REVISE/DROP/MERGE) → ADOPT/REVISE 항목만 설계에 반영

5. **교안 architecture.md에서 추출**:
   - §1-2: 대상 차시 목록 (SLO, Bloom's, content_type)
   - §2-3: GRR 배분 (전개 시간 내 I Do/We Do/You Do Together/You Do Alone 시간)
   - §3: 차시별 내부 구조 (도입-전개-정리 시간 블록)
   - §4-2.5: 일별 시간표

---

### Step 1: 콘텐츠 기반 2차 슬라이드 수 산출 + GRR 병합

| 항목 | 내용 |
|------|------|
| 입력 | Step 0에서 추출한 데이터 |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

#### 1-1. One Idea Rule 기반 콘텐츠 카운팅

brainstorm_result.md §1(AE 구조)의 세션별 슬라이드 항목을 카운팅한다:

```
for each session in session_manifest:
  # §1 AE 테이블에서 카운팅
  ae_i_do    = §1 해당 세션 I Do 테이블 행 수
  ae_we_do   = §1 해당 세션 We Do 테이블 행 수
  ae_you_do  = §1 해당 세션 You Do 테이블 행 수
  ae_subtotal = ae_i_do + ae_we_do + ae_you_do

  # 구조 슬라이드 수 (세션에 자동 삽입)
  structural = 제목(1) + 아젠다(1) + 핵심요약(1)
             + 섹션전환(GRR 전환 수 — 보통 1~2장)
  structural_count = 3 + ceil(GRR 전환 수 × 0.5)

  # 도입·정리 슬라이드 (AE 테이블에 미포함된 것)
  intro_wrap = 도입 슬라이드(1~2장) + 정리 슬라이드(0~1장)

  estimated_slides_content = ae_subtotal + structural_count + intro_wrap
```

#### 1-2. 2단계 병합

```
for each session:
  grr_est     = session.estimated_slides_grr     # Phase 1에서 산출
  content_est = estimated_slides_content          # Step 1-1에서 산출

  # 가중 평균 병합 (slide_config.estimated_slides.merge_formula)
  merged = round(0.6 × grr_est + 0.4 × content_est)

  # content_type별 밀도 보정
  if session.content_type == "hands-on":
    merged = round(merged × 0.9)   # 코드 슬라이드는 체류 시간↑ → 장수↓
  elif session.content_type == "activity":
    merged = round(merged × 0.8)   # 활동 슬라이드는 장수 적음

  # 시간 범위 clamp (분/장 기준)
  min_slides = floor(session.duration_min / 2.5)  # 최대 2.5분/장
  max_slides = ceil(session.duration_min / 1.5)    # 최소 1.5분/장
  final_slides = clamp(merged, min_slides, max_slides)
```

**분/장 범위 근거**:

| 슬라이드 유형 | 체류 시간 | 출처 |
|------------|---------|------|
| 개념 설명 | 1~2분 | Naegle, 2021 |
| 코드 워크스루 | 2~3분 | CLT in CS Ed., ACM TOCSE 2022 |
| 실습 지시 | 2~4분 | 실무 합의, SessionLab 2022 |
| 전환·아젠다 | 30초 이내 | Naegle, 2021 |
| 평균 범위 | 1.5~2.5분 | 가중 평균 |

#### 1-3. 시간당 슬라이드 수 참고 범위

| 세션 시간 | 최소 (2.5분/장) | 최대 (1.5분/장) |
|----------|---------------|---------------|
| 50분 | 20장 | 33장 |
| 25분 | 10장 | 17장 |
| 30분 | 12장 | 20장 |

#### 1-4. 전체 합산 검증

```
total_final = sum(final_slides for all sessions)
total_grr   = slide_config.estimated_slides.total

if abs(total_final - total_grr) / total_grr > 0.30:
  → [경고] 전체 병합 결과가 GRR 1차 대비 ±30% 초과
  → 편차가 큰 세션 식별 후 조정
```

---

### Step 2: 슬라이드 유형 배정 (12유형) + GRR 단계별 배치

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~1 결과, brainstorm_result.md §1·§3·§5 |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

#### 2-1. GRR 단계별 주 유형 배정 규칙

| GRR 단계 | 주 유형 | 보조 유형 | AE 적용률 | 시각 밀도 |
|---------|--------|---------|----------|---------|
| 도입 (사태1~3) | 제목, 아젠다 | 인용, 이미지 | 선택적 | 중간 — 맥락 제공 |
| I Do (사태4~5) | 개념설명, 코드, 비교, 데이터+인사이트, 타임라인 | 이미지, 인용 | **≥80%** | **높음** — 풍부한 시각 자료 |
| We Do (사태5~6) | 실습/활동, 코드, 비교 | 개념설명 | **≥60%** | 중간 — 참여형 |
| You Do (사태6~7) | 실습/활동 | 코드, 핵심요약 | **≥30%** | **낮음** — 최소 시각 |
| 정리 (사태8~9) | 핵심요약, 실습/활동(Exit) | 섹션전환 | 선택적 | 중간 — 정리 |

**AE 적용률 근거**: Garner & Alley(2013)의 실험 결과, Body slides(I Do/We Do)에서 AE 구조가 이해도·기억 보존에 통계적으로 유의한 효과(p<.01). You Do는 과제 지시 중심이므로 비율 완화.

#### 2-2. 구조 슬라이드 자동 삽입 규칙

| 구조 슬라이드 | 삽입 위치 | 삽입 규칙 | AE 적용 |
|-------------|----------|----------|---------|
| 제목 | 세션 시작 | 모든 세션에 1장 | ✗ 예외 |
| 아젠다 | 제목 후 | 모든 세션에 1장 (세션 내 학습 순서 안내) | ✗ 예외 |
| 섹션전환 | GRR 단계 전환 | I Do→We Do 필수, We Do→You Do 선택적 | ✗ 예외 |
| 핵심요약 | 세션 마지막 | 정리 구간에 1장 (Exit 평가와 결합 가능) | ✗ 예외 |

#### 2-3. brainstorm §3 레이아웃 + §5 코드 워크스루 매핑

brainstorm_result.md §3의 세션별 레이아웃 배정과 §5의 코드 워크스루 계획을 기반으로, 각 슬라이드에 구체적 유형을 배정한다.

**배정 알고리즘**:

```
for each session:
  # 1. §1(AE 테이블)의 Evidence 유형으로 슬라이드 유형 결정
  for each ae_row in §1[session]:
    if ae_row.evidence_type in [다이어그램, 도표, 개념도]:
      → slide_type = "개념설명"
    elif ae_row.evidence_type == "코드":
      → slide_type = "코드"
      → §5에서 해당 코드의 워크스루 패턴 매핑 (줄별해설/빌드업/Before→After/에러→수정/확대경)
    elif ae_row.evidence_type == "비교":
      → slide_type = "비교"
    elif ae_row.evidence_type in [차트, 수치, 그래프]:
      → slide_type = "데이터+인사이트"
    elif ae_row.evidence_type == "이미지":
      → slide_type = "이미지"
    elif ae_row.evidence_type == "타임라인":
      → slide_type = "타임라인"
    elif ae_row.evidence_type == "인용문":
      → slide_type = "인용"
    elif ae_row.evidence_type in [체크리스트, 과제, 활동지시]:
      → slide_type = "실습/활동"

  # 2. 구조 슬라이드 추가 (Step 2-2)
  # 3. §3 레이아웃 합계와 final_slides 정합 확인
  layout_total = sum(§3[session] 12유형 합계)
  if abs(layout_total - final_slides) > 3:
    → 차이 원인 분석: 구조 슬라이드 미포함 or 콘텐츠 과잉/부족
    → 조정: layout_total > final_slides → 우선순위 낮은 슬라이드 병합
    → 조정: layout_total < final_slides → 분절 또는 보조 슬라이드 추가
```

#### 2-4. 코드 슬라이드 밀도 기준 (기술 교육 특화)

| 항목 | 기준 | 근거 |
|------|------|------|
| 코드 줄 수 | 10~15줄/슬라이드 | CLT in Computing Ed., ACM TOCSE 2022 |
| 하이라이트 | 설명 대상 줄만 강조, 나머지 불투명도 저감 | Split Attention 방지, Ginns 2006 |
| 코드+설명 배치 | 동일 슬라이드에 코드와 설명 인접 | Spatial Contiguity g=0.63 |
| 폰트 | 고정폭, 최소 18pt | 가독성 실무 기준 |
| 신택스 하이라이팅 | slide_tool 빌트인 사용 | slidev: Shiki, marp: code block |

코드가 15줄 초과 시 → 분절 슬라이드 시퀀스 또는 확대경 패턴 적용.

#### 2-5. 유형 분포 균형 검증

| # | 검증 항목 | 기준 | 위반 시 조치 |
|---|----------|------|------------|
| 1 | I Do 시각 슬라이드 | 개념설명+코드+비교+데이터 ≥ I Do 총장의 60% | 텍스트 전용 → 시각 자료 추가 |
| 2 | 코드 슬라이드 (hands-on 세션) | ≥ 해당 세션 총장의 30% | 코드 워크스루 추가 |
| 3 | 실습/활동 슬라이드 | ≥ 전체의 15% | 활동 슬라이드 추가 |
| 4 | 텍스트 전용 슬라이드 | ≤ 전체의 10% | 시각 자료 추가 (Mayer 멀티미디어 d=1.39) |

---

### Step 3: 슬라이드 시퀀스 + 전환 설계

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~2 결과, brainstorm_result.md §4 |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

#### 3-1. 세션 내 기본 시퀀스 (GRR 순서)

```
[제목] → [아젠다]
→ [도입 슬라이드 1~2장: 주의획득/목표고지]
→ [사전훈련 슬라이드 (해당 시, Pre-training)]
→ [I Do 슬라이드: 개념설명/코드/비교/데이터/타임라인...]
→ [섹션전환: I Do → We Do]
→ [We Do 슬라이드: 안내실습/발문/코드...]
→ [섹션전환: We Do → You Do (선택적)]
→ [You Do 슬라이드: 실습지시/체크리스트]
→ [핵심요약 / Exit 평가]
```

#### 3-2. Mayer Segmenting 원칙 적용 (d=0.79~0.98)

I Do 구간이 길 경우 분절 포인트를 삽입한다:

```
for each session:
  i_do_slides = I Do 구간 슬라이드 수

  if i_do_slides > 7:
    # 5~7장마다 확인 슬라이드(발문 또는 간단 퀴즈) 삽입
    insert_points = [5, 12, 19, ...]  # 7장 간격
    for point in insert_points:
      if point < i_do_slides:
        insert(확인_슬라이드, position=point)
        # 확인 슬라이드: 발문 1장 또는 Think-Pair-Share 1장
```

**분절 단위 근거**: Mayer(2020)의 Segmenting 연구에서 1~2문장 + 8~10초 해당 설명 단위가 최적. 슬라이드 맥락에서 5~7장(약 7~14분)이 하나의 의미 단위.

#### 3-3. Progressive Disclosure 전략 (brainstorm §4 반영)

brainstorm_result.md §4의 인터랙션 요소를 시퀀스에 반영한다:

| slide_tool | Progressive Disclosure 구현 | 코드 워크스루 구현 |
|-----------|--------------------------|----------------|
| slidev | `v-click`으로 동일 슬라이드 내 단계적 공개 | `{lines}` 속성으로 줄별 하이라이트, `<<< @/` Magic Move |
| marp | 동일 내용 + 요소 추가 분절 슬라이드 시퀀스 | 주석(`// ← 여기!`) + 분절 슬라이드 |
| revealjs | `fragment` | `data-line-numbers` |
| gamma | 분절 슬라이드 | 분절 슬라이드 |

**marp 분절 슬라이드 시 장 수 보정**: marp에서 Progressive Disclosure를 분절 슬라이드로 대체할 경우, 실제 장 수가 증가한다. 이를 final_slides에 반영:

```
if slide_tool == "marp":
  pd_count = §4에서 Progressive Disclosure 적용 대상 슬라이드 수
  marp_extra = pd_count × (평균 단계 수 - 1)  # 추가 분절 슬라이드
  # 단, 시간 계산에서는 분절 시퀀스를 1장으로 취급 (전환만 추가)
```

#### 3-4. 사전훈련 슬라이드 배치 (Mayer Pre-training d=0.85)

핵심 용어/개념이 처음 등장하는 세션의 I Do 시작 전에 용어 정의 슬라이드를 배치한다:

```
for each session:
  # 해당 세션에서 처음 등장하는 핵심 용어 추출
  new_terms = session의 SLO/하위 주제에서 이전 세션에 없는 기술 용어
  if len(new_terms) >= 3:
    # 용어 정의 슬라이드 1장 삽입 (아젠다 후, I Do 전)
    insert(pre_training_slide, after=아젠다, before=i_do_start)
    # 슬라이드 유형: 개념설명 (용어 + 간단 정의 + 아이콘)
```

**적용 조건**: 기술 교육(content_type == "hands-on" 또는 "concept")이고 신규 용어 3개 이상일 때. 초급 학습자(Bloom's L1~L2)에서 효과 극대화.

#### 3-5. 세션 간 전환 설계

| 전환 유형 | 적용 위치 | 슬라이드 수 | 내용 |
|----------|----------|-----------|------|
| 세션 내 GRR 전환 | I Do→We Do, We Do→You Do | 0~1장 (섹션전환) | GRR 단계 안내 + 활동 모드 변경 |
| 같은 Day 세션 간 | D{N}-{M} → D{N}-{M+1} | 0장 | 다음 세션의 제목 슬라이드가 전환 역할 |
| 같은 Day 블록 간 | AM→PM (점심 후) | 1장 | 오전 요약 + 오후 예고 |
| Day 간 전환 | D{N} 마지막 → D{N+1} 시작 | 1장 | Day 요약 + 다음 Day 예고 |

---

### Step 4: 시간 배분 + 검증 + architecture.md 통합 작성

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~3의 모든 결과 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/architecture.md` ★ 최종 산출물 |

**동작**:

#### 4-1. 슬라이드별 시간 배분

기본 시간 = session.duration_min / final_slides (균등 배분 기준)

유형별 시간 가중치를 적용하여 차등 배분한다:

| 슬라이드 유형 | 시간 가중치 | 근거 |
|-------------|-----------|------|
| 제목 | 0.5 | 빠르게 넘김 |
| 아젠다 | 0.7 | 구조 안내 (30초~1분) |
| 섹션전환 | 0.3 | 짧은 전환 (15~30초) |
| 개념설명 | 1.2 | AE 설명 시간 (1~2분) |
| 코드 | 1.5 | 코드 설명 + 하이라이트 단계 (2~3분) |
| 비교 | 1.3 | 양측 설명 (1.5~2분) |
| 데이터+인사이트 | 1.2 | 수치 해석 (1~2분) |
| 이미지 | 0.8 | 시각적 이해, 짧은 설명 |
| 타임라인 | 1.0 | 순차 설명 |
| 인용 | 0.5 | 짧은 강조 (30초) |
| 핵심요약 | 0.8 | 정리 (1분) |
| 실습/활동 | 1.5 | 활동 지시 + 실행 시간 (2~4분) |

**시간 배분 알고리즘**:

```
for each session:
  total_weight = sum(slide.type_weight for slide in session_slides)
  time_per_weight = session.duration_min / total_weight

  for each slide in session_slides:
    slide.time_min = round(slide.type_weight × time_per_weight, 1)

  # 반올림 오차 보정: 마지막 슬라이드에서 합계 맞춤
  diff = session.duration_min - sum(slide.time_min)
  session_slides[-1].time_min += diff
```

#### 4-2. 검증 체크리스트 (7항목)

모든 세션 설계 완료 후 다음 7항목을 검증한다:

| # | 검증 항목 | 기준 | 위반 시 조치 |
|---|----------|------|------------|
| 1 | 시간 합산 | 세션별 슬라이드 시간 합 = session.duration_min | 시간 재배분 |
| 2 | 분당 슬라이드 수 | 평균 1.5~2.5분/장 범위 | 슬라이드 추가/제거 |
| 3 | AE 적용률 | I Do ≥80%, We Do ≥60%, You Do ≥30% | 비AE 슬라이드를 AE로 변환 |
| 4 | One Idea Rule | 모든 슬라이드가 단일 개념 (요소 ≤6개) | 과밀 슬라이드 분할 |
| 5 | GRR 병합 편차 | 세션별 final vs GRR 1차 ±30% | 범위 초과 세션 조정 |
| 6 | 유형 분포 | 텍스트 전용 ≤10%, hands-on 세션 코드 ≥30% | 유형 교체 |
| 7 | Mayer 분절 | I Do 연속 ≤7장 (확인 슬라이드 없이) | 확인 슬라이드 삽입 |

검증 실패 시 해당 Step으로 돌아가 수정한다 (최대 2회 반복).

#### 4-3. architecture.md 통합 작성

Step 0~3의 결과와 검증 결과를 아래 구조로 통합하여 `{output_dir}/architecture.md`를 작성한다.

---

## 슬라이드 기획 architecture.md 산출물 구조

```markdown
# 슬라이드 아키텍처 설계

## 메타데이터
- 강의 주제: {topic}
- 설계 일자: {date}
- 설계 방법론: GRR 밀도 × AE 구조 × Mayer 원칙 (Middle-out 슬라이드 구조 설계)
- 변경 불가 기준: 교안 architecture.md (차시 구조/SLO/GRR 배분), input_data.json (session_manifest)
- 입력 소스: brainstorm_result.md (§1~§7), input_data.json
- 적용 연구: Garner & Alley(2013), Naegle(2021), Mayer(2020), CLT in CS Ed.(2022)

---

## §1. 변경 불가 기준 요약

### 1-1. 슬라이드 기획 설정

| 항목 | 값 | 출처 |
|------|-----|------|
| 슬라이드 도구 | {slide_tool} | slide_config |
| 디자인 톤 | {design_tone} | slide_config |
| 정보 밀도 | standard (25~55줄/장) | slide_config |
| 병합 공식 | round(0.6 × GRR + 0.4 × Content) | slide_config |
| 총 일수 | {days}일 | session_manifest |
| 총 세션 수 | {sessions}개 | session_manifest |
| 세션 시간 | {session_minutes}분 | session_manifest |

### 1-2. 세션 매니페스트 요약

| 세션 | 제목 | 시간 | content_type | Bloom's | SLO | GRR 1차 |
|------|------|------|-------------|---------|-----|---------|
| D1-1 | {title} | {min}분 | {type} | {level} | {slo} | {est}장 |
| ... | ... | ... | ... | ... | ... | ... |

---

## §2. 슬라이드 수 산출

### 2-1. 2단계 병합 결과

| 세션 | GRR 1차 | 콘텐츠 2차 | 병합 | 밀도 보정 | **최종** | 분/장 | 범위 |
|------|---------|----------|------|---------|---------|------|------|
| D1-1 | {n}장 | {n}장 | {n}장 | ×{보정} | **{n}장** | {n}분 | ✓/✗ |
| ... | ... | ... | ... | ... | ... | ... | ... |

### 2-2. 전체 요약

| Day | 세션 수 | 총 슬라이드 | 평균 분/장 |
|-----|--------|-----------|----------|
| Day 1 | {n} | {n}장 | {n}분 |
| ... | ... | ... | ... |
| **합계** | **{n}** | **{n}장** | **{n}분** |

### 2-3. content_type별 분포

| content_type | 세션 수 | 평균 슬라이드/세션 | 밀도 보정 |
|-------------|--------|----------------|----------|
| concept | {n} | {n}장 | ×1.0 |
| hands-on | {n} | {n}장 | ×0.9 |
| activity | {n} | {n}장 | ×0.8 |

---

## §3. 세션별 슬라이드 구조

### Day {N}: {테마}

#### D{N}-{M}: {세션 제목} ({final_slides}장, {duration}분)

| # | 슬라이드 유형 | GRR 단계 | Assertion 제목 | Evidence 유형 | 인터랙션 | 시간(분) |
|---|------------|---------|--------------|-------------|---------|---------|
| 1 | 제목 | 도입 | {세션 제목} | — | — | 0.5 |
| 2 | 아젠다 | 도입 | — | 목록 | — | 1.0 |
| 3 | 개념설명 | I Do | "{12단어 주장}" | 다이어그램 | {v-click/—} | 2.0 |
| 4 | 코드 | I Do | "{12단어 주장}" | 코드 블록 | {줄별 하이라이트} | 2.5 |
| 5 | 섹션전환 | — | "함께 실습해 봅시다" | 아이콘 | — | 0.5 |
| 6 | 실습/활동 | We Do | "{안내 실습 지시}" | 체크리스트 | — | 2.0 |
| ... | ... | ... | ... | ... | ... | ... |

**AE 적용률**: I Do {n}/{n} = {%}%, We Do {n}/{n} = {%}%, You Do {n}/{n} = {%}%
**Mayer 분절**: I Do 최대 연속 {n}장 → {확인 슬라이드 삽입 여부}
**코드 밀도**: 코드 슬라이드 {n}장 (코드 ≤15줄/장 기준 충족: {✓/✗})

(세션별 반복)

---

## §4. 슬라이드 유형 분포

### 4-1. 전체 유형 분포

| 슬라이드 유형 | 장 수 | 비율 | GRR 주 배치 |
|------------|------|------|-----------|
| 제목 | {n} | {%}% | 도입 |
| 아젠다 | {n} | {%}% | 도입 |
| 섹션전환 | {n} | {%}% | 전환 |
| 개념설명 | {n} | {%}% | I Do |
| 코드 | {n} | {%}% | I Do/We Do |
| 비교 | {n} | {%}% | I Do |
| 데이터+인사이트 | {n} | {%}% | I Do |
| 이미지 | {n} | {%}% | I Do |
| 타임라인 | {n} | {%}% | I Do |
| 인용 | {n} | {%}% | 도입/I Do |
| 핵심요약 | {n} | {%}% | 정리 |
| 실습/활동 | {n} | {%}% | We Do/You Do |

### 4-2. GRR 단계별 분포

| GRR 단계 | 슬라이드 수 | 비율 | 주 유형 |
|---------|-----------|------|--------|
| 도입 | {n} | {%}% | 제목, 아젠다, 인용 |
| I Do | {n} | {%}% | 개념설명, 코드, 비교, 데이터 |
| We Do | {n} | {%}% | 실습, 코드, 개념설명 |
| You Do | {n} | {%}% | 실습, 코드 |
| 정리 | {n} | {%}% | 핵심요약, 실습 |

---

## §5. 인터랙션 매핑 ({slide_tool})

| # | 세션 | 슬라이드 # | 인터랙션 유형 | 구현 방법 | marp 대체 |
|---|------|----------|------------|---------|----------|
| 1 | D{N}-{M} | #{n} | Progressive Disclosure | {v-click/fragment} | 분절 {n}장 |
| 2 | D{N}-{M} | #{n} | 코드 하이라이트 | {lines 속성} | 주석 하이라이트 |
| 3 | D{N}-{M} | #{n} | Magic Move | {<<< @/} | Before/After 2장 |
| ... | ... | ... | ... | ... | ... |

---

## §6. 코드 워크스루 매핑

| # | 세션 | 슬라이드 # | 코드 주제 | 패턴 | 줄 수 | 슬라이드 수 | 하이라이트 |
|---|------|----------|---------|------|------|-----------|----------|
| 1 | D{N}-{M} | #{n} | {API/문법} | 줄별 해설 | {n}줄 | {n}장 | 줄 {n}~{m} 순차 |
| 2 | D{N}-{M} | #{n} | {리팩토링} | Before→After | {n}줄 | 2장 | 전체 |
| ... | ... | ... | ... | ... | ... | ... | ... |

**코드 밀도 기준**: 10~15줄/슬라이드 (CLT in CS Ed., ACM TOCSE 2022)
**15줄 초과 시**: 분절 슬라이드 또는 확대경 패턴 적용

---

## §7. 시간 배분 요약

### 7-1. 세션별 시간 배분

| 세션 | 총 시간 | 도입 | I Do | We Do | You Do | 정리 | 분/장 |
|------|--------|------|------|-------|--------|------|------|
| D{N}-{M} | {min}분 | {min} | {min} | {min} | {min} | {min} | {n} |
| ... | ... | ... | ... | ... | ... | ... | ... |

### 7-2. 시간 가중치 테이블

| 슬라이드 유형 | 가중치 | 적용 장 수 | 배분 시간(분) |
|------------|--------|----------|-----------|
| 코드 | 1.5 | {n} | {min} |
| 개념설명 | 1.2 | {n} | {min} |
| 실습/활동 | 1.5 | {n} | {min} |
| 비교 | 1.3 | {n} | {min} |
| 데이터+인사이트 | 1.2 | {n} | {min} |
| 타임라인 | 1.0 | {n} | {min} |
| 이미지 | 0.8 | {n} | {min} |
| 핵심요약 | 0.8 | {n} | {min} |
| 아젠다 | 0.7 | {n} | {min} |
| 제목 | 0.5 | {n} | {min} |
| 인용 | 0.5 | {n} | {min} |
| 섹션전환 | 0.3 | {n} | {min} |

---

## §8. 검증 결과

| # | 검증 항목 | 기준 | 결과 | 상태 |
|---|----------|------|------|------|
| 1 | 시간 합산 | 세션별 합 = duration_min | {상세} | Pass/Fail |
| 2 | 분당 슬라이드 | 1.5~2.5분/장 | {범위} | Pass/Fail |
| 3 | AE 적용률 | I Do≥80%, We Do≥60%, You Do≥30% | {%} | Pass/Fail |
| 4 | One Idea Rule | 요소 ≤6개/슬라이드 | {위반 수} | Pass/Fail |
| 5 | GRR 병합 편차 | final vs GRR ±30% | {최대 편차} | Pass/Fail |
| 6 | 유형 분포 | 텍스트 전용 ≤10% | {%} | Pass/Fail |
| 7 | Mayer 분절 | I Do 연속 ≤7장 | {최대 연속} | Pass/Fail |

{위반 항목 있으면 조정 내역 기록}

---

## §9. 설계 결정 로그

| # | 결정 | 대안 | 선택 근거 |
|---|------|------|----------|
| 1 | {결정 내용} | {고려한 대안} | {근거} |
```
