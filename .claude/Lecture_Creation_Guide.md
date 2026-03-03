# Lecture Creation Guide - 강의 제작 파이프라인 가이드

Lecture Factory 프로젝트의 전체 강의 제작 워크플로우를 정의합니다.

## 전체 파이프라인 개요

```
/lecture-outline  →  /lecture-script   →  /slide-planning    →  /slide-generation
  강의구성안             강의교안            슬라이드 기획         슬라이드 생성 프롬프트
  (6단계)               (6단계)             (5단계)              (3단계)
```

각 워크플로우는 독립 실행 가능하며, 이전 단계의 산출물을 입력으로 참조합니다.

---

## 아키텍처

### Skill 오케스트레이터 패턴

Skill이 직접 오케스트레이터 역할을 하며, `Agent` 도구로 공통 에이전트를 순차 호출합니다.

```
/lecture-outline (Skill = 오케스트레이터)
     ├── Phase 1: Agent → input-agent
     ├── Phase 2: Agent → brainstorm-agent
     ├── Phase 3: Agent → research-agent
     ├── Phase 4: Agent → architecture-agent
     ├── Phase 5: Agent → writer-agent
     └── Phase 6: Agent → review-agent
```

- Skill → Agent 호출 (허용)
- Agent → Agent 중첩 (금지)

### 6개 공통 에이전트

| 에이전트 | 역할 | 사용 워크플로우 |
|---------|------|--------------|
| **input-agent** | 사용자 입력 수집 + 이전 산출물 로드 + 컨텍스트 구성 | 구성안, 교안, 슬기획, 슬생성 |
| **brainstorm-agent** | 아이디어 확장, 구체화, 우선순위 분류 | 구성안, 교안, 슬기획 |
| **research-agent** | 인터넷 리서치, 트렌드 분석, 자료 수집 | 구성안, 교안 |
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
| 1 | 입력 수집 | input-agent | 핵심 주제, 대상 학습자, 강의 형태, 시간/차시, 키워드 |
| 2 | 브레인스토밍 | brainstorm-agent | 하위 주제 도출, 학습자 페르소나, 핵심 질문, Bloom's 매핑, 콘텐츠 우선순위(핵심/중요/참고) |
| 3 | 인터넷 리서치 | research-agent | 최신 트렌드, 유사 강의 벤치마킹, 업계 수요, 교수법 사례 |
| 4 | 아키텍처 설계 | architecture-agent | Backward Design(학습결과→평가→학습경험), 정렬 맵, 차시 구조, 시간 배분 |
| 5 | 구성안 작성 | writer-agent | outline-template.md 기반 최종 문서 생성 |
| 6 | 품질 검토 | review-agent | QM Rubric, Bloom's 정렬, 목표-활동-평가 정렬, 시간 배분, 자료 정확성 |

**적용 프레임워크**: Backward Design + GAIDE + 프롬프트 체이닝

**데이터 흐름**:
```
사용자 입력 → input_data.json → brainstorm_result.md → research_report.md
→ architecture.md → lecture_outline.md → quality_review.md
```

**산출물**: `lectures/{강의명}/01_outline.md`

---

### 워크플로우 2: 강의교안 (`/lecture-script`)

**목적**: 구성안을 기반으로 실제 강의에 사용하는 상세 교안을 작성합니다.

| Phase | 단계 | 에이전트 | 핵심 작업 |
|-------|------|---------|----------|
| 1 | 입력 수집 | input-agent | 구성안 로드, 교수법 선택(직접교수/PBL/플립러닝/액티브러닝) |
| 2 | 브레인스토밍 | brainstorm-agent | 발문 설계(Bloom's 기반), 학습활동 아이디어, 실생활 사례 구상 |
| 3 | 인터넷 리서치 | research-agent | 예시 자료, 사례, 보충 콘텐츠, 참고 문헌 |
| 4 | 교안 구조 설계 | architecture-agent | 도입-전개-정리(10:70:20), Gagne 9가지 수업사태 적용, 시간 배분 |
| 5 | 교안 작성 | writer-agent | script-template.md 기반, 섹션별 스크립트/발문/활동/평가문항/발표자 노트 |
| 6 | 품질 검토 | review-agent | 목표-활동-평가 정렬, 시간 배분 현실성, 용어/톤 일관성 |

**적용 프레임워크**:
- Madeline Hunter 8단계 (직접교수법)
- Gagne의 9가지 수업사태
- Gradual Release of Responsibility (I Do → We Do → You Do)

**교안 구조**:
```
도입 (10-15%): 주의집중 → 동기부여 → 선수학습 확인 → 학습목표 제시
전개 (70-80%): 내용제시 → 시범 → 안내연습 → 독립연습 (× 섹션 수)
정리 (10-15%): 핵심요약 → 실천방법 → 과제안내 → 차시예고
```

**산출물**: `lectures/{강의명}/02_script.md`

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

**산출물**: `lectures/{강의명}/03_slide_plan.md`

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

**산출물**: `lectures/{강의명}/04_slides/`

---

## 산출물 저장 구조

```
lectures/
└── {강의명}/
    ├── 01_outline.md        # 강의구성안
    ├── 02_script.md         # 강의교안
    ├── 03_slide_plan.md     # 슬라이드 기획
    └── 04_slides/           # 슬라이드 파일
        ├── prompts.md       # 생성 프롬프트
        └── slides.md        # 최종 슬라이드 (Marp/Slidev 등)
```

---

## 품질 검증 프레임워크

### 공통 검증 기준

| 영역 | 가중치 | 검증 내용 |
|------|--------|----------|
| 학습 목표 명확성 | 25% | 측정 가능한 동사, 학습자 중심, 수준 적합성 |
| 목표-활동-평가 정렬 | 25% | 정렬 맵 일관성, 누락 없음 |
| 콘텐츠 구조/흐름 | 15% | 논리적 순서, 난이도 점진적 상승 |
| 시간 배분 현실성 | 15% | 인지 과부하 방지, 활동 시간 충분 |
| 자료 정확성/최신성 | 20% | 팩트 체크, AI 환각 검증, 출처 신뢰성 |

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
| **GAIDE** | 구성안 | Setup → 초안 → 매크로 정제 → 마이크로 정제 → 통합 |
| **Gagne 9사태** | 교안 | 주의획득 → 목표고지 → ... → 파지와 전이 촉진 |
| **Hunter 8단계** | 교안 | 선행조직자 → 목표 → 정보제공 → 시범 → 이해확인 → 연습 → 정리 |
| **QM Rubric** | 품질 검토 | 8개 일반 기준, 목표-활동-평가 정렬 |
| **Assertion-Evidence** | 슬라이드 | 주장 제목 + 시각 증거 (불릿포인트 대체) |

---

## 리서치 출처

- Carnegie Mellon Eberly Center (강의계획서 설계)
- NC State DELTA (AI 지원 코스 설계)
- GAIDE Framework, Purdue University (arXiv:2308.12276)
- Virginia Tech CETL (Backward Design)
- Quality Matters Rubric 7th Edition
- OLC Course Review Scorecard
- PMC Naegle 2021 (Ten Simple Rules for Effective Slides)
- PMC Gottlieb et al. 2024 (Educator's Blueprint)
- McGill University Teaching KB (교육용 슬라이드 설계)
- Marp, Slidev, reveal.js 공식 문서
- EduCraft System, Tsinghua University (CIKM 2025)
