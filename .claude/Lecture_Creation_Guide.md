# Lecture Creation Guide - 강의 제작 파이프라인 가이드

Lecture Factory 프로젝트의 전체 강의 제작 워크플로우를 정의합니다.

## 전체 파이프라인 개요

```
/lecture-outline  →  /lecture-script   →  /slide-planning    →  /slide-generation
  강의구성안             강의교안            슬라이드 기획         슬라이드 생성 프롬프트
  (7단계)               (8단계)             (5단계)              (3단계)
```

각 워크플로우는 독립 실행 가능하며, 이전 단계의 산출물을 입력으로 참조합니다.

---

## 아키텍처

### Skill 오케스트레이터 패턴

Skill이 직접 오케스트레이터 역할을 하며, `Agent` 도구로 공통 에이전트를 순차 호출합니다.

```
/lecture-outline (Skill = 오케스트레이터)
     ├── Phase 1: Agent → input-agent
     ├── Phase 2: Agent → research-agent (탐색적 리서치)
     ├── Phase 3: Agent → brainstorm-agent
     ├── Phase 4: Agent → research-agent (심화 리서치)
     ├── Phase 5: Agent → architecture-agent
     ├── Phase 6: Agent → writer-agent
     └── Phase 7: Agent → review-agent
```

- Skill → Agent 호출 (허용)
- Agent → Agent 중첩 (금지)

### 6개 공통 에이전트

| 에이전트 | 역할 | 사용 워크플로우 |
|---------|------|--------------|
| **input-agent** | 사용자 입력 수집 + 이전 산출물 로드 + 컨텍스트 구성 | 구성안, 교안, 슬기획, 슬생성 |
| **brainstorm-agent** | 아이디어 확장, 구체화, 우선순위 분류 | 구성안, 교안, 슬기획 |
| **research-agent** | 인터넷 리서치, 트렌드 분석, 자료 수집 (2-Pass: 탐색적 + 심화) | 구성안, 교안 |
| **architecture-agent** | 구조 설계, 정렬 맵, Backward Design 적용 | 구성안, 교안, 슬기획 |
| **writer-agent** | 최종 문서/콘텐츠 생성 (템플릿 기반) | 구성안, 교안, 슬기획, 슬생성 |
| **review-agent** | 품질 검증, 체크리스트 평가, 피드백 생성 | 구성안, 교안, 슬기획, 슬생성 |

에이전트는 Skill이 전달하는 컨텍스트(지시사항 + 템플릿)에 따라 워크플로우별로 다르게 동작합니다.

---

## 워크플로우 상세

### 워크플로우 1: 강의구성안 (`/lecture-outline`)

**목적**: 강의의 전체 설계도를 작성합니다.

| Phase | 단계 | 에이전트 | 핵심 작업 |
|-------|------|---------|----------|
| 1 | 입력 수집 | input-agent | 필수 6개(주제, 학습자, 목표, 형태, 시간, 키워드) + 선택 7개 → input_data.json |
| 2 | 탐색적 리서치 | research-agent | 참고자료 분석(로컬 폴더 + NotebookLM) + 트렌드, 유사 강의 (문제 공간 이해) |
| 3 | 브레인스토밍 | brainstorm-agent | 하위 주제 도출, 학습자 페르소나, 핵심 질문, Bloom's 매핑, 콘텐츠 우선순위(핵심/중요/참고) |
| 4 | 심화 리서치 | research-agent | 브레인스토밍 결과 기반 사례 수집, 참고자료 심화 분석, 참고문헌, 보충 콘텐츠 |
| 5 | 아키텍처 설계 | architecture-agent | Backward Design(학습결과→평가→학습경험), 정렬 맵, 차시 구조, 시간 배분 |
| 6 | 구성안 작성 | writer-agent | outline-template.md 기반 최종 문서 생성 |
| 7 | 품질 검토 | review-agent | QM Rubric, Bloom's 정렬, 목표-활동-평가 정렬, 시간 배분, 자료 정확성 |

**적용 프레임워크**: Backward Design + GAIDE + 2-Pass Research + 프롬프트 체이닝

#### Phase 1: 입력 수집 상세

**필수 질문 (6개)** — 답변 필수, 없으면 진행 불가

| # | 카테고리 | 질문 | 입력 형태 |
|---|---------|------|----------|
| Q1 | 핵심 주제 | 무엇을 가르치나요? | 자유 텍스트 |
| Q2 | 대상 학습자 | 누구를 가르치나요? | 자유 텍스트 + 수준(입문/중급/고급) |
| Q3 | 학습 목표 | 강의 후 학습자가 무엇을 할 수 있어야 하나요? | 자유 텍스트 (측정 가능 행동 동사) |
| Q4 | 강의 형태 | 어떤 형태로 진행하나요? | 선택지 (기본값: 강의/오프라인) |
| Q5 | 시간·차시 | 시간 구성은? | 프리셋 (기본값: 집중 워크숍 5일×8h, 50분+10분) |
| Q6 | 핵심 키워드 | 반드시 다뤄야 할 주제나 기술은? | 자유 텍스트 |

**선택 질문 (7개)** — 기본값 존재, 미입력 시 자동 적용

| # | 카테고리 | 기본값 |
|---|---------|--------|
| Q7 | 선수 지식 | 없음 (초급부터) |
| Q8 | 제외 범위 | 없음 |
| Q9 | 평가 방식 | 형성평가 (퀴즈+실습) |
| Q10a | 교수 전략 | PBL + AI-first, 실습 50%+ |
| Q10b | 톤·스타일 | 비유 중심 설명 + 메타포 목록 |
| Q11 | 참고 자료 | 없음 (로컬 폴더 경로 / NotebookLM URL, 수집만) |
| Q12 | 맥락 | 독립 강의 |

Q11 참고 자료는 **경로/URL만 수집**하며, 실제 분석은 Phase 2 탐색적 리서치에서 수행:
- 로컬 폴더 → research-agent가 Glob+Read로 스캔·분석
- NotebookLM → research-agent가 NBLM 스킬로 소스 쿼리

스키마: `.claude/templates/input-schema.json` 참조

#### 2-Pass Research 설계 근거

- ADDIE, SAM, Double Diamond 등 모든 주요 교수설계 프레임워크가 분석/리서치를 아이디어 생성 이전에 배치
- Minas et al.(2018) — 사전 프라이밍이 아이디어의 수량, 참신성, 실현가능성, 관련성을 동시에 향상
- IdeaSynth(2024) — 2-pass 구조에서 대안적 아이디어 탐색이 유의미하게 증가 (5.40 vs 3.65)
- 1차 리서치는 **방향 제시형(orientation)** — 문제 공간 이해 수준으로 제한하여 고착 효과(fixation) 방지
- 2차 리서치는 **심화형(deep dive)** — 브레인스토밍에서 구체화된 아이디어를 검증하고 자료 보강

#### Phase 2 탐색적 리서치 — web-research 패턴 적용

- 패턴 출처: `langchain-ai/deepagents@web-research` (참조용 설치)
- 4자료원 통합: input_data.json + 로컬 참고자료 + NotebookLM + 인터넷 리서치
- 5단계 통합 알고리즘: 주제 축 추출 → 축별 배정 → 교차검증(삼각측량) → 고착효과 필터 → 구조화 작성
- 상세 워크플로우: `.claude/agents/research-agent/AGENT.md` 참조

#### Phase 4 심화 리서치 — deep-research 스킬 적용

- 스킬: `199-biotechnologies/claude-deep-research-skill@deep-research` (1.3K installs)
- 설치: `npx skills add 199-biotechnologies/claude-deep-research-skill@deep-research`
- 8단계 파이프라인: Scope → Plan → Retrieve → Triangulate → Synthesize → Critique → Refine → Package
- 브레인스토밍 결과(`brainstorm_result.md`)를 입력으로 구체적 사례·참고문헌·검증 데이터 수집
- 인용 기반 보고서 생성 (anti-hallucination protocol: 모든 팩트에 즉시 인용 `[N]` 부여)
- 모드 선택: Standard(5-10분, 기본) 또는 Deep(10-20분, 철저 검증)

#### Phase 6 구성안 작성 — 분할 작업 지원

출력이 32,000 토큰 제한을 초과할 경우 writer-agent가 자동으로 분할 작성합니다.

- **분할 단위**: Part 1(§1~§4 기본 정보) → Part 2(§5 전반부 차시별 계획) → Part 3(§5 후반부 + §6~§9)
- **동작 방식**: 오케스트레이터가 writer-agent를 Part별로 순차 호출, 각 Part는 이전 산출물에 이어쓰기(append)
- **최종 산출물**: 단일 `lecture_outline.md`로 병합
- 분할 기준은 강의 규모(차시 수)에 따라 오케스트레이터가 동적 결정

#### Phase 7: 품질 검토 — 6영역 36항목 검증

Phase 6 산출물(`lecture_outline.md`)을 입력 원본 4개 파일과 대조하여 품질을 검증합니다.

**Step 0~5 워크플로우**:

```
Step 0: 입력 로드 (5개 파일)
  │     lecture_outline.md + architecture.md + brainstorm_result.md + research_deep.md + input_data.json
  │
  ├── Step 1: 구조 완전성 (S-1~S-6, 6항목) → _review_step1.md
  ├── Step 2: 교수설계 정렬 (L-1~L-5, A-1~A-5, F-1~F-4, 14항목) → _review_step2.md
  ├── Step 3: 시간 배분 현실성 (T-1~T-7, 7항목) → _review_step3.md
  ├── Step 4: 콘텐츠 정확성 — Anti-Hallucination (C-1~C-9, 9항목) → _review_step4.md
  └── Step 5: 통합 판정 → quality_review.md ★
```

**6개 검증 영역**:

| 영역 | ID 범위 | 항목 수 | 가중치 | 주요 검증 기준 |
|------|---------|--------|--------|--------------|
| S: 구조 완전성 | S-1~S-6 | 6 | — | §1~§9 존재, 필수 테이블, 24개 서브섹션, 50분 내부 구조 |
| L: 학습목표 명확성 | L-1~L-5 | 5 | 25% | 측정 가능 동사, ABCD 요소, Bloom's 적합성, CLO-SLO 계층 |
| A: 목표-활동-평가 정렬 | A-1~A-5 | 5 | 25% | 정렬 맵 일관성, 활동·평가 커버리지, 차시-정렬맵 일치 |
| F: 콘텐츠 구조/흐름 | F-1~F-4 | 4 | 15% | Bloom's 점진 상승, 선후 관계, Essential Questions |
| T: 시간 배분 현실성 | T-1~T-7 | 7 | 15% | 일일 시간, 개념 수 ≤5, 실습 비율, Must 100%, 시간 예산 |
| C: 콘텐츠 정확성 | C-1~C-9 | 9 | 20% | CLO/SLO 원본 대조, 차시·정렬맵·활동·메타포 근거 |

**판정 기준** (3단계):
- **PASS**: Major 0개 + Minor ≤ 3
- **CONDITIONAL PASS**: Major 0개 + Minor ≥ 4
- **REVISION REQUIRED**: Major ≥ 1

**산출물**: `01_outline/quality_review.md` (§1 검토 요약 → §2 검증 상세 → §3 Major → §4 Minor → §5 우수 → §6 수정 우선순위 → §7 최종 판정)

상세 워크플로우: `.claude/agents/review-agent/AGENT.md` "강의구성안 품질 검토 (Phase 7) 세부 워크플로우" 섹션 참조

#### 시간표 자동 생성

Phase 5(아키텍처 설계)에서 일별 시간표를 자동 생성하여 Phase 6 산출물에 삽입합니다.

- **생성 위치**: `architecture.md` §4 차시 배치에서 시간표 설계 → `lecture_outline.md` §1 강의 개요에 삽입
- **시간표 포함 정보**: 교시 번호, 시작/종료 시간, 하위 주제, 활동 유형, 휴식 배치
- **자동 계산**: 교시 시간(50분) + 휴식(10분) + 점심 시간을 반영한 일별 타임테이블

#### 산출물 명명 규칙

폴더와 파일 이름은 `단계번호_단계이름` 패턴을 따릅니다.

- **워크플로우 폴더**: `{단계번호}_{단계이름}/` (예: `01_outline/`, `02_script/`, `03_slide_plan/`, `04_slides/`)
- **최종 산출물**: `{워크플로우}_{유형}.md` (예: `lecture_outline.md`, `lecture_script.md`, `slide_plan.md`)
- **중간 산출물**: `{Phase역할}_{내용}.md` (예: `research_exploration.md`, `brainstorm_result.md`, `research_deep.md`)
- **검토 중간**: `_review_step{N}.md` (구성안: N=1~4), `_review_block_{block_id}.md` (교안: 블록별)
- 상세 파일 목록은 각 SKILL.md의 산출물 섹션 참조

**데이터 흐름**:
```
사용자 입력 → input_data.json → research_exploration.md → brainstorm_result.md
→ research_deep.md → architecture.md → lecture_outline.md → quality_review.md
```

**산출물**: `lectures/YYYY-MM-DD_{강의명}/01_outline/lecture_outline.md`

---

### 워크플로우 2: 강의교안 (`/lecture-script`)

**목적**: 구성안을 기반으로 실제 강의에 사용하는 상세 교안을 작성합니다.

| Phase | 단계 | 에이전트 | 핵심 작업 |
|-------|------|---------|----------|
| 1 | 입력 수집 | input-agent | 구성안 3파일 로드 + S0~S6 자동 추론/확인 (AskUserQuestion 1회) → input_data.json |
| 2 | 탐색적 리서치 | research-agent | 5자료원 통합(구성안+로컬+NBLM+웹) → 5개 주제 축(교수법/활동/사례/오개념/발문) 탐색, 고착 효과 방지 필터 |
| 3 | 브레인스토밍 | brainstorm-agent | 4가지 발산 기법(HMW/SCAMPER/학제간융합/강제제약) → 발문(Bloom's×Socratic), 학습활동(GRR), 사례·훅, 설명 전략, Gagne 9사태, 오개념 해소 |
| 4 | 심화 리서치 | research-agent | 브레인스토밍 기반 교수법 효과성 검증(효과 크기+맥락 전이+SLO 측정), 활동 보충(루브릭/발문/템플릿), 사실 확인 |
| 5 | 교안 구조 설계 | architecture-agent | 교수 모델별 도입-전개-정리 비율, Gagne 9사태 적용, SLO별 형성평가 배정, 시간 배분 |
| 6 | 블록별 교안 작성 | writer-agent | 동적 블록 분할 + full_script(L5) 완전 스크립트 — 교안(학습 내용) + 강사대본(발화문) + 발문 + 활동 + 평가문항. brainstorm 소재 필수 통합, 친절한 구어체 |
| 7 | 블록별 품질 검토 | review-agent | 블록 단위 6영역 검증 루프 — REVISION_REQUIRED 시 해당 블록만 재작성(최대 1회). G(Gagne/GRR) + P(Bloom's/CMU) + T(시간) + C(Anti-Hallucination) + N(발화문 충실도/brainstorm 활용도) |
| 8 | 통합 + 최종 검토 | review-agent | 블록 독립 산출물 생성 + 구조 완전성(S) + 블록 간 전환 일관성 + SLO 커버리지 + 집계 정합 → quality_review.md |

**적용 프레임워크**:
- Madeline Hunter 6단계 (직접교수법)
- PBL 6단계 (문제기반학습)
- Before/During/After (플립러닝)
- Gagne의 9가지 수업사태 (체크리스트)
- GRR — Gradual Release of Responsibility (I Do → We Do → You Do)
- Bloom's Taxonomy 기반 발문 수준 자동 매핑

**교안 구조** (교수 모델별 자동 비율, 50분 기준):
```
직접교수법:  도입 16% (8분) / 전개 70% (35분) / 정리 14% (7분)  (GRR: I Do → We Do → You Do)
PBL:        도입 20% (10분) / 전개 70% (35분) / 정리 10% (5분)  (GRR: We Do Together 중심)
플립러닝:    도입 10% (5분) / 전개 80% (40분) / 정리 10% (5분)  (GRR: We Do → You Do Together)
혼합:       차시별 해당 모델의 비율 적용
```

**스크립트 상세도**: `full_script`(L5) 고정 — 초보 강사가 교안+대본만 보고 강의 가능

#### Phase 1: 입력 수집 상세

구성안의 3개 파일을 로드하고, architecture.md를 분석하여 교수 모델·활동 전략을 자동 추론합니다.

**Step 0: 이전 산출물 탐색 + 로드**
- `lectures/*/01_outline/lecture_outline.md` 스캔 → 구성안 폴더 선택
- 로드 대상 3파일: `lecture_outline.md`, `input_data.json`, `architecture.md`
- `02_script/` 폴더 자동 생성

**Step 1: AskUserQuestion 1회** — S0 + S1a(확인) + S1b(확인)

| # | 카테고리 | 질문 | 입력 형태 | 기본값 |
|---|---------|------|----------|--------|
| S0 | 교안 작성 범위 | 전체 차시 / 특정 차시 선택 | 단일 선택 | 전체 차시 |
| S1a | 교수 모델 | 직접교수법 / PBL / 플립러닝 / 혼합 | 단일 선택 | architecture.md 자동 추론 결과 "(추천)" |
| S1b | 활동 전략 | 개인실습 / 그룹활동 / 토론·발문 / 프로젝트 | 복수 선택 | architecture.md 자동 추론 결과 |

**S1a 자동 추론 알고리즘**:
1. architecture.md §4-2 차시 테이블 "활동 유형" 열에서 키워드 카운팅
2. 직접교수법("안내 실습", "시범"), PBL("프로젝트", "탐구"), 플립러닝("사전학습", "플립") 점수 산출
3. 최고 점수 모델이 전체 50% 이상 → 해당 모델 추천, 미만 → "혼합" 추천
4. 1차 실패 시 pedagogy 텍스트에서 폴백 추론

**Step 2: 자동 결정 (질문 없음)** — S2~S6

| # | 카테고리 | 자동 결정 방법 |
|---|---------|--------------|
| S2 | 스크립트 상세도 | `full_script` 고정 (초보 강사가 교안+대본만 보고 강의 가능) |
| S3 | 형성평가 | architecture.md §3-2 형성평가 계획에서 자동 추출 → 유형 분류 + SLO 커버리지 검증 |
| S4 | 시간 비율 | S1a 교수 모델에서 자동 파생 (직접교수: 10/60/30, PBL: 10/75/15 등) |
| S5 | 참고자료 | 구성안 local_folders + notebooklm_urls 상속 + 인터넷 리서치 기본 활성화 |
| S6 | 발문·Gagne | Bloom's 수준별 발문 자동 매핑 + Gagne 9사태 체크리스트 고정 |

**Step 3**: 자동 결정 요약 출력 (사용자 확인용)
**Step 4**: `02_script/input_data.json` 생성

스키마: `.claude/templates/input-schema-script.json` 참조

#### Phase 2: 탐색적 리서치 상세

구성안 Phase 2의 4자료원 통합 패턴을 재사용하되, **교안 특화**(How to teach) 관점으로 재설계합니다.

- **핵심 차이**: 구성안은 "무엇을 가르칠까?(What)" → 교안은 "어떻게 가르칠까?(How)"
- **Step 0~4 흐름**: 스키마 참조 + 입력 로드 → 로컬 분석 → NBLM 쿼리 → 인터넷 리서치 → 5단계 통합 알고리즘

**자료원 통합 (5자료원 + 스키마 참조)**:

| 자료원 | 역할 | 신뢰도 |
|--------|------|--------|
| input-schema-script.json | 구조 참조 — 필드 의미·유효 enum·필드 간 관계 정의 | ★★★ 절대 기준 |
| input_data.json + 구성안 산출물 | 설계 기준선 — 차시 구조·SLO·학습자 프로필 | ★★★ 절대 기준 |
| 로컬 참고자료 | 사용자 선별 핵심 자료 | ★★★ 높음 |
| NotebookLM | 사용자 선별 소스 기반 검증된 답변 | ★★★ 높음 |
| 인터넷 리서치 | 최신 교수법 사례, 외부 벤치마킹 | ★☆☆~★★☆ 가변 |

**교안 특화 5개 주제 축**:

| 축 | 질문 | 구성안 축과의 차이 |
|----|------|-----------------|
| A: 교수법 패턴 | "어떤 방식으로 가르치는 것이 효과적인가?" | 구성안 D축(교육 현황) 대체 |
| B: 학습활동·참여 | "어떤 활동이 학습 참여를 높이는가?" | 신규 |
| C: 설명·사례·비유 | "어떤 설명/사례/비유가 효과적인가?" | 구성안 A+E축 재조합 |
| D: 학습자 장벽·오개념 | "학습자가 겪는 어려움과 해소 전략은?" | 구성안 B축 심화 |
| E: 평가·발문·피드백 | "효과적인 발문·평가·피드백 방법은?" | 신규 |

**고착 효과 방지 필터 (교안 버전)**: 교수법 방향성·활동 패턴은 허용, 구체적 강사 대본·교안 시간표 직접 복제는 금지

**교수 모델별 검색어 분기**: `teaching_model` enum에 따라 검색 키워드 자동 분기 (직접교수법→Hunter, PBL→문제 시나리오, 플립러닝→Before/During/After)

**산출물 구조** (`research_exploration.md` §1~§7):
1. 교수 모델별 수업 설계 사례 (축 A)
2. 학습활동·참여 전략 사례 (축 B)
3. 실생활 사례·설명 전략 (축 C)
4. 학습자 오개념·장벽 해소 전략 (축 D)
5. 발문·형성평가·피드백 패턴 (축 E) + Gagne 9사태 실행 가이드
6. 참고자료 분석 요약
7. 리서치 인사이트 (Phase 3 브레인스토밍용, SLO + activity_strategy + Bloom's 수준 태깅)

상세 워크플로우: `.claude/agents/research-agent/AGENT.md` "강의교안 탐색적 리서치 (Phase 2)" 섹션 참조

#### Phase 3: 브레인스토밍 상세

구성안 Phase 3이 "무엇을 가르칠까(What)"를 발산했다면, 교안 Phase 3은 **"어떻게 가르칠까(How)"**를 발산합니다.

- **핵심 차이**: 구성안은 하위 주제 도출 → 교안은 발문·활동·사례·Gagne 구현 방안 도출
- **Step 0~5 흐름**: 입력 로드(4파일) → 발산(4기법×4카테고리) → 차시별 매핑 → 다관점 검증(3역할) → Bloom's 발문+Gagne 매핑+활동 구체화 → 통합

**교안 특화 4가지 발산 기법**:

| # | 기법 | 생성 대상 |
|---|------|----------|
| 1 | HMW(How Might We) 재구성 | 학습활동, 설명 전략 |
| 2 | 학제간 융합 | 학습활동, 실생활 사례 |
| 3 | SCAMPER 활동 설계 | 학습활동, 형성평가 |
| 4 | 강제 제약 + Magic Wand | 발문, 도입부 훅, 설명 전략 |

**3개 검증 관점** (구성안 5개에서 축소 — 구조는 이미 확정, 실행 현실성만 검증):

| 역할 | 검증 대상 |
|------|----------|
| 비판적 교육자 | SLO-활동 정렬, Bloom's 적합성, Gagne 누락 |
| 학습자 대변인 | 인지 부하, 동기 유발, 난이도 |
| 시간 관리자 | 활동 소요 시간, time_ratio 준수 |

**산출물 구조** (`brainstorm_result.md` §1~§8):
1. 차시별 발문 설계 (Bloom's × Socratic)
2. 학습활동 아이디어 (GRR × 차시)
3. 실생활 사례·훅 목록
4. 설명 전략·비유 목록
5. Gagne 9사태 구현 방안
6. 학습자 오개념·장벽 해소 전략
7. 심화 리서치 요청 사항 (Phase 4 전달용)
8. Decision Log (ADOPT/REVISE/DROP/MERGE)

상세 워크플로우: `.claude/agents/brainstorm-agent/AGENT.md` "강의교안 브레인스토밍 (Phase 3) 세부 워크플로우" 섹션 참조

#### Phase 4: 심화 리서치 상세

구성안 Phase 4가 "콘텐츠 사실 확인(What)"이라면, 교안 Phase 4는 **"교수법 효과성 검증(How to teach)"**입니다. deep-research 스킬의 8단계 파이프라인을 재사용하되, 교안 특화 삼각검증을 추가합니다.

**구성안 Phase 4와의 핵심 차이**:

| 차원 | 구성안 | 교안 |
|-----|--------|------|
| §7 입력 컬럼 | `관련 하위 주제` | `관련 차시/SLO` |
| 검증 초점 | 콘텐츠 사실 확인 | 교수법 효과성 검증 |
| 요청 유형 | 사례 검증, 참고 문헌, 사실 확인 | 사례 검증, 활동 보충, 사실 확인 |
| 삼각검증 | 3중 소스 일치 | 3중 소스 + 효과 크기·맥락 전이·SLO 측정 |
| 산출물 소비자 | Phase 5 | Phase 5 (architecture) + Phase 6 (writer) |

**교수법 효과성 3중 검증** (교안 Phase 4 신규):

| 차원 | 질문 | 적용 유형 |
|------|------|----------|
| 효과 크기 | "effect size가 유의미한가? (d≥0.4)" | 사례 검증, 사실 확인 |
| 맥락 전이 | "{target_learner}에게도 적용 가능한가?" | 사례 검증, 활동 보충 |
| SLO 측정 | "이 평가 도구가 해당 SLO를 측정하는가?" | 사실 확인, 활동 보충 |

**유형별 검색 전략**:
- 사례 검증: 메타분석 → 대학 CTL → 교사 커뮤니티 (효과 크기+맥락 전이 필수)
- 활동 보충: 대학 CTL → 교육공학 저널 → 교사 커뮤니티 (SLO 적합성)
- 사실 확인: 공식 교수설계 문헌 → 논문 → 전문가 블로그 (3중 소스 일치)

**통합 시사점 3카테고리**:
1. 확정된 전제 → architecture-agent(Phase 5)용 — 교수법/활동 전략 설계 기반
2. 확보된 소재 → writer-agent(Phase 6)용 — 루브릭/발문/활동 템플릿/훅 소재
3. 미해결 항목 → 강사 확인 필요

**Step 0: 입력 변환** (교안 특화):
1. `brainstorm_result.md` §1(발문), §2(활동), §5(Gagne) — 검증의 참조 기준선으로 로드
2. `brainstorm_result.md` §7 — 구체적 요청사항 (사례검증/활동보충/사실확인, `관련 차시/SLO` 컬럼)
3. `input_data.json` → `script_config.teaching_model`, `instructional_model_map`, `formative_assessment`
4. 구성안 파일(`lecture_outline.md`, `architecture.md`) — 차시별 SLO, 시간 배분 참조 (변경 불가 기준)

**제약**: 웹 25회, NBLM 5회, 삼각검증 추가 5회 이내

상세 워크플로우: `.claude/agents/research-agent/AGENT.md` "강의교안 심화 리서치 (Phase 4) 세부 워크플로우" 섹션 참조

#### Phase 5: 교안 구조 설계 상세

구성안 Phase 5가 "전체 과정 구조 설계"(Top-down: CLO/SLO/차시 배정)라면, 교안 Phase 5는 **"각 차시 내부 구조 설계"(Bottom-up: 확정된 차시 내부를 교수 모델별로 채움)**입니다.

**구성안 Phase 5 vs 교안 Phase 5 핵심 차이**:

| 차원 | 구성안 Phase 5 | 교안 Phase 5 |
|------|--------------|-------------|
| 설계 대상 | 전체 과정 구조 (CLO/SLO/차시 배정) | 각 차시 내부 구조 (도입-전개-정리) |
| 설계 방향 | Top-down (학습 결과 → 차시) | Bottom-up (확정된 차시 내부를 채움) |
| 불변 기준 | input_data.json의 learning_goals | 구성안 architecture.md 전체 |
| 핵심 프레임워크 | Backward Design, Constructive Alignment | Gagne 9사태, GRR, Bloom's 발문, CMU 3점 모델 |
| 교수 모델 분기 | 없음 | 있음 (직접교수법/PBL/플립러닝/혼합) |

**Step 0~4 워크플로우**:

```
Step 0: 입력 로드 + 변경 불가 기준 확정
  │     구성안 architecture.md(변경 불가) + brainstorm + research_deep + input_data.json + context7_reference
  │
  ├── Step 1: 차시별 교수 모델 확정 + 시간 비율 + GRR 배분
  │     교수 모델별 도입/전개/정리 비율, Gagne 9사태 강조점, GRR 4단계 시간 배분
  │
  ├── Step 2: 차시 내부 구조 설계 (Gagne 9사태 × GRR × Bloom's)
  │     도입부(사태1~3), 전개부(사태4~7 × GRR), 정리부(사태8~9) 세부 시간 블록
  │
  ├── Step 3: 형성평가 3점 배치 + 발문 수준 배정
  │     CMU Eberly 3점(Entry-During-Exit) + SLO-평가 정합 + Bloom's×Socratic 교차
  │
  └── Step 4: 차시 간 전환 설계 + 검증(6항목) + 산출물 통합 → architecture.md
```

**Context7 기술 문서 통합** (오케스트레이터 사전 처리):
- `input_data.json`의 keywords + 구성안 차시 하위 주제에서 라이브러리 자동 추출
- Context7 MCP(`resolve-library-id` → `get-library-docs`)로 최신 문서/코드 예제 수집
- `context7_reference.md`에 저장 → architecture-agent가 §3 차시별 내부 구조의 `기술 참조` 컬럼으로 배정
- 기술 교육이 아닌 경우 자동 스킵

**적용 프레임워크**:
- Gagne 9사태 (U. Florida CITT, Utah State, NIU CITL)
- GRR 4단계 (Fisher & Frey, DePaul University, ASCD)
- CMU Eberly 3점 형성평가 배치 (CMU Eberly Center, Columbia CPET)
- Bloom's × Socratic 발문 교차 매핑 (Paul & Elder)
- 강의 분절 10~15분 규칙 (Michigan CRLT)

**교수 모델별 시간 비율** (50분 기준):

| 교수 모델 | 도입 | 전개 | 정리 | GRR 중심 |
|-----------|------|------|------|---------|
| 직접교수법 | 16% (8분) | 70% (35분) | 14% (7분) | I Do → We Do → You Do |
| PBL | 20% (10분) | 70% (35분) | 10% (5분) | We Do Together 중심 |
| 플립러닝 | 10% (5분) | 80% (40분) | 10% (5분) | We Do → You Do Together |

**검증 체크리스트** (6항목): 시간 합산, Gagne 커버리지 ≥7/9, SLO 평가 100%, GRR 연속성, 강의 분절 ≤15분, time_ratio 준수

**산출물**: `02_script/architecture.md` (§1~§9: 변경 불가 기준 요약, 교수 모델 설계, 차시별 내부 구조, 형성평가 배치, 발문 수준, 전환 설계, 기술 문서 참조, 검증 결과, 설계 결정 로그)

상세 워크플로우: `.claude/agents/architecture-agent/AGENT.md` "강의교안 아키텍처 설계 (Phase 5) 세부 워크플로우" 섹션 참조

#### Phase 6: 블록별 교안 작성 — full script + 강사대본

Phase 1~5 산출물을 통합하여 초보 강사가 교안+대본만 보고 강의 가능한 full_script(L5)를 생성합니다.

**교안 고유 요소**: 강사 발화문, 발문 스크립트(Bloom's×Socratic), 행동 지시, 활동 지시문, 시간 큐, 전환 문구, 예상 학습자 반응, Think-Aloud 메타인지 패턴, 오개념 대응 카드

**2-레이어 분리**: 발화문(`> "..."`)과 행동 지시(`[...]`)를 시각적으로 구분하여 강사가 빠르게 발화/동작을 식별

**동적 블록 분할**: architecture.md 시간표를 파싱하여 블록 경계를 동적 결정합니다.

- 각 Day에 대해 30분+ 공백(점심 등) 탐색
- `sessions_in_day ≥ 6 AND 공백 존재` → AM/PM 2블록 분할
- 그 외 → Day 전체 1블록
- 블록 ID: `D{day}_{AM|PM}` (분할 시) 또는 `D{day}` (미분할 시)
- 교시 수 10개 초과 시 블록별 분할 작성 (`len(blocks) + 2` Part)

**내용 충실화 규칙** (발화문 품질 기준):

- **분량 제한 없음**: GRR 구간별 내용 품질 기준으로 대체
- **brainstorm 소재 필수 통합**: brainstorm_result.md §1~§6의 소재를 레이블이 아닌 교안 발화문으로 통합
- **어조**: 친절한 구어체(~해요, ~입니다), 딱딱한 문어체(~한다) 금지
- **강사 발화 = 실제 대본**: `> "..."` 블록은 강사가 말할 내용 전체를 담는다

**산출물 구조**: §1~§3 개요·목표·공통구조 + §4 차시별 교안 + §5~§6 형성평가·발문 집계 + §7~§8 참고자료·강사가이드

상세 워크플로우: `.claude/agents/writer-agent/AGENT.md` "강의교안 작성 (Phase 6) 세부 워크플로우" 섹션 참조

#### Phase 7: 블록별 품질 검토 — 블록 단위 검증 + 재작성 루프

Phase 6에서 결정한 블록 단위로 교안 품질을 검증하며, REVISION_REQUIRED 시 해당 블록만 재작성합니다.

**구성안 Phase 7 vs 교안 Phase 7+8 핵심 차이**:

| 차원 | 구성안 Phase 7 | 교안 Phase 7 (블록별) | 교안 Phase 8 (통합) |
|------|--------------|---------------------|-------------------|
| 검증 대상 | `lecture_outline.md` 전체 | `lecture_script.md` 블록 범위 | `lecture_script.md` 전체 |
| 검증 항목 수 | 38개 (6영역) | ~41개 (5영역: G+P+T+C+N) | ~15개 (S+일관성) |
| Step 수 | Step 0~5 | 블록 수만큼 반복 | 1회 |
| 재작성 | 없음 | REVISION 시 writer-agent 재호출 (최대 1회) | 없음 |

**블록별 검토 루프**:

```
for block in blocks:
    1. review-agent 호출 (블록 범위, ~41항목)
       → _review_block_{block_id}.md

    2. 판정 추출
       → PASS / CONDITIONAL PASS → 다음 블록
       → REVISION_REQUIRED → 재작성 루프

    3. [REVISION] writer-agent 재호출 (해당 블록만, revision 모드)
       → lecture_script.md 내 해당 세션 Edit 교체

    4. [REVISION] review-agent 재호출 (동일 블록)
       → 여전히 REVISION → 사용자 보고 후 중단
```

**블록별 검증 5영역 (~41항목)**:

| 영역 | ID 범위 | 항목 수 | 주요 검증 기준 |
|------|---------|--------|--------------|
| G: 교수설계 프레임워크 | G-1~G-8 | 8 | Gagne ≥7/9, GRR 순차, 2-레이어 분리, Think-Aloud ≥3/4, 15분 분절 |
| P: 발문·평가·흐름 | P-1~P-7 | 7 | Bloom's 점진 상승, CMU 3점(Exit 필수), SLO-발문 정합, 차시 간 전환 |
| T: 시간 배분 | T-1~T-8 | 8 | 교시 합산, time_ratio ±5%, GRR 비율, **15분 분절 준수(T-5)**, 시간큐 연속성 |
| C: 콘텐츠 정확성 | C-1~C-9 | 9 | CLO/SLO 원본 대조, 차시 배치, 발문·활동·오개념 근거 |
| N: 교안 실행 품질 | N-1~N-9 | 9 | **발화문 자연성+내용 충실도(N-1)**, 활동 3요소, 집계 정합, 강사 가이드, 표기법, **brainstorm 소재 활용도(N-8)** |

**N 영역 주요 변경 사항** (내용 충실화 규칙 반영):
- **N-1**: 발화문이 친절한 구어체(~해요, ~입니다)이고, I Do/We Do에 개념 설명·비유·예시가 충분한지 검증. 1줄 발화만 존재 시 **Major** 위반
- **N-8** (신설): brainstorm_result.md §3(사례·훅), §4(설명전략·비유), §5(Gagne 구현 방안) 소재가 교안 발화문에 반영되었는지 검증. 50%+ 미활용 시 **Major**
- **T-5**: 발화 블록 길이 → **15분 분절 준수**로 변경 (I Do 세그먼트 15분 초과 시 Bridging Activity 삽입 확인)

**판정 기준** (3단계):
- **PASS**: Major 0개 + Minor ≤ 3
- **CONDITIONAL PASS**: Major 0개 + Minor ≥ 4
- **REVISION REQUIRED**: Major ≥ 1

상세 워크플로우: `.claude/agents/review-agent/AGENT.md` "강의교안 품질 검토 (Phase 7) 세부 워크플로우" 섹션 참조

#### Phase 8: 통합 + 최종 검토 — 구조 완전성 + 블록 간 일관성

Phase 7 블록별 검토 완료 후, 전체 문서의 구조 완전성과 블록 간 일관성을 최종 검증합니다.

**오케스트레이터 사전 처리**:
- 각 블록의 §4 세션들을 `lecture_script.md`에서 추출 → `block_{block_id}.md`로 독립 산출물 생성

**통합 검증 영역 (~15항목)**:

| 영역 | 주요 검증 기준 |
|------|--------------|
| S: 구조 완전성 (S-1~S-7) | §1~§8 존재, 필수 테이블, 22개 서브섹션, 차시 커버리지 |
| 블록 간 전환 일관성 | AM→PM, Day 간 전환 문구 자연스러움 |
| SLO 커버리지 | 모든 SLO가 §4에서 다뤄지는지 |
| 형성평가 집계 정합 | §5 집계 = §4 인라인 합계 |
| 발문 모음 정합 | §6 발문 = §4 인라인 발문 |
| 용어·표기 통일 | 전체 문서 일관성 |

**산출물**: `02_script/quality_review.md` (§1 검토 요약 → §2 검증 상세 → §3 Major → §4 Minor → §5 우수 → §6 수정 우선순위 → §7 최종 판정)

**데이터 흐름**:
```
구성안 3파일 로드 → input_data.json → research_exploration.md → brainstorm_result.md
→ research_deep.md → [context7_reference.md] → architecture.md
→ [블록별 작성] lecture_script.md → [블록별 검토] _review_block_*.md
→ [통합] block_*.md + quality_review.md
```
- `context7_reference.md`: Phase 5 오케스트레이터가 Context7 MCP로 사전 수집 (기술 교육 시에만 생성)
- `_review_block_{block_id}.md`: Phase 7 블록별 검토 결과 (블록 수만큼 동적 생성)
- `block_{block_id}.md`: Phase 8 블록별 독립 산출물 (블록 수만큼 동적 생성)

**산출물**: `lectures/YYYY-MM-DD_{강의명}/02_script/lecture_script.md`

---

### 워크플로우 3: 슬라이드 기획 (`/slide-planning`)

**목적**: 교안을 기반으로 슬라이드의 구조, 수, 레이아웃을 설계합니다.

| Phase | 단계 | 에이전트 | 핵심 작업 |
|-------|------|---------|----------|
| 1 | 입력 수집 | input-agent | 교안 로드, 슬라이드 도구(Marp/Slidev/Gamma) 선택 |
| 2 | 브레인스토밍 | brainstorm-agent | 시각화 아이디어, 레이아웃 패턴 구상, 인터랙션 요소 |
| 3 | 구조 설계 | architecture-agent | 슬라이드 수 결정, 유형 배정, 순서, 시간 배분 |
| 4 | 기획안 작성 | writer-agent | slide-plan-template.md 기반, 슬라이드별 목적/레이아웃/콘텐츠/시각자료 |
| 5 | 품질 검토 | review-agent | 정보 밀도, 시각 계층, 학습목표 정렬, 슬라이드 수 적절성 |

**설계 원칙**:
- 슬라이드당 1개 아이디어 (인지 부하 이론)
- 정보 밀도: 텍스트 5-7줄, 불릿 4-5개 이하
- 시간 기준: 1-2분/슬라이드 (교육용은 활동 시간 별도)
- Assertion-Evidence 구조 (불릿포인트 대체)

**슬라이드 유형 (12가지)**:
제목, 아젠다, 섹션전환, 개념설명, 코드, 비교, 데이터+인사이트, 이미지, 타임라인, 인용, 핵심요약, 실습/활동

**시간별 슬라이드 수 기준**:

| 시간 | 슬라이드 수 |
|------|-----------|
| 30분 | 15-32장 |
| 60분 | 30-45장 |
| 90분 | 45-70장 |

**산출물**: `lectures/YYYY-MM-DD_{강의명}/03_slide_plan/slide_plan.md`

> **구현 상태**: 파이프라인 개요 및 설계 원칙 정의 완료. SKILL.md 오케스트레이터 로직, 에이전트별 세부 워크플로우, 입력 스키마(`input-schema-slide-planning.json`) 미구현.

---

### 워크플로우 4: 슬라이드 생성 프롬프트 (`/slide-generation`)

**목적**: 기획안을 기반으로 실제 슬라이드 콘텐츠 또는 AI 도구용 프롬프트를 생성합니다.

| Phase | 단계 | 에이전트 | 핵심 작업 |
|-------|------|---------|----------|
| 1 | 입력 수집 | input-agent | 기획안 로드, 출력 형식 선택(Marp/Slidev/Gamma 프롬프트) |
| 2 | 프롬프트 생성 | writer-agent | slide-prompt-template.md 기반, 슬라이드별 마크다운 또는 프롬프트 |
| 3 | 품질 검토 | review-agent | 형식 검증, 콘텐츠 정확성, 일관성, 접근성 |

**지원 출력 형식**:

| 도구 | 적합 용도 | 특징 |
|------|----------|------|
| **Marp** | 범용 교육 강의 | 학습 곡선 최소, AI 생성 용이, Git 친화적 |
| **Slidev** | 코드 중심 개발 교육 | 줄별 하이라이트, Vue 컴포넌트, 라이브 코딩 |
| **Gamma** | 디자인 중시 프레젠테이션 | 시각적 완성도, 비개발자 접근성 |
| **reveal.js** | 고급 인터랙션 | 최대 커스터마이징, 웹 배포 |

**프롬프트 6대 필수 요소**: 청중 정의, 프레젠테이션 유형, 콘텐츠 범위, 톤과 스타일, 시각적 선호, 핵심 데이터

**산출물**: `lectures/YYYY-MM-DD_{강의명}/04_slides/slides.md`

> **구현 상태**: 파이프라인 개요 및 출력 형식 정의 완료. SKILL.md 오케스트레이터 로직, 에이전트별 세부 워크플로우, 입력 스키마(`input-schema-slide-generation.json`) 미구현.

---

## 산출물 저장 구조

```
lectures/
└── YYYY-MM-DD_{강의명}/
    ├── 01_outline/                        # /lecture-outline 산출물
    │   ├── input_data.json                # Phase 1 최종
    │   ├── research_exploration.md        # Phase 2 최종
    │   ├── brainstorm_result.md           # Phase 3 최종
    │   ├── research_deep.md               # Phase 4 최종
    │   ├── architecture.md                # Phase 5 최종
    │   ├── lecture_outline.md             # Phase 6 최종 ★
    │   ├── _review_step1~4.md             # Phase 7 중간
    │   └── quality_review.md              # Phase 7 최종 ★
    │
    ├── 02_script/                         # /lecture-script 산출물
    │   ├── input_data.json                # Phase 1 최종
    │   ├── research_exploration.md        # Phase 2 최종
    │   ├── brainstorm_result.md           # Phase 3 최종
    │   ├── research_deep.md               # Phase 4 최종
    │   ├── [context7_reference.md]        # Phase 5 사전처리 (기술 교육 시)
    │   ├── architecture.md                # Phase 5 최종
    │   ├── lecture_script.md              # Phase 6 최종 ★
    │   ├── _review_block_{block_id}.md    # Phase 7 블록별 검토 결과 (동적)
    │   ├── block_{block_id}.md            # Phase 8 블록별 독립 산출물 (동적)
    │   └── quality_review.md              # Phase 8 최종 ★
    │
    ├── 03_slide_plan/                     # /slide-planning 산출물 (미구현)
    │   └── slide_plan.md                  # 최종 슬라이드 기획
    └── 04_slides/                         # /slide-generation 산출물 (미구현)
        └── slides.md                      # 최종 슬라이드 (Marp/Slidev 등)
```

- **날짜 형식**: `YYYY-MM-DD` (예: `2026-03-05`)
- **강의명**: 사용자 입력 Q1(핵심 주제)에서 추출, 공백은 하이픈(`-`)으로 대체
- **예시**: `lectures/2026-03-05_claude-code-활용/`
- 각 워크플로우 폴더에는 중간 산출물도 함께 보존 (디버깅·재실행 용도)
- 상세 파일 목록은 각 SKILL.md의 산출물 섹션 참조

---

## 품질 검증 프레임워크

### 공통 판정 기준 (3단계)

모든 워크플로우의 Phase 7은 동일한 3단계 판정 기준을 적용합니다.

| 판정 | 조건 | 후속 조치 |
|------|------|----------|
| **PASS** | Major 0개 + Minor ≤ 3 | 최종 산출물 확정 |
| **CONDITIONAL PASS** | Major 0개 + Minor ≥ 4 | Minor 목록 제시, 부분 수정 권고 |
| **REVISION REQUIRED** | Major ≥ 1 | Major 수정 가이드 제공, 해당 섹션 재작성 필요 |

### 워크플로우별 검증 영역

**구성안 (`/lecture-outline`)** — 6영역 36항목, 가중치 기반:

| 영역 | 항목 수 | 가중치 | 검증 내용 |
|------|--------|--------|----------|
| S: 구조 완전성 | 6 | — | §1~§9 존재, 필수 테이블, 24개 서브섹션 |
| L: 학습목표 명확성 | 5 | 25% | 측정 가능 동사, ABCD 요소, Bloom's 적합성 |
| A: 목표-활동-평가 정렬 | 5 | 25% | 정렬 맵 일관성, 활동·평가 커버리지 |
| F: 콘텐츠 구조/흐름 | 4 | 15% | Bloom's 점진 상승, 선후 관계, Essential Questions |
| T: 시간 배분 현실성 | 7 | 15% | 인지 과부하 방지, Must 100%, 시간 예산 일치 |
| C: 콘텐츠 정확성 | 9 | 20% | Anti-Hallucination, 입력 원본 대조 |

**교안 (`/lecture-script`)** — 6영역 46항목, 가중치 미적용, 블록별 검토(Phase 7) + 통합 검토(Phase 8) 2단계:

| 영역 | 항목 수 | 검증 내용 | 검토 단계 |
|------|--------|----------|----------|
| S: 구조 완전성 | 7 | §1~§8 존재, 필수 테이블, 22개 서브섹션, 차시 커버리지 | Phase 8 (통합) |
| G: 교수설계 프레임워크 | 8 | Gagne ≥7/9, GRR 순차, 2-레이어 분리, Think-Aloud ≥3/4, 15분 분절 | Phase 7 (블록별) |
| P: 발문·평가·흐름 | 7 | Bloom's 점진 상승, CMU 3점(Exit 필수), 차시 간 전환 | Phase 7 (블록별) |
| T: 시간 배분 | 8 | 교시 합산, time_ratio ±5%, GRR 비율, **15분 분절 준수(T-5)**, 시간큐 연속성 | Phase 7 (블록별) |
| C: 콘텐츠 정확성 | 8 | Anti-Hallucination, CLO/SLO·차시·발문·활동 입력 원본 대조 | Phase 7 (블록별) |
| N: 교안 실행 품질 | 8 | **발화문 자연성+내용 충실도(N-1)**, 활동 3요소, 집계 정합, 강사 가이드, 표기법, **brainstorm 소재 활용도(N-8)** | Phase 7 (블록별) |

### Bloom's Taxonomy 참조

| 수준 | 핵심 동사 | 발문 패턴 |
|------|-----------|----------|
| 기억 | 정의, 나열, 식별 | "~은 무엇인가요?" |
| 이해 | 설명, 요약, 비교 | "자신의 말로 설명해 보세요" |
| 적용 | 적용, 사용, 실행 | "이 상황에 어떻게 적용하겠습니까?" |
| 분석 | 비교, 분류, 구분 | "A와 B의 차이점은?" |
| 평가 | 판단, 비판, 정당화 | "이 해결책의 장단점은?" |
| 창조 | 설계, 구성, 개발 | "새로운 해결 방안을 제안해 보세요" |

---

## 적용 교수설계 프레임워크 요약

| 프레임워크 | 적용 워크플로우 | 핵심 원칙 |
|-----------|--------------|----------|
| **Backward Design** | 구성안, 교안 | 학습결과 → 평가 → 학습경험 역순 설계 |
| **GAIDE** | 구성안, 교안 | Setup → 초안 → 매크로 정제 → 마이크로 정제 → 통합 |
| **Gagne 9사태** | 교안 | 주의획득 → 목표고지 → ... → 파지와 전이 촉진 (체크리스트 적용) |
| **Hunter 6단계** | 교안 (직접교수법) | 목표 → 정보제공 → 시범 → 안내연습 → 독립연습 → 정리 |
| **PBL 6단계** | 교안 (문제기반학습) | 문제제시 → 탐구계획 → 탐구수행 → 해결안개발 → 발표공유 → 성찰 |
| **Before/During/After** | 교안 (플립러닝) | 사전학습 확인 → 심화활동 → 적용·정리 |
| **GRR** | 교안 | I Do(시범) → We Do(안내연습) → You Do(독립연습) — 교수 모델별 중심 단계 상이 |
| **Bloom's 발문 매핑** | 교안 | 차시별 Bloom's 수준에 따른 수업 단계별 발문 수준 자동 배정 |
| **소크라테스식 발문 6유형** | 교안 | 명료화 → 가정 탐색 → 근거 탐구 → 함의·결과 → 관점·시각 → 메타인지 (Bloom's 수준 교차 매핑) |
| **SCAMPER (교안 활동 설계)** | 교안 브레인스토밍 | 대체/결합/적응/변형/전용/제거/역전 — 학습활동 다양화 및 형성평가 설계 |
| **HMW (How Might We)** | 교안 브레인스토밍 | SLO를 HMW 질문으로 변환하여 배달 형태에 갇히지 않는 학습 문제 중심 발상 |
| **QM Rubric** | 품질 검토 | 8개 일반 기준, 목표-활동-평가 정렬 |
| **2-Pass Research** | 구성안, 교안 | 탐색적 리서치(문제 공간) → 브레인스토밍 → 심화 리서치(아이디어 검증) |
| **deep-research 8단계** | 구성안 Phase 4, 교안 Phase 4 | Scope→Plan→Retrieve→Triangulate→Synthesize→Critique→Refine→Package (브레인스토밍 결과 심화 검증) |
| **교수법 효과성 3중 검증** | 교안 Phase 4 | 효과 크기(d≥0.4) + 맥락 전이({target_learner} 적용 가능) + SLO 측정 타당성 |
| **CMU Eberly 3점 형성평가 배치** | 교안 Phase 5 | Entry(도입 사태3 후)-During(전개 We Do 후)-Exit(정리 사태8) 3시점 배치 |
| **Think-Aloud 메타인지 4대 패턴** | 교안 Phase 6 (I Do 단계) | 계획("먼저 ~부터") → 모니터링("맞는지 확인") → 평가("효과적인 이유는") → 자기교정("다시 해야겠습니다") — Cognitive Apprenticeship 모델링 |
| **2-레이어 분리 표기법** | 교안 Phase 6 | 발화문(`> "..."`) vs 행동 지시(`[...]`) 시각 구분 — 강사가 발화/동작을 즉시 식별 가능한 실행 문서 포맷 |
| **brainstorm 소재 필수 통합** | 교안 Phase 6 | brainstorm_result.md §1~§6 소재를 레이블이 아닌 발화문으로 통합 — 사례는 스토리텔링, 비유는 풀어쓰기, Gagne 방안은 자연 반영 |
| **발화문 내용 충실화 + 구어체** | 교안 Phase 6-7 | 분량 제한 없음, GRR 구간별 내용 품질 기준. 친절한 구어체(~해요, ~입니다), 문어체(~한다) 금지. brainstorm 소재 50%+ 미활용 시 Major |
| **Context7 MCP 기술 문서 통합** | 교안 Phase 5-6 | 라이브러리 자동 판별 → resolve-library-id → get-library-docs → 최신 문서/코드 예제 수집 |
| **Assertion-Evidence** | 슬라이드 | 주장 제목 + 시각 증거 (불릿포인트 대체) |

---

## 리서치 출처

### 교수설계 프레임워크
- Virginia Tech CETL (Backward Design)
- Design Council UK, Double Diamond Framework
- Quality Matters Rubric 7th Edition
- OLC Course Review Scorecard

### AI 기반 교육 콘텐츠 설계
- GAIDE Framework, Purdue University (arXiv:2308.12276)
- NC State DELTA (AI 지원 코스 설계)
- EduCraft System, Tsinghua University (CIKM 2025)
- IdeaSynth, arXiv:2410.04025 (문헌 기반 반복 아이디어 개발)

### 브레인스토밍 · 창의적 아이디어 생성
- Minas et al. 2018, Decision Sciences (프라이밍과 전자 브레인스토밍)
- Kohn & Smith 2011, Applied Cognitive Psychology (고착 효과)
- eLearning Industry (HMW 기법 — Design Thinking 교수설계 적용)
- ScienceDirect 2025 (SCAMPER+PBL 창의성 4지표 유의미 향상)
- NIU CITL (강제 제약 기법 — 핵심 아이디어 촉발)
- Paul & Elder, Foundation for Critical Thinking (소크라테스식 발문 6유형)

### 교수법 효과성 검증 · 교수설계 이론 근거
- Gagne, R.M. et al. (2005). Principles of Instructional Design, 5th ed. (9가지 수업사태 원전)
- Keller, J.M. & Suzuki, K. (2008). ARCS Model of Motivation (동기 설계)
- Switzer, J. (2023). Direct Instruction Meta-Analysis, ERIC Database (직접교수법 효과 크기)
- Dochy, F. et al. (2015). PBL Effectiveness Meta-Analysis, CBE Life Sciences Education
- Bergmann, J. & Sams, A. (2012). Flip Your Classroom (플립러닝 연구 종합)
- Perkins, D.N. & Salomon, G. (2012). Knowledge to Go: Transfer of Learning (맥락 전이 이론)
- Black, P. & Wiliam, D. (2009). Formative Assessment Impact Meta-Analysis, Review of Educational Research
- Heritage, M. (2007). Formative Assessment: What Do Teachers Need to Know and Do?

### 교안 구조 설계 (Phase 5)
- Michigan CRLT (강의 분절 10-15분 규칙, bridging activities)
- U. Florida CITT, Utah State, NIU CITL (Gagne 9사태 × 도입-전개-정리 매핑)
- Fisher & Frey, DePaul University, ASCD (GRR 4단계 모델)
- CMU Eberly Center, Columbia CPET (형성평가 3점 배치 — Entry/During/Exit)
- U. Pittsburgh, UNC Learning Center, TopHat (Bloom's 발문 수준 패턴)
- Oregon GTF Manual, Ausubel (차시 간 전환 Preview-Review)
- Study.com (강의 전환 전략)
- CITL Illinois (PBL 수업 구조), Hunter 7단계 (직접교수법), CMU Flipped Classroom

### 교안 작성 (Phase 6)
- Collins, Brown, & Newman (1989). Cognitive Apprenticeship (Think-Aloud 모델링 전략 — 전문가 사고 과정 외현화)
- Davey, B. (1983). Think-Aloud: Modeling the Cognitive Processes of Reading Comprehension
- Rosenshine, B. (2012). Principles of Instruction (명시적 교수법 — I Do/We Do/You Do 발화 구조)
- Lemov, D. (2015). Teach Like a Champion 2.0 (강사 대본 작성, 전환 문구, 발문 스크립팅)
- Archer, A. & Hughes, C. (2011). Explicit Instruction (효과적 발화문 구조 — 내용 품질 기준 적용)

### 교안 품질 검토 (Phase 7)
- NIU CITL, U. Florida CITT (Gagne 9사태 품질 체크리스트 — 사태별 이행 여부 검증)
- PMC Gottlieb et al. 2015 (Gagne's Nine Events 커버리지 기준 ≥7/9)
- Fisher & Frey 2014, Wisconsin DPI, ODU (GRR 평가 기준 — I Do→We Do→You Do 순차성)
- Anderson & Krathwohl 2001, Waterloo CTE, Vanderbilt CFT (Bloom's 발문 정렬 검증)
- Sweller 1988 (인지 부하 이론 — 시간 배분 현실성 기준)
- Bunce et al. 2010 (15분 분절 규칙 — 연속 강의 주의 집중 한계)
- Collins, Brown & Newman 1989, Texas Gateway (Think-Aloud/Cognitive Apprenticeship 품질 검증)

### 강의 · 교안 설계
- Carnegie Mellon Eberly Center (강의계획서 설계)
- PMC Gottlieb et al. 2024 (Educator's Blueprint)

### 슬라이드 설계
- PMC Naegle 2021 (Ten Simple Rules for Effective Slides)
- McGill University Teaching KB (교육용 슬라이드 설계)
- Marp, Slidev, reveal.js 공식 문서
