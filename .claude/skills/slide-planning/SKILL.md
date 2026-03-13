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
- Step 3: 2관점 검증 (학습자 대변인: One Idea Rule/Mayer/6×6/AE적용률, 시간 관리자: GRR 밀도 균형/세션 간 편중/12유형 3유형 이상) → review_result.md. 정량적 장수 확정은 Phase 3에서 수행
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
4. §3 레이아웃 후보가 세션별로 완결적인지 확인 (12유형 중 최소 3유형 이상 포함)

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

### Phase 4: 기획안 작성 → writer-agent (슬라이드별 4레이어 명세)

Phase 4는 architecture.md §3의 슬라이드 골격을 세션별 4레이어 명세(CONTENT/VISUAL/SPEAKER_NOTE/IMPL_HINT)로 확장한다. 분할 모드 판단 후, Part별로 writer-agent를 순차 호출한다.

#### Step 4-0: 분할 판단

```
1. Read `{output_dir}/architecture.md` §3 → total_slides 파싱
2. Read `{output_dir}/input_data.json` → session_manifest 로드
3. 분할 판단:
   - total_slides ≤ 80 → 단일 모드 (1회 호출로 전체 세션 작성)
   - total_slides > 80 → 세션별 분할 모드 (sessions + 2 Part)
4. session_manifest 순서대로 세션 목록 확정
```

#### Step 4-1: Part 0 — §1~§3 (Header)

**Agent 호출**:
- **subagent_type**: `writer-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 4 기획안 작성을 수행하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-write.md`를 로드하여 따르세요.

**모드**: Part 0/{total_parts} (§1~§3 Header)
**실행 Step**: Step 0(입력 로드) + Step 1(§1 기획 개요 + §2 공통 가이드) + Step 2(§3 표기법 + 12유형별 가이드)

**입력 경로**:
  - `{output_dir}/architecture.md` — §1~§9
  - `{output_dir}/brainstorm_result.md` — §1~§7
  - `{output_dir}/input_data.json` — slide_config, session_manifest
  - 템플릿: `.claude/templates/slide-plan-template.md`

**산출물**: `{output_dir}/_plan_header.md` (§1~§3)
```

**완료 확인**: Glob `{output_dir}/_plan_header.md` → §1, §2, §3 섹션 존재 확인

#### Step 4-2: Part 1~S — §4 세션별 슬라이드 명세

session_manifest 순서대로 각 세션에 대해 순차 호출한다.

**Agent 호출** (세션별 반복):
- **subagent_type**: `writer-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 4 기획안 작성을 수행하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-write.md`를 로드하여 따르세요.

**모드**: Part {part_num}/{total_parts} (§4 세션 {session_id})
**실행 Step**: Step 3 (해당 세션의 슬라이드 명세만 작성)

**세션 정보**:
  - session_id: {session_id}
  - title: {title}
  - duration_min: {duration_min}
  - slides: {slides_count}
  - content_type: {content_type}
  - slo: {slo}
  - grr: {grr_breakdown}

**architecture.md §3 해당 세션 슬라이드 목록**:
{architecture §3에서 해당 세션 행들을 추출하여 전달}

**입력 경로**:
  - `{output_dir}/architecture.md` — §3 해당 세션
  - `{output_dir}/brainstorm_result.md` — §1~§5 (해당 세션 관련)
  - `{output_dir}/input_data.json` — slide_config
  - session 파일: `{source_script.lecture_root}/02_script/session_{session_id}.md`

**Overlap 컨텍스트**: {이전 세션 slides_*.md의 마지막 SLIDE 블록, 또는 "없음"}

**산출물**: `{output_dir}/slides_{session_id}.md`
```

**완료 확인**: Glob `{output_dir}/slides_{session_id}.md` → 파일 존재 + `[SLIDE` 블록 수 = 해당 세션 slides_count 확인

**Overlap 추출**: 세션 완료 후, 생성된 `slides_*.md`의 마지막 `### [SLIDE` 블록(~50줄)을 Read로 추출하여 다음 세션 호출 시 전달

#### Step 4-3: Part N — §5~§8 (Footer)

**Agent 호출**:
- **subagent_type**: `writer-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 4 기획안 작성을 수행하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-write.md`를 로드하여 따르세요.

**모드**: Part {total_parts}/{total_parts} (§5~§8 Footer)
**실행 Step**: Step 4(§5 유형 분포 집계 + §6 인터랙션 목록) + Step 5(§7 코드 워크스루 + §8 제작 참고)

**입력 경로**:
  - `{output_dir}/slides_D*.md` — 모든 세션별 슬라이드 명세 (Read하여 집계)
  - `{output_dir}/architecture.md` — §3 검증 기준
  - `{output_dir}/brainstorm_result.md` — §5 코드 워크스루
  - `{output_dir}/input_data.json` — design_tone

**산출물**: `{output_dir}/_plan_footer.md` (§5~§8)
```

**완료 확인**: Glob `{output_dir}/_plan_footer.md` → §5, §6, §7, §8 섹션 존재 확인

#### Step 4-4: GATE-4 검증 + 병합

GATE-4 검증 (6항목):

```
1. 파일 존재: _plan_header.md + slides_*.md (session_manifest 수) + _plan_footer.md 모두 존재
2. 슬라이드 수 일치: 각 slides_*.md의 [SLIDE] 블록 수 합 = architecture §3 total_slides
3. 시간 합산: 각 세션의 체류 시간 합 = duration_min (§8-4 검증 체크리스트)
4. AE 적용률: _plan_footer.md §5-2의 GRR 구간별 AE 적용률 기준 충족
5. 세션 완전성: session_manifest의 모든 세션 ID에 대응하는 slides_*.md 존재
6. §1~§8 완전성: _plan_header.md(§1~§3) + slides_*.md(§4) + _plan_footer.md(§5~§8) = 8개 섹션 완전
```

GATE-4 통과 시 → 병합:

```
1. Read `{output_dir}/_plan_header.md` → 콘텐츠 A
2. session_manifest 순서대로 각 `{output_dir}/slides_D{day}-{num}.md` Read → 콘텐츠 B[i]
3. Read `{output_dir}/_plan_footer.md` → 콘텐츠 C
4. Write `{output_dir}/slide_plan.md`:
   - 콘텐츠 A (§1~§3)
   - "## §4 세션별 슬라이드 명세" 헤딩
   - 콘텐츠 B[1] ~ B[S] (세션 순서대로)
   - 콘텐츠 C (§5~§8)
```

GATE-4 실패 시 → 실패 항목 보고 후 사용자에게 확인 요청

---

### Phase 5: 품질 검토 → review-agent (AE 구조, Mayer 원칙, GRR 밀도, 도구 구현)

Phase 5는 GATE-4를 통과한 기획안의 **품질**을 검증한다. 세션별 검토 → 통합 검토 → 판정 → (필요 시) 재작성 루프로 구성한다.

#### Step 5-0: 검토 범위 결정

```
1. Read `{output_dir}/input_data.json` → session_manifest 로드
2. session_manifest의 세션 목록 확정 → 세션별 검토 순서 결정
3. source_script.lecture_root 확인 → session 파일 경로 확정
```

#### Step 5-1: 세션별 검토 (session_manifest 순서대로 순차 호출)

**Agent 호출** (세션별 반복):
- **subagent_type**: `review-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 5 품질 검토를 수행하세요.

**지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-review.md`를 로드하여 따르세요.

**모드**: 세션별 검토 모드 — 세션 {session_id}
**실행 Step**: Step 0(입력 로드) + Step 1(D-1~D-7) + Step 2(G-1~G-7) + Step 3(T-1~T-3) + Step 4(C-1~C-8) + Step 5(I-1~I-7) + Step 6(세션 판정)

**세션 정보**:
  - session_id: {session_id}
  - title: {title}
  - duration_min: {duration_min}
  - slides: {slides_count}
  - content_type: {content_type}
  - slo: {slo}
  - grr: {grr_breakdown}

**입력 경로**:
  - `{output_dir}/slides_{session_id}.md` — 검증 대상
  - `{output_dir}/architecture.md` — §3 슬라이드 골격 기준
  - `{output_dir}/brainstorm_result.md` — §1~§5 시각화 소재
  - `{output_dir}/input_data.json` — slide_config, session_manifest
  - session 파일: `{source_script.lecture_root}/02_script/session_{session_id}.md`
  - 템플릿: `.claude/templates/slide-plan-template.md`

**산출물**: `{output_dir}/_review_session_{session_id}.md`
```

**완료 확인**: Glob `{output_dir}/_review_session_{session_id}.md` → 파일 존재 + 판정(PASS/CONDITIONAL PASS/REVISION REQUIRED) 포함 확인

#### Step 5-2: 통합 검토

모든 세션별 검토 완료 후, slide_plan.md 전체의 구조 완전성과 세션 간 일관성을 검증한다.

**Agent 호출**:
- **subagent_type**: `review-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 5 품질 검토를 수행하세요.

**지시사항**: `.claude/agents/review-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-review.md`를 로드하여 따르세요.

**모드**: 통합 검토 모드
**실행 Step**: Step 0(입력 로드) + Step 1(S-1~S-6) + Step 2(크로스 세션 일관성) + Step 3(T-4~T-6 집계 정합) + Step 4(통합 판정)

**입력 경로**:
  - `{output_dir}/slide_plan.md` — 병합된 기획안
  - `{output_dir}/_review_session_*.md` — 세션별 검토 결과 전부
  - `{output_dir}/architecture.md` — 구조 기준
  - `{output_dir}/input_data.json` — session_manifest

**산출물**: `{output_dir}/quality_review.md`
```

**완료 확인**:
1. Glob `{output_dir}/quality_review.md` → 파일 존재 확인
2. Read → 최종 판정(PASS/CONDITIONAL PASS/REVISION REQUIRED) 확인
3. 검증 항목 41개 결과 존재 확인

#### Step 5-3: GATE-5 판정

```
1. Read `{output_dir}/quality_review.md` → 최종 판정 추출
2. 판정별 후속 조치:
   - PASS → Phase 5 완료. 사용자에게 완료 보고
   - CONDITIONAL PASS → 사용자에게 Minor 위반 목록 보고. "수정 진행/현재 상태 유지" 선택 요청
   - REVISION REQUIRED → Step 5-4 재작성 루프 진행
```

#### Step 5-4: 재작성 루프 (최대 1회)

REVISION REQUIRED 판정 시, Major 위반이 있는 세션만 재작성한다.

```
1. quality_review.md §3 Major 위반에서 해당 세션 ID 목록 추출
2. 해당 세션별로 writer-agent revision 모드 호출:
```

**Agent 호출** (Major 위반 세션별 반복):
- **subagent_type**: `writer-agent`
- **prompt**:

```
슬라이드 기획 워크플로우의 Phase 4 기획안 작성을 수행하세요.

**지시사항**: `.claude/agents/writer-agent/AGENT.md`를 읽고 라우팅에 따라 `slide-planning-write.md`를 로드하여 따르세요.

**모드**: revision (세션 재작성)

**입력 경로**:
  - `{output_dir}/slides_{session_id}.md` — 현재 파일
  - `{output_dir}/_review_session_{session_id}.md` — Major 위반 + 수정 가이드
  - `{output_dir}/architecture.md` — §3 기준
  - `{output_dir}/input_data.json` — slide_config

**산출물**: `{output_dir}/slides_{session_id}.md` (전체 Write 교체)
```

재작성 완료 후:

```
3. 재작성된 세션만 Step 5-1 세션별 검토 재실행
4. Step 5-2 통합 검토 재실행
5. Step 5-3 GATE-5 재판정
   - PASS/CONDITIONAL PASS → Phase 5 완료
   - REVISION REQUIRED (2회차) → 사용자에게 보고 후 중단
```

---

## 산출물 (03_slide_plan/)

```
lectures/YYYY-MM-DD_{강의명}/03_slide_plan/
├── input_data.json              # Phase 1: 교안 로드 + 도구/형식 선택
├── brainstorm_plan.md           # Phase 2: 브레인스토밍 계획
├── divergent_ideas.md           # Phase 2: 발산 아이디어
├── idea_clusters.md             # Phase 2: 클러스터링
├── review_result.md             # Phase 2: 다관점 검증
├── brainstorm_result.md         # Phase 2: 최종 브레인스토밍
├── architecture.md              # Phase 3: 슬라이드 구조 설계
├── _plan_header.md              # Phase 4: §1~§3 (기획 개요+공통 가이드+표기법)
├── slides_D{day}-{num}.md       # Phase 4: 세션별 슬라이드 명세 ★ (×세션 수)
├── _plan_footer.md              # Phase 4: §5~§8 (유형 분포+인터랙션+코드+제작 참고)
├── slide_plan.md                # Phase 4: 최종 기획안 (병합) ★
├── _review_session_{id}.md      # Phase 5: 세션별 검토 결과 (×세션 수)
└── quality_review.md            # Phase 5: 최종 품질 검토 ★
```
