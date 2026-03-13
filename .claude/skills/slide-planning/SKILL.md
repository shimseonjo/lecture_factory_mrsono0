---
name: slide-planning
description: 슬라이드 기획 - 5단계 파이프라인 (입력수집 → 브레인스토밍 → 구조설계 → 기획안작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, AskUserQuestion
---

# 슬라이드 기획 워크플로우

## 작업 지시

$ARGUMENTS

## 오케스트레이터 실행 로직

**당신은 5단계 파이프라인의 오케스트레이터다.** 직접 콘텐츠를 작성하지 않는다. 각 Phase를 Agent 도구로 전담 에이전트에 위임하고, Phase 간 데이터 흐름을 관리한다.

### Step 0: 초기화

1. `today` = 오늘 날짜 (YYYY-MM-DD 형식)
2. `project_root` = 현재 작업 디렉토리
3. `output_dir` = Phase 1 완료 후 결정

### Phase 1~5 공통 실행 규칙

각 Phase 실행 시 반드시:
1. Agent 도구로 해당 에이전트 호출 (아래 Phase별 템플릿 사용)
2. 에이전트 반환 후 **필수 산출물 존재 확인** (Glob 또는 Read)
3. 산출물 확인 성공 → 다음 Phase 진행
4. 산출물 확인 실패 → 사용자에게 보고 후 **중단**

---

## 파이프라인 (5단계)

### Phase 1: 입력 수집

**Agent 호출**:
- **subagent_type**: `input-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 입력을 수집하세요.

**지시사항**: `.claude/agents/input-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-input.md`를 로드하여 따르세요.

**핵심 원칙**:
- Step 0: lectures/ 스캔 → 교안 폴더 선택 → 3개 파일 로드 → session 매니페스트 생성
- Step 1: P1~P5 전체 자동 결정 (질문 없음)
  - P1: content_type + lab_environment 분석 → 슬라이드 도구 (marp/slidev)
  - P2: tone/tone_examples 분석 → 디자인 톤 (friendly_visual/professional)
  - P3: 기본값 "전체" (Day 목록 파싱)
  - P4: standard (25-55줄/장) 고정
  - P5: GRR 기반 1차 슬라이드 수 동적 산출
- Step 2: 전체 설정 요약 + AskUserQuestion **반드시 1회** (확인/변경)
  - P1~P5 전체를 요약 + session 매니페스트 출력 후 "이 설정으로 진행할까요?" 확인
  - "변경 필요" 선택 시 해당 항목만 갱신 (예: "P1: slidev", "P3: Day 1만")
- Step 3: input_data.json 생성

**폴더 생성**: 선택된 강의 루트 폴더 아래 `03_slide_plan/` 생성
**산출물**: `03_slide_plan/input_data.json` — 스키마: `.claude/templates/input-schema-slide-planning.json`

**사용자 인자**: {$ARGUMENTS 내용이 있으면 여기에 포함}
```

**완료 확인**:
1. Glob `lectures/*_*/03_slide_plan/input_data.json`으로 생성된 파일 경로 찾기 → `output_dir` 확정
2. Read로 `input_data.json` 로드 → `slide_config` 객체 존재 확인
3. `slide_config.slide_tool`이 유효한 enum 값인지 검증
4. `session_manifest` 배열이 1개 이상 항목 포함 확인

---

### Phase 2: 브레인스토밍 → brainstorm-agent (시각화 아이디어, 레이아웃 구상)

**Agent 호출**:
- **subagent_type**: `brainstorm-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 시각화 브레인스토밍을 수행하세요.

**지시사항**: `.claude/agents/brainstorm-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-brainstorm.md`를 로드하여 따르세요.

**핵심 원칙**:
- Step 0: input_data.json + session 파일 시드 추출 (발화문/코드/발문/비유/활동) → brainstorm_plan.md
- Step 1: 4기법(AE변환/6W매핑/범위전환/인터랙션설계) × session 시드 × 4카테고리(시각화/레이아웃/인터랙션/AE구조) → divergent_ideas.md
- Step 2: 세션별 매핑 + 클러스터링 (GRR 단계, 슬라이드 유형, 도구 적합성) → idea_clusters.md
- Step 3: 2관점 검증 (학습자 대변인: One Idea Rule/Mayer/6×6/AE적용률, 시간 관리자: estimated_slides_grr ±30%/GRR 밀도/1.5~2.1분/장) → review_result.md
- Step 4: AE 구조 + 레이아웃(12유형) + 인터랙션(도구별) + 코드 워크스루(5패턴) + Mayer 8원칙 구체화
- Step 5: 통합 → brainstorm_result.md (§1~§7)

**입력 경로**: `{output_dir}/input_data.json`
  - session 파일: `{source_script.lecture_root}/02_script/session_D{day}-{num}.md`
  - slide_tool: input_data.json의 slide_config.slide_tool 참조
  - design_tone: input_data.json의 slide_config.design_tone 참조

**산출물**: `{output_dir}/brainstorm_result.md` (§1~§7 구조)
```

**완료 확인**:
1. Glob `{output_dir}/brainstorm_result.md`로 생성 확인
2. Read로 brainstorm_result.md 로드 → §1~§7 섹션 존재 확인
3. §1에 session_manifest의 모든 세션 ID가 포함되는지 확인
4. §3 레이아웃 합계가 estimated_slides_grr 대비 ±30% 범위인지 확인

### Phase 3: 슬라이드 구조 설계 → architecture-agent (슬라이드 수, 유형, 순서, 시간 배분)

**Agent 호출**:
- **subagent_type**: `architecture-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 3 슬라이드 구조 설계를 수행하세요.

**지시사항**: `.claude/agents/architecture-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-architecture.md`를 로드하여 따르세요.

**핵심 원칙**:
- Step 0: 4개 파일 로드 (input_data.json + brainstorm_result.md + 교안 architecture.md + 구성안 input_data.json)
  - session_manifest, slide_config, AE 구조(§1), 레이아웃(§3), 인터랙션(§4), 코드 워크스루(§5) 추출
  - 교안 architecture.md의 차시 구조·GRR 배분은 변경 불가 기준
- Step 1: 콘텐츠 기반 2차 슬라이드 수 산출 + GRR 병합
  - §1 AE 테이블 행 카운팅 → estimated_slides_content
  - 병합: final = round(0.6 × GRR + 0.4 × Content)
  - content_type 보정 (hands-on ×0.9, activity ×0.8)
  - 1.5~2.5분/장 범위 clamp
- Step 2: 12유형 배정 + GRR 단계별 배치
  - AE 적용률: I Do ≥80%, We Do ≥60%, You Do ≥30%
  - 구조 슬라이드 자동 삽입 (제목/아젠다/섹션전환/핵심요약)
  - §3 레이아웃 + §5 코드 워크스루 매핑
  - 유형 분포 균형 검증 (텍스트 전용 ≤10%, hands-on 코드 ≥30%)
- Step 3: 슬라이드 시퀀스 + 전환 설계
  - GRR 순서 배열 + Mayer 분절 (I Do 연속 ≤7장)
  - Progressive Disclosure (§4 인터랙션, slide_tool별 구현)
  - Pre-training 슬라이드 배치 (신규 용어 ≥3개 세션)
  - 세션 간/Day 간 전환 패턴
- Step 4: 시간 배분 (유형별 가중치) + 검증(7항목) + architecture.md 통합 작성
  - 7항목: 시간합산, 분/장, AE율, One Idea, GRR편차, 유형분포, 분절

**입력 경로**:
  - `{output_dir}/input_data.json` — session_manifest, slide_config
  - `{output_dir}/brainstorm_result.md` — §1~§7
  - `{source_script.lecture_root}/02_script/architecture.md` — 변경 불가 기준
  - `{source_script.lecture_root}/01_outline/input_data.json` — 원본 참조 (존재 시)

**산출물**: `{output_dir}/architecture.md` (§1~§9 구조)
```

**완료 확인**:
1. Glob `{output_dir}/architecture.md`로 생성 확인
2. Read로 architecture.md 로드 → §1~§9 섹션 존재 확인
3. §2 슬라이드 수 산출 — 전체 합계가 session_manifest 기반 GRR 1차 대비 ±30% 범위인지 확인
4. §3 세션별 구조 — session_manifest의 모든 세션 ID가 포함되는지 확인
5. §8 검증 결과 — 7항목 중 Fail이 0개인지 확인 (Fail 존재 시 조정 내역 확인)

### Phase 4: 기획안 작성 → writer-agent (슬라이드별 목적, 레이아웃, 핵심 콘텐츠)

<!-- TODO: Phase 4 오케스트레이터 로직 구현 예정 -->

### Phase 5: 품질 검토 → review-agent (정보 밀도, 시각 계층, 학습목표 정렬)

<!-- TODO: Phase 5 오케스트레이터 로직 구현 예정 -->

## 산출물 (03_slide_plan/)

```
lectures/YYYY-MM-DD_{강의명}/03_slide_plan/
├── input_data.json              # Phase 1: 교안 로드 + 도구/형식 선택
├── brainstorm_result.md         # Phase 2: 브레인스토밍
├── architecture.md              # Phase 3: 슬라이드 구조 설계
├── slide_plan.md                # Phase 4: 최종 기획안 ★
└── quality_review.md            # Phase 5: 품질 검토
```
