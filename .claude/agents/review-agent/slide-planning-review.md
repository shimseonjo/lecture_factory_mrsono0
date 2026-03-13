# 슬라이드 기획 품질 검토 (Phase 5) 세부 워크플로우

### 설계 원칙

1. **교안 Phase 7 패턴 재사용**: 점진적 Write(중간 파일 → 통합), 인용 규칙(기대값/실제값/수정가이드), 3단계 판정(PASS/CONDITIONAL PASS/REVISION REQUIRED)
2. **슬라이드 기획 고유 검증 영역 독립 분리**: AE 구조(Assertion-Evidence), 4레이어 명세 품질, Mayer 멀티미디어 원칙, 도구별 구현 적합성
3. **41개 항목, 6개 영역**: GATE-4를 통과한 기획안의 **품질** 검증에 집중
4. **정량적 기준 최대화**: AE 적용률(I Do≥80%), 6×6 규칙, 분/장 범위(1.5~2.5), I Do 연속 ≤7장
5. **가중치 미적용**: 6개 영역 모두 "슬라이드 제작자가 기획안만으로 슬라이드를 정확히 구현할 수 있는가"에 수렴. Major/Minor 분류로 충분
6. **3단계 판정**: `shared/judgment-criteria.md` 참조

### 교안 Phase 7 vs 슬라이드 기획 Phase 5

| 차원 | 교안 Phase 7 | 슬라이드 기획 Phase 5 |
|------|-------------|---------------------|
| 검증 대상 | `block_D*.md` (교안+대본 통합 블록) + `session_D*.md` (교안 콘텐츠) | `slide_plan.md` (제작 지시서 — 4레이어 명세) |
| 검증 기준 파일 수 | 7개 | 5개 (architecture.md + brainstorm_result.md + input_data.json + session 파일들 + slide-plan-template.md) |
| 핵심 분량 | §4 교시당 80~120줄, 전체 4,000~6,000행 | §4 슬라이드당 25~55줄, 전체 2,000~8,000행 |
| 고유 검증 영역 | Gagne, GRR, 2-레이어, Think-Aloud, CMU 3점, 15분 분절, 발화문 자연성 | AE 구조, 4레이어 완전성, Mayer 원칙, 6×6, Progressive Disclosure, 도구 구현 |
| 검증 항목 수 | 51개 (S:7 + G:8 + P:7 + T:8 + C:12 + N:9) | **41개** (S:6 + D:7 + G:7 + T:6 + C:8 + I:7) |
| 선행 검증 | 없음 | **GATE-4 (6항목) 통과 후** — 파일 존재, 슬라이드 수, 시간, AE률, 세션 완전성, §1~§8 |
| 검토 모드 | 블록별 + 통합 | **세션별 + 통합** |

### 전체 흐름

```
[세션별 검토 모드] — 세션별 slides_*.md 독립 검증
  │
  ├── Step 0: 입력 로드 (해당 세션 + 참조 파일)
  ├── Step 1: 정보 밀도·시각 설계 검증 (D-1~D-7)
  ├── Step 2: GRR/AE 정렬 + 학습목표 검증 (G-1~G-7)
  ├── Step 3: 시간·수량 검증 (T-1~T-3, 세션 해당)
  ├── Step 4: 콘텐츠 정확성 검증 (C-1~C-8)
  ├── Step 5: 도구 구현 적합성 검증 (I-1~I-7)
  └── Step 6: 세션 판정 통합 → _review_session_{session_id}.md

[통합 검토 모드] — slide_plan.md 전체 크로스 체크
  │
  ├── Step 0: 입력 로드 + _review_session_*.md
  ├── Step 1: 구조 완전성 검증 (S-1~S-6)
  ├── Step 2: 크로스 세션 일관성 검증
  ├── Step 3: 집계 정합 검증 (T-4~T-6)
  └── Step 4: 세션별 검토 결과 통합 + 최종 판정 → quality_review.md
```

**점진적 Write 패턴**: 세션별 검토에서는 중간 파일 없이 단일 `_review_session_*.md`에 순차 Write한다. 통합 검토에서도 단일 `quality_review.md`에 직접 Write한다. 5개 입력 파일 + 41개 검증 결과를 동시에 메모리에 유지하는 부담을 세션별 분리로 해소한다.

### 산출물 목록

```
{output_dir}/
├── _review_session_{session_id}.md  # 세션별 검토 결과 (세션 수만큼)
└── quality_review.md                # 최종 품질 검토 결과 ★
```

### 위반 분류 (슬라이드 기획 기준)

| 유형 | 기준 | 예시 |
|------|------|------|
| **Major** | 슬라이드 제작자가 기획안만으로 슬라이드를 정확히 구현 불가능, 또는 학습 설계의 핵심 무결성 손상 | AE 적용률 I Do <80%, architecture §3 유형 변경, 근거 없는 콘텐츠 창작, 4레이어 체계적 누락, 다른 도구 문법 사용, 금지 패턴 체계적 위반 |
| **Minor** | 품질에 영향을 주나 제작 가능성과 핵심 설계는 유지됨 | 일부 슬라이드 밀도 역전, Assertion 명사구 1~5건, 하이라이트 미지정, brainstorm 소재 미활용 |

### 인용 규칙

`shared/judgment-criteria.md`의 인용 규칙을 따른다.

**예시**:

```
| D-1 | AE Assertion 품질 | D1-3 [SLIDE 5]의 Assertion이 명사구 "Spring Bean 등록" — 주장 문장이 아님 | architecture §3 D1-3 #5: "Spring Bean 등록은 @Component 스캔으로 자동화된다" | slides_D1-3.md [SLIDE 5] CONTENT: "Spring Bean 등록" | Assertion을 완전한 서술문으로 재작성 |
```

---

## 세션별 검토 모드

오케스트레이터가 세션별로 review-agent를 호출한다. 구조 완전성(S-1~S-6)은 통합 검토에서 수행하므로 **생략**한다.

### Step 0: 입력 로드

| 항목 | 내용 |
|------|------|
| 입력 | 해당 세션 slides_*.md + 5개 참조 파일 |
| 도구 | Read |
| 산출물 | (내부 컨텍스트) |

**동작**:

1. 해당 세션의 `slides_D{day}-{num}.md` Read — 검증 대상
2. 참조 파일 5개 Read:
   - `{output_dir}/architecture.md` §3: 슬라이드 골격 (유형, GRR, AE, 시간) — **변경 불가 기준**
   - `{output_dir}/brainstorm_result.md` §1~§5: 시각화·레이아웃·인터랙션 소재
   - `{output_dir}/input_data.json`: slide_config, session_manifest, source_script
   - session 파일: `{source_script.lecture_root}/02_script/session_D{day}-{num}.md` — 콘텐츠 원본
   - `.claude/templates/slide-plan-template.md`: 4레이어 표기법 기준

**파일별 역할**:

| # | 파일 | 역할 | 검증 단계 |
|---|------|------|----------|
| 1 | `slides_D{day}-{num}.md` | **검증 대상** | Step 1~5 |
| 2 | `architecture.md` §3 | 슬라이드 골격·유형·시간 기준 | Step 2, 3, 4 |
| 3 | `brainstorm_result.md` | 시각화·레이아웃·인터랙션 소재 원본 | Step 1, 4 |
| 4 | `input_data.json` | slide_config, session_manifest | Step 1, 2, 3, 5 |
| 5 | `session_D{day}-{num}.md` | 콘텐츠 원본 (발화문/코드/발문) | Step 4 |

---

### Step 1: 정보 밀도 + 시각 설계 검증

| 항목 | 내용 |
|------|------|
| 입력 | slides_*.md, architecture.md, brainstorm_result.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md`에 순차 Write |

이 Step은 슬라이드 기획 **고유**의 시각 설계 품질을 검증한다. AE 구조, Mayer 원칙, 인지 부하 이론(CLT) 기반의 정량적 기준을 적용한다.

**체크리스트**:

#### 1-1. AE Assertion + Evidence

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | D-1 | AE Assertion 품질 | AE 대상 슬라이드의 CONTENT AE Assertion이 완전한 주장 문장(서술문, 주어+동사+목적어). 명사구 제목 금지 (예: "Spring Boot 자동 설정" ✗). 2줄 이내 (Alley AE Framework). 구조 슬라이드(제목/아젠다/섹션전환/핵심요약) 예외 | Major (AE 대상 슬라이드의 30%+에서 명사구 Assertion), Minor (1~5슬라이드) |
| 2 | D-2 | AE Evidence 시각 증거 | AE 대상 슬라이드의 CONTENT에 시각 증거 지시 존재 (다이어그램/코드/이미지/차트). 불릿 목록만으로 Evidence 구성 시 AE 원칙 위반 (Garner & Alley 2013, p<.01). VISUAL 레이어에 Evidence를 뒷받침하는 구체적 시각 지시 존재 | Major (I Do AE 대상에서 시각 증거 없이 텍스트만), Minor (We Do/You Do에서 텍스트만) |

#### 1-2. 정보 밀도 + CLT

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 3 | D-3 | 6×6 규칙 | CONTENT 핵심 텍스트 6줄 이내, 줄당 6단어 이내. 슬라이드당 시각 요소 ≤6개 (Naegle 2021: 6개 초과 시 인지 부하 500% 증가) | Major (전체 슬라이드의 10%+에서 위반), Minor (1~5슬라이드) |
| 4 | D-4 | 정보 밀도 줄 수 | 슬라이드별 명세(4레이어 전체) 25~55줄 범위 (info_density_lines). 15줄 미만 = 불충분, 60줄 초과 = 과도 | Major (20%+가 범위 이탈), Minor (5~20%) |

#### 1-3. VISUAL + Mayer 원칙

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 5 | D-5 | VISUAL 레이어 충실도 | I Do/We Do 슬라이드에 구체적 시각 자료 지시 존재 (다이어그램 유형, 색상, 아이콘 등). 코드+설명 동일 슬라이드 배치 (Mayer 공간근접 d=0.79). 단순 "레이아웃: default" 만 있는 I Do 슬라이드 검출 | Major (I Do의 50%+에서 구체적 시각 지시 없음), Minor (1~5슬라이드) |
| 6 | D-6 | 텍스트 전용 슬라이드 비율 | VISUAL 레이어에 시각 자료 지시가 없는 슬라이드 비율 ≤10% (Mayer 멀티미디어 d=1.67) | Major (15%+), Minor (10~15%) |
| 7 | D-7 | Mayer 중복성 원칙 | SPEAKER_NOTE 발화큐와 CONTENT 핵심 텍스트가 동일 내용 중복 (Mayer 잉여 d=0.87). 발화큐는 구두 설명 큐이므로 슬라이드 텍스트와 달라야 함 | Minor (중복 검출 슬라이드) |

**동작**: D-1~D-7 검증 결과를 `_review_session_{session_id}.md`에 Write한다.

---

### Step 2: GRR/AE 정렬 + 학습목표 검증

| 항목 | 내용 |
|------|------|
| 입력 | slides_*.md, architecture.md §3, input_data.json |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md`에 순차 Write (append) |

**체크리스트**:

#### 2-1. AE 적용률

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | G-1 | AE 적용률 기준 | GRR 구간별 AE 적용률: I Do ≥80%, We Do ≥60%, You Do ≥30%. §4 실제 슬라이드에서 AE Assertion+Evidence 존재 슬라이드를 GRR 구간별로 카운팅하여 검증. Garner & Alley (2013): Body slides에서 AE 구조가 p<.01 유의 | Major (I Do <80% 또는 We Do <60%), Minor (You Do <30%) |

#### 2-2. GRR 구조

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 2 | G-2 | GRR 시퀀스 순서 | 세션 내 슬라이드 시퀀스가 GRR 순서 준수: 도입→I Do→We Do→You Do→정리. I Do→You Do 점프 (We Do 생략) 검출 | Major (We Do 생략 세션 존재), Minor (GRR 단계 태그 누락이나 순서는 올바름) |
| 3 | G-3 | GRR 시각 밀도 차이 | I Do: VISUAL 풍부 (다이어그램/코드/이미지), We Do: 참여형 (빈칸/TODO 강조), You Do: 최소 (과제 지시/체크리스트). I Do의 VISUAL 항목 수 > We Do > You Do 순서 확인 | Minor (밀도 역전 검출 — You Do가 I Do보다 시각 요소 많음) |

#### 2-3. 학습목표 + 분절

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 4 | G-4 | SLO 커버리지 | 세션의 SLO 핵심 개념이 해당 세션 슬라이드 CONTENT에 반영. SLO에서 언급한 기술/개념이 최소 1개 이상의 [SLIDE] CONTENT에 존재 | Major (SLO 핵심 개념이 슬라이드에 전혀 없는 세션) |
| 5 | G-5 | Mayer 분절 | I Do 구간에서 확인 슬라이드(발문/퀴즈/섹션전환) 없이 연속 ≤7장. Mayer Segmenting d=0.98 (Mayer 2009) | Major (10장+ 연속), Minor (8~9장 연속) |
| 6 | G-6 | 구조 슬라이드 배치 | 세션에 제목(1장)+아젠다(1장)+핵심요약(1장) 존재. I Do→We Do 전환에 섹션전환 슬라이드 존재. architecture §3 구조 슬라이드 배치와 일치 | Major (제목/아젠다/핵심요약 중 누락), Minor (섹션전환 누락) |
| 7 | G-7 | 사전훈련 슬라이드 | 신규 기술 용어 ≥3개인 세션에 사전훈련(Pre-training) 슬라이드 존재 (Mayer d=0.46). 비기술 교육(keywords에 기술 라이브러리 없음) 시 자동 Pass | Minor (해당 세션에 사전훈련 슬라이드 없음) |

**동작**: G-1~G-7 검증 결과를 `_review_session_{session_id}.md`에 순차 Write한다.

---

### Step 3: 시간 + 수량 검증 (세션 해당분)

| 항목 | 내용 |
|------|------|
| 입력 | slides_*.md, architecture.md §3, input_data.json |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md`에 순차 Write (append) |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | T-1 | 세션별 시간큐 합산 | SPEAKER_NOTE 시간큐의 합 = 해당 세션 duration_min | Major (5분+ 차이), Minor (1~4분 차이) |
| 2 | T-2 | 분/장 범위 | 세션별 평균 = duration_min / slides_count. 범위: 1.5~2.5분/장 | Major (1.0분 미만 또는 3.0분 초과), Minor (경계 1.0~1.5 또는 2.5~3.0) |
| 3 | T-3 | 슬라이드 수 architecture 일치 | slides_*.md의 [SLIDE] 블록 수 = architecture.md §3 해당 세션 슬라이드 수 | Major (불일치) |

**동작**: T-1~T-3 검증 결과를 `_review_session_{session_id}.md`에 순차 Write한다.

---

### Step 4: 콘텐츠 정확성 검증 — Anti-Hallucination

| 항목 | 내용 |
|------|------|
| 입력 | slides_*.md, architecture.md §3, brainstorm_result.md, session 파일 |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md`에 순차 Write (append) |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | C-1 | architecture §3 슬라이드 1:1 매핑 | architecture.md §3의 모든 슬라이드 행이 §4에서 [SLIDE] 블록으로 1:1 대응. 누락 또는 추가 검출 | Major (매핑 누락 또는 추가) |
| 2 | C-2 | 슬라이드 유형 원본 일치 | §4의 각 [SLIDE]의 유형(12유형)이 architecture.md §3에서 배정한 유형과 동일 | Major (유형 변경) |
| 3 | C-3 | Assertion 제목 원본 부합 | §4의 AE Assertion이 architecture.md §3의 Assertion 제목과 의미적으로 부합. 완전히 다른 주장으로 변경 검출 | Major (Assertion 의미 변경 — AE 구조 핵심 무결성) |
| 4 | C-4 | session 발화문 추출 | SPEAKER_NOTE 발화큐가 session 파일의 `> "..."` 발화문에서 추출된 것인지. session에 없는 내용 창작 검출 | Major (근거 없는 발화큐 창작) |
| 5 | C-5 | session 코드 추출 | CONTENT 코드 블록이 session 파일의 fenced code block과 일치 (15줄 이내 발췌). session에 없는 코드 창작 검출 | Major (근거 없는 코드 창작) |
| 6 | C-6 | session 발문 추출 | SPEAKER_NOTE 발문이 session 파일의 `❓ [LN]` 발문에서 추출된 것인지 | Major (근거 없는 발문 창작) |
| 7 | C-7 | brainstorm 시각화 활용 | VISUAL 시각화 지시가 brainstorm_result.md §2 시각화 아이디어 또는 §3 레이아웃 후보를 반영. §7 Decision Log에서 ADOPT된 아이디어의 활용률 | Minor (ADOPT된 아이디어가 20%+ 미활용) |
| 8 | C-8 | 콘텐츠 창작 검출 | §4 CONTENT에 입력 파일(architecture, session, brainstorm)에 없는 새로운 콘텐츠(개념, 코드, 사실, 수치) 신규 생성 검출. writer-agent "콘텐츠 창작 금지" 위반 여부 | Major (근거 없는 팩트 창작) |
| 9 | C-9 | session 핵심 콘텐츠 활용도 | session 파일의 ★ 핵심 예시 코드, 발문(❓), 비유/메타포가 기획안 §4에 1개 이상 반영되었는지. session에서 ★ 마커가 붙은 코드 블록 → CONTENT에 대응 슬라이드 존재, ❓ 발문 → SPEAKER_NOTE 또는 CONTENT에 반영, 비유 키워드 → VISUAL 또는 CONTENT에 반영 여부 확인 | Minor (핵심 콘텐츠 미활용 — 품질 저하) |

**동작**: C-1~C-9 검증 결과를 `_review_session_{session_id}.md`에 순차 Write한다.

---

### Step 5: 도구 구현 적합성 검증

| 항목 | 내용 |
|------|------|
| 입력 | slides_*.md, input_data.json (slide_config), brainstorm_result.md §4 |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md`에 순차 Write (append) |

이 Step은 IMPL_HINT 레이어가 지정된 slide_tool에 맞는 올바른 문법을 사용하는지 검증한다.

**도구별 올바른 문법 참조**:

| 항목 | marp | slidev | revealjs | gamma |
|------|------|--------|----------|-------|
| frontmatter | `marp: true` | `theme: seriph` | `transition: slide` | 없음 |
| 레이아웃 | `_class: lead/invert` | `layout: cover/two-cols` | HTML class | 없음 |
| 페이지 번호 | `_paginate: false` | — | — | — |
| 코드 하이라이트 | ````java {1-3,7}`` | ````java {1\|3-5\|7}`` | `data-line-numbers="1\|2-3"` | 없음 |
| Progressive Disclosure | 분절 슬라이드 시퀀스 | `v-click`, `v-clicks` | `class="fragment"` | 분절 슬라이드 |
| Magic Move | ✗ (전후 비교 슬라이드) | `magic-move` | ✗ (전후 비교) | ✗ |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | I-1 | IMPL_HINT slide_tool 정합 | IMPL_HINT의 frontmatter/layout/directive가 slide_config.slide_tool의 올바른 문법 사용. 다른 도구 문법 혼용 검출 (예: marp 프로젝트에서 `layout: two-cols` slidev 문법 사용) | Major (10%+ 슬라이드에서 다른 도구 문법), Minor (1~5슬라이드) |
| 2 | I-2 | Progressive Disclosure 구현 | 인터랙션 슬라이드에서 도구별 올바른 Progressive Disclosure 지시. 도구 미지원 기능 사용 검출 (예: marp에서 v-click 사용) | Minor (도구 미지원 기능 지시) |
| 3 | I-3 | 코드 하이라이트 구현 | 코드 슬라이드의 IMPL_HINT에 하이라이트 줄 번호 지정. 도구별 올바른 문법. 기술 교육 시 하이라이트 미지정 검출 | Minor (하이라이트 미지정 코드 슬라이드) |
| 4 | I-4 | 코드 줄 수 제한 | 코드 슬라이드 CONTENT 코드 ≤15줄 (CLT 기반, Split Attention 방지). 초과 시 §7-2 분절 계획 또는 확대경 패턴 | Major (15줄 초과 + 분절 계획 없음), Minor (15줄 초과 + 분절 계획 존재하나 불충분) |
| 5 | I-5 | 디자인 톤 일관성 | §8-3 디자인 톤 가이드의 색상/폰트/배경이 IMPL_HINT에서 일관 적용. input_data.json design_tone과 부합 | Minor (톤 불일치 슬라이드) |
| 6 | I-6 | 레이아웃-유형 정합 | VISUAL 레이아웃이 §3-2 12유형별 레이아웃 가이드와 일치. 필수 요소 존재 + 금지 패턴 위반 검출 (예: 코드 유형에 15줄 초과, 비교 유형에 4항목+, 아젠다에 6항목+) | Major (금지 패턴 체계적 위반), Minor (필수 요소 누락 1~5슬라이드) |
| 7 | I-7 | 코드 워크스루 패턴 | 코드 슬라이드의 워크스루 패턴(줄별해설/빌드업/Before→After/에러→수정/확대경)이 코드 내용에 적합. 새 API→줄별해설, 작성 과정→빌드업, 리팩토링→Before→After, 오개념→에러→수정, 대규모 탐색→확대경 | Minor (패턴 미지정 코드 슬라이드) |

**동작**: I-1~I-7 검증 결과를 `_review_session_{session_id}.md`에 순차 Write한다.

---

### Step 6: 세션 판정 통합

| 항목 | 내용 |
|------|------|
| 입력 | Step 1~5에서 Write한 `_review_session_{session_id}.md` |
| 도구 | Read, Write |
| 산출물 | `_review_session_{session_id}.md` 판정 추가 (append) |

**동작**:

1. `_review_session_{session_id}.md`를 Read하여 D/G/T/C/I 검증 결과 로드
2. 세션별 Major/Minor 위반 집계
3. 세션 판정: `shared/judgment-criteria.md` 기준
4. 판정 + 수정 가이드를 `_review_session_{session_id}.md` 하단에 append Write

**세션 판정 결과 포함 항목**:
- 세션 ID, 슬라이드 수, 검증 항목 수
- Major/Minor 위반 수
- 판정 (PASS/CONDITIONAL PASS/REVISION REQUIRED)
- Major 위반 목록 + 수정 가이드 (REVISION REQUIRED 시)

---

## 통합 검토 모드

세션별 검토 완료 후, slide_plan.md 전체의 구조 완전성과 세션 간 일관성을 검증한다.

### Step 0: 입력 로드

| 항목 | 내용 |
|------|------|
| 입력 | slide_plan.md + _review_session_*.md + architecture.md + input_data.json |
| 도구 | Read |
| 산출물 | (내부 컨텍스트) |

**동작**:

1. `{output_dir}/slide_plan.md` Read — 병합된 전체 기획안
2. `{output_dir}/_review_session_*.md` 전부 Read — 세션별 검토 결과
3. `{output_dir}/architecture.md` Read — 구조 기준
4. `{output_dir}/input_data.json` Read — session_manifest

---

### Step 1: 구조 완전성 검증

| 항목 | 내용 |
|------|------|
| 입력 | slide_plan.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `quality_review.md`에 Write |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | S-1 | §1~§8 섹션 완전성 | slide_plan.md에 §1(기획 개요), §2(공통 가이드), §3(표기법), §4(세션별 명세), §5(유형 분포), §6(인터랙션), §7(코드 워크스루), §8(제작 참고) 8개 섹션 모두 존재 | Major (누락 섹션당) |
| 2 | S-2 | 세션 메타 정합 | 각 세션의 메타(SLO, content_type, GRR 배분, 슬라이드 수, AE 적용률)가 input_data.json session_manifest와 일치 | Major (SLO/content_type 변경), Minor (GRR 시간 ±2분 차이) |
| 3 | S-3 | 표기법 일관성 | §3-1에서 정의한 4레이어 표기법(CONTENT/VISUAL/SPEAKER_NOTE/IMPL_HINT)이 §4 전체에서 일관 사용. 레이어 명칭 변형 검출 | Major (체계적 혼용 50%+ 슬라이드), Minor (산발적 1~5슬라이드) |
| 4 | S-4 | 슬라이드 번호 연속성 | 각 세션 내에서 [SLIDE 1]~[SLIDE N] 빠짐없이 연속. 중복/건너뛴 번호 검출 | Major (번호 중복/누락) |
| 5 | S-5 | 4레이어 완전성 | 모든 [SLIDE] 블록에 CONTENT/VISUAL/SPEAKER_NOTE/IMPL_HINT 4레이어 존재. 빈 레이어(레이어 제목만, 내용 없음) 검출 | Major (레이어 누락 10%+ 슬라이드), Minor (내용 부실 1~5슬라이드) |
| 6 | S-6 | 플레이스홀더 잔존 | `{중괄호}` 플레이스홀더 잔존 검출. 학습자용 양식 내부 `[직접 입력]` 제외 | Major (5개+), Minor (1~4개) |

---

### Step 2: 크로스 세션 일관성 검증

| 항목 | 내용 |
|------|------|
| 입력 | slide_plan.md, _review_session_*.md |
| 도구 | Read, Write |
| 산출물 | `quality_review.md`에 순차 Write (append) |

**동작**:

1. **AE 스타일 통일**: 세션 간 Assertion 문장 톤·길이가 일관적인지 (전체적으로 서술문 형식 유지)
2. **디자인 톤 통일**: 세션 간 IMPL_HINT의 색상/레이아웃/폰트가 일관적인지
3. **전환 일관성**: 세션 간 전환 슬라이드(마지막 핵심요약 → 다음 제목)의 전환 패턴 일관적
4. **용어 통일**: 동일 개념에 대해 세션마다 다른 용어 사용 검출

검출 결과를 `quality_review.md`에 순차 Write한다. (별도 검증 ID 없이 서술형으로 기록)

---

### Step 3: 집계 정합 검증

| 항목 | 내용 |
|------|------|
| 입력 | slide_plan.md |
| 도구 | Read, Write |
| 산출물 | `quality_review.md`에 순차 Write (append) |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | T-4 | §5 유형 분포 집계 정합 | §5-1 전체 유형별 분포 집계 = §4 실제 슬라이드 유형 카운트. 12유형별 수량 일치 | Major (합계 불일치 — 50%+ 유형에서 차이), Minor (일부 유형에서 1~2장 차이) |
| 2 | T-5 | §6 인터랙션 목록 정합 | §6 인터랙션 목록의 슬라이드가 §4에서 실제 인터랙션(IMPL_HINT interaction non-empty)이 있는 슬라이드와 일치 | Major (50%+ 불일치), Minor (일부 불일치) |
| 3 | T-6 | §7 코드 워크스루 목록 정합 | §7-1 코드 슬라이드 목록이 §4에서 유형 "코드"인 슬라이드와 일치. 줄 수, 하이라이트 범위, 워크스루 패턴 일치 | Major (코드 슬라이드 누락), Minor (하이라이트/패턴 불일치) |

---

### Step 4: 세션별 검토 결과 통합 + 최종 판정

| 항목 | 내용 |
|------|------|
| 입력 | Step 1~3 결과 + _review_session_*.md |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/quality_review.md` ★ 최종 산출물 |

**동작**:

1. `_review_session_*.md` 전부 Read → 세션별 위반 사항 통합
2. Step 1~3의 구조/일관성/집계 검증 결과 통합
3. **전체 위반 집계**: Major/Minor 위반 수 카운트
4. **판정 결정**: `shared/judgment-criteria.md`의 판정 기준에 따라 판정
5. **quality_review.md 작성**: 아래 구조에 따라 작성

---

## quality_review.md 산출물 구조

```markdown
# 슬라이드 기획 품질 검토 결과

## 메타데이터

| 항목 | 값 |
|------|-----|
| 검토 일자 | {date} |
| 검토 대상 | slide_plan.md (Phase 4 산출물) |
| 검토 기준 | AE 구조 + Mayer 원칙 + GRR 밀도 + 6×6 규칙 + Anti-Hallucination + 도구 구현 |
| 검증 항목 수 | 41개 (S:6 + D:7 + G:7 + T:6 + C:8 + I:7) |
| 판정 | {PASS / CONDITIONAL PASS / REVISION REQUIRED} |

---

## 1. 검토 요약

| 영역 | 검증 항목 수 | Pass | Fail (Major) | Fail (Minor) |
|------|------------|------|-------------|-------------|
| 구조 완전성 (S) | 6 | {N} | {N} | {N} |
| 정보 밀도·시각 설계 (D) | 7 | {N} | {N} | {N} |
| GRR/AE 정렬 (G) | 7 | {N} | {N} | {N} |
| 시간·수량 (T) | 6 | {N} | {N} | {N} |
| 콘텐츠 정확성 (C) | 8 | {N} | {N} | {N} |
| 도구 구현 적합성 (I) | 7 | {N} | {N} | {N} |
| **합계** | **41** | {N} | {N} | {N} |

---

## 2. 검증 상세

41개 검증 항목 전체의 Pass/Fail 결과를 기록한다.

| # | 검증 ID | 영역 | 결과 | 상세 |
|---|---------|------|------|------|
| 1 | S-1 | 구조 완전성 | {Pass/Major/Minor} | {검증 결과 요약} |
| 2 | S-2 | 구조 완전성 | {Pass/Major/Minor} | {검증 결과 요약} |
| ... | ... | ... | ... | ... |
| 41 | I-7 | 도구 구현 적합성 | {Pass/Major/Minor} | {검증 결과 요약} |

---

## 3. Major 위반 사항

{Major 위반이 없으면: "Major 위반 없음"}

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (slide_plan) | 해당 세션/슬라이드 | 수정 가이드 |
|---|---------|------|----------|-------------|-------------------|------------------|-----------|
| 1 | {D-1 등} | {영역} | {구체적 위반 내용} | {원본 파일명 §섹션의 값} | {slide_plan §4 세션/슬라이드의 값} | {D{N}-{M} #슬라이드} | {수정 방법} |

---

## 4. Minor 위반 사항

{Minor 위반이 없으면: "Minor 위반 없음"}

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (slide_plan) | 해당 세션/슬라이드 | 수정 권고 |
|---|---------|------|----------|-------------|-------------------|------------------|----------|
| 1 | {I-3 등} | {영역} | {구체적 위반 내용} | {원본 파일명 §섹션의 값} | {slide_plan §4 세션/슬라이드의 값} | {D{N}-{M} #슬라이드} | {권고 사항} |

---

## 5. 우수 사항

| # | 영역 | 우수 내용 |
|---|------|----------|
| 1 | {영역} | {구체적 우수 사항} |

---

## 6. 수정 우선순위

{PASS인 경우: 이 섹션 생략}

위반 항목을 수정 영향 범위 기준으로 정렬한다. 상위 항목부터 수정해야 연쇄 수정을 최소화한다.

| 순위 | 검증 ID | 위반 유형 | 이유 | 예상 영향 범위 |
|------|---------|----------|------|-------------|
| 1 | {C-1 등} | {Major/Minor} | {이 항목을 먼저 수정해야 하는 이유} | {영향받는 세션/슬라이드 목록} |
| 2 | {D-1 등} | {Major/Minor} | {이유} | {세션/슬라이드 목록} |

---

## 7. 최종 판정

**판정**: {PASS / CONDITIONAL PASS / REVISION REQUIRED}

**판정 근거**:
- Major 위반: {N}개
- Minor 위반: {N}개
- 총 검증 항목: 41개 중 Pass {N}개

{CONDITIONAL PASS인 경우}:
**권고 수정 사항**: §6 수정 우선순위 순서대로 Minor 위반을 수정한 뒤 재검토 권장.

{REVISION REQUIRED인 경우}:
**필수 수정 사항**: §6 수정 우선순위 순서대로 Major 위반의 수정 가이드를 따라 해당 세션/슬라이드를 재작성해야 합니다. 재작성 대상 세션: {_review_session_*.md에서 REVISION REQUIRED 판정된 세션 ID 목록}
```
