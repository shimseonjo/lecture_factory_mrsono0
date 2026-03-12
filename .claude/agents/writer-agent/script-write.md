# 강의교안 작성 (Phase 6) 세부 워크플로우

### 설계 원칙

| 차원 | 구성안 Phase 6 | 교안 Phase 6 |
|------|--------------|-------------|
| 산출물 성격 | 설계 문서 (What) | 실행 문서 (How) — 강사가 바로 수업 가능 |
| §4/§5 상세도 | 교시당 10~15줄 (활동 요약) | 교시당 80~120줄 (발화문+발문+활동지시+시간큐) |
| 고유 요소 | 없음 | 발화문, 발문스크립트, 행동지시, Think-Aloud, 전환문구, 예상반응 |
| 2-레이어 분리 | 없음 | 발화문(`> "..."`) vs 행동지시(`[...]`) 시각 구분 |
| 예상 분량 | 1,678행 (3일) | 4,000~6,000행 (3일) |
| 분할 모드 | 3-Part | Day별 분할 (days+2 Part) |
| GAIDE 매핑 | 동일 | 동일 (Setup→Draft→Macro→Micro→Integration) |

**5대 핵심 원칙**:

1. **GAIDE 5단계 적용**: 구성안과 동일
2. **번역자 역할**: Architecture의 시간 블록·GRR·Gagne를 **강사 발화문**으로 변환
3. **2-레이어 분리**: 발화문(인용블록 `> "..."`)과 행동지시(대괄호 `[...]`) 시각 구분
4. **입력 충실성**: 5개 입력 파일의 데이터만 사용, 팩트 창작 금지
5. **15분 법칙**: 강사 단독 발화 블록은 15분 이하, 초과 시 bridging activity 삽입

**교안 콘텐츠 5대 원칙** (기술 교육 시 특히 엄격 적용):

| 원칙 | 교안 적용 |
|------|----------|
| 완전성 | 모든 코드·명령어는 복사 가능한 fenced code block(``` ```)으로 제공. `[코드 시연: ...]` 같은 플레이스홀더 금지 |
| 명확성 | 코드 내 파일명·경로·클래스명을 정확히 표기. 코드 블록 상단에 파일명 주석 포함 |
| 재현성 | 각 코드 실행 후 예상 결과(콘솔 출력, API 응답, UI 상태)를 명시. 학습자가 혼자서 100% 재현 가능 |
| 추적성 | 코드 출처(context7 라이브러리명, 공식 문서 URL, brainstorm §4 소재 ID) 명시 |
| 비생략 | 코드를 임의로 요약하거나 `// ...` 로 생략하지 않음. 강사가 화면에 보여줄 코드 전체를 담음 |

### 전체 흐름

```
Step 0: 입력 로드 + 검증 (GAIDE Setup)
  │     architecture.md + brainstorm_result.md + research_deep.md
  │     + input_data.json + context7_reference.md(선택) + script-template.md
  │
  ├── Step 1: §1 강의 개요 + §2 학습 목표 요약 (GAIDE Draft-1)
  │   └── 교수 모델, 시간 구조, CLO-SLO 매핑, 표기법 안내
  │
  ├── Step 2: §3 공통 교안 구조 (GAIDE Draft-2)
  │   └── 교수 모델별 50분 내부 구조, GRR×Gagne 통합 패턴, 발문 수준 가이드
  │
  ├── Step 3: §4 차시별 교안 작성 (GAIDE Draft-3) ★ 핵심 Step
  │   └── Day별 각 교시의 full script (발화문+발문+활동+시간큐+전환)
  │
  ├── Step 4: §5 형성평가 집계 + §6 발문 모음 (GAIDE Macro Refinement)
  │   └── §4에서 인라인 작성된 내용을 Quick Reference로 집계
  │
  ├── Step 5: §7 교재/참고자료 + §8 강사 가이드 (GAIDE Micro Refinement)
  │   └── 오개념 대응 카드, 시간 초과 축소 전략, 메타포, 트러블슈팅
  │
  └── (Step 6 삭제 — 통합은 Phase 8 오케스트레이터가 수행)
```

### 산출물 목록 (3계층 Bottom-Up)

```
{output_dir}/
├── _header.md                      # Phase 6: §1~§3 (Part 0)
├── session_D1-1.md ~ D{N}-{M}.md  # Phase 6: 차시별 독립 파일 ★
├── _footer.md                      # Phase 6: §5~§8 (Part N)
├── block_D{day}_{AM|PM}.md        # Phase 8: 블록별 통합 (1차 병합)
└── lecture_script.md               # Phase 8: 최종 통합 (2차 병합) ★
```

### 분할 작업 모드 (Part Mode) — Bottom-Up 3계층

**분할 판단 기준**: `total_sessions` (총 교시 수)

| 조건 | 모드 | Part 수 |
|------|------|---------|
| `total_sessions ≤ 10` | 단일 모드 | 1 |
| `total_sessions > 10` | 블록별 분할 | blocks + 2 |

블록 수와 경계는 오케스트레이터가 architecture.md 시간표를 파싱하여 동적으로 결정한다:
- 각 Day에 30분 이상 공백(점심 등)이 있고 `sessions_in_day ≥ 6`이면 AM/PM 2블록으로 분할
- 그 외에는 Day 전체를 1블록으로 처리
- 블록 ID: `D{day}_{AM|PM}` (분할 시) 또는 `D{day}` (미분할 시)

#### 블록별 분할 모드 (동적) — 차시별 독립 파일

| Part | 범위 | Step | 산출물 |
|------|------|------|--------|
| Part 0/{N} | §1~§3 | Step 0~2 | `_header.md` (Write 신규) |
| Part 1/{N} | §4 blocks[0] 세션들 | Step 3 (블록 세션만) | `session_D{day}-{num}.md` × 세션 수 (각각 Write 신규) |
| ... | §4 blocks[K] 세션들 | Step 3 (블록 세션만) | `session_D{day}-{num}.md` × 세션 수 (각각 Write 신규) |
| Part B/{N} | §4 blocks[B-1] 세션들 | Step 3 (마지막 블록) | `session_D{day}-{num}.md` × 세션 수 (각각 Write 신규) |
| Part {N}/{N} | §5~§8 | Step 4~5 | `_footer.md` (Write 신규) |

**핵심 변경**: 호출 단위는 **블록** 유지 (8회), 산출물만 **차시별 독립 파일**로 변경.

```
이전:  writer-agent(D1-AM) → lecture_script.md append (4차시 한번에)
변경:  writer-agent(D1-AM) → session_D1-1.md, session_D1-2.md, session_D1-3.md, session_D1-4.md (4파일 독립 Write)
```

이유: 호출 수 최소화(8회 유지) + 차시별 독립 파일 이점 + 블록 내 용어 일관성 유지

**예시: 3일×8시간 (6블록 → 8 Part)**

| Part | 범위 | 산출물 |
|------|------|--------|
| Part 0/8 | §1~§3 | `_header.md` |
| Part 1/8 | §4 D1-AM | `session_D1-1.md`, `session_D1-2.md`, `session_D1-3.md`, `session_D1-4.md` |
| Part 2/8 | §4 D1-PM | `session_D1-5.md`, `session_D1-6.md`, `session_D1-7.md`, `session_D1-8.md` |
| Part 3/8 | §4 D2-AM | `session_D2-1.md`, `session_D2-2.md`, `session_D2-3.md`, `session_D2-4.md` |
| Part 4/8 | §4 D2-PM | `session_D2-5.md`, `session_D2-6.md`, `session_D2-7.md`, `session_D2-8.md` |
| Part 5/8 | §4 D3-AM | `session_D3-1.md`, `session_D3-2.md`, `session_D3-3.md`, `session_D3-4.md` |
| Part 6/8 | §4 D3-PM | `session_D3-5.md`, `session_D3-6.md`, `session_D3-7.md`, `session_D3-8.md` |
| Part 7/8 | §5~§8 | `_footer.md` |

**예시: 3일×4시간 (3블록 → 5 Part)**

| Part | 범위 | 산출물 |
|------|------|--------|
| Part 0/5 | §1~§3 | `_header.md` |
| Part 1/5 | §4 D1 | `session_D1-1.md`, `session_D1-2.md`, `session_D1-3.md`, `session_D1-4.md` |
| Part 2/5 | §4 D2 | `session_D2-1.md`, `session_D2-2.md`, `session_D2-3.md`, `session_D2-4.md` |
| Part 3/5 | §4 D3 | `session_D3-1.md`, `session_D3-2.md`, `session_D3-3.md`, `session_D3-4.md` |
| Part 4/5 | §5~§8 | `_footer.md` |

#### 차시별 독립 파일 작성 규칙

각 `session_D{day}-{num}.md`에는 해당 교시의 **완전한 교안**이 포함된다:

```markdown
# D{day}-{num}: {주제} ({분}분)

## 메타데이터
| 항목 | 내용 |
|------|------|
| SLO | {SLO 코드}: {목표} (Bloom's: {수준}) |
| 교수 모델 | {모델명} |
| GRR 중심 | {단계} |
| content_type | {hands-on / concept / activity} |

## 도입 ({분}분) — Gagne 1~3
[script-template.md 구조]

## 전개 ({분}분) — Gagne 4~7 × GRR
[script-template.md 구조]

## 정리 ({분}분) — Gagne 8~9
[script-template.md 구조]

**Gagne 체크**: {N}/9
**필요 자료**: {슬라이드, 핸즈아웃, 소프트웨어}
```

- 각 session 파일은 **독립 실행 가능**: 해당 차시만으로도 수업 진행 가능
- Step 3의 교시별 작성 내용(3-1)과 동일한 구조를 따르되, 파일 단위로 분리
- 파일 시작에 Day 헤딩(`### Day {N}: {테마}`)은 포함하지 않는다 — 블록 병합 시 추가

#### Overlap 컨텍스트 수신 규칙

블록 호출 시 이전 블록의 마지막 차시 내용을 참조하여 차시 간 전환의 일관성을 보장한다.

| 블록 순서 | Overlap 입력 |
|-----------|-------------|
| 첫 번째 블록 | 없음 |
| 두 번째 이후 | 이전 블록 마지막 차시 `session_*.md`의 **정리 섹션** (마지막 50~100줄) |

**Overlap 사용 방법**:
- 전환 문구(`🔄`) 작성 시 이전 차시의 정리 내용을 참조
- 첫 교시 도입부의 Gagne 사태3(선수학습 회상)에 이전 차시 핵심 내용 반영
- Overlap이 추출 실패하거나 빈 경우: 일반적인 전환 문구로 작성

#### `_header.md` 포함 범위

Part 0에서 Write하는 `_header.md`에는 다음이 포함된다:
- §1 강의 개요 (기본 정보, 교수 모델, 표기법 안내)
- §2 학습 목표 요약 (CLO-SLO 매핑, 차시-SLO 배정 매트릭스)
- §3 공통 교안 구조 (교수 모델별 50분 내부 구조, GRR×Gagne 패턴, 발문 수준 가이드)
- §4 Day 헤딩 목록: 각 Day의 `### Day {N}: {테마}` 헤딩만 미리 작성 (교시 내용은 session 파일에)

#### `_footer.md` 포함 범위

Part {N}에서 Write하는 `_footer.md`에는 다음이 포함된다:
- §5 형성평가 집계 (차시별 형성평가 일람, 총괄평가 설계, 루브릭)
- §6 발문 모음 (도입부/전개부/정리부 발문 Quick Reference)
- §7 교재 및 참고자료
- §8 강사 가이드 (오개념 대응 카드, 시간 초과 축소 전략, 메타포, 트러블슈팅, 사전 확인)

`_footer.md` 작성 시 모든 `session_*.md` 파일을 Read하여 §4 인라인 내용에서 §5~§6을 집계한다.

#### 분할 모드 공통 규칙

- 각 Part는 다른 Part가 작성한 파일을 수정하지 않는다
- 각 `session_*.md`는 완전한 단일 교시 교안을 담는 독립 파일이다
- 각 Part는 메타데이터 헤더(차시, 교수모델, SLO)를 Part 입력 컨텍스트로 제공받는다
- 오케스트레이터가 prompt에 `블록 세션` 목록을 전달하므로, 해당 세션만 작성한다
- **통합(병합)은 writer-agent가 수행하지 않는다** — Phase 8 오케스트레이터가 담당

#### revision 모드 (차시 재작성)

Phase 7 블록별 검토에서 REVISION_REQUIRED 판정 시, 해당 블록의 차시 파일을 재작성하는 모드.

| 항목 | 내용 |
|------|------|
| 입력 | `session_D{day}-{num}.md` (해당 블록의 차시 파일들), `_review_block_{block_id}.md` (위반 목록 + 수정 가이드) |
| 도구 | Read, Write |
| 산출물 | `session_D{day}-{num}.md` (해당 차시 파일 전체 Write로 교체) |

**동작**:
1. `_review_block_{block_id}.md` Read → Major 위반 사항 + 수정 가이드 추출
2. 해당 블록의 `session_*.md` 파일들 Read → 현재 내용 파악
3. 위반 사항이 있는 차시만 재작성 (다른 차시 파일은 **절대 수정하지 않는다**)
4. Write 도구로 해당 `session_*.md` 파일 전체를 교체 (Edit가 아닌 **Write**)
5. 재작성 시에도 Gagne ≥ 7/9, GRR 순서, 시간 합산 준수

---

### 금지 사항

**공통**: `shared/prohibited-rules.md`를 Read하여 따른다.

**교안 추가**:
- **발문 수준 변경 금지**: architecture.md §5의 Bloom's 수준 배정을 변경하지 않는다
- **형성평가 배치 변경 금지**: architecture.md §4의 Entry/During/Exit 배치를 변경하지 않는다
- **표기법 혼용 금지**: §1-3에서 정의한 표기법을 전체 §4에서 일관되게 사용한다

---

### Step 0: 입력 로드 + 검증

| 항목 | 내용 |
|------|------|
| 입력 | `{output_dir}/architecture.md`, `{output_dir}/brainstorm_result.md`, `{output_dir}/research_deep.md`, `{output_dir}/input_data.json`, `{output_dir}/context7_reference.md` (선택), `{output_dir}/context7_block_{block_id}.md` (블록 모드 시, 존재하면) |
| 도구 | Read |
| 산출물 | (내부 컨텍스트 — `_header.md` 또는 `session_*.md` 또는 `_footer.md`에 반영) |

**동작**:

0. `.claude/templates/input-schema-script.json` 읽기 — script_config 각 필드의 enum 값, 의미, 필드 간 관계를 사전 이해

1. 5개 파일을 순서대로 Read:

| 파일 | 핵심 소비 섹션 | 역할 |
|------|-------------|------|
| `architecture.md` | §2(교수모델), §3(차시내부구조 ★), §4(형성평가), §5(발문수준), §6(전환설계) | 시간 블록·GRR·Gagne의 골격 |
| `brainstorm_result.md` | §1(발문), §2(활동), §3(사례·훅), §4(설명전략), §5(Gagne구현), §6(오개념) | 콘텐츠 소재 |
| `research_deep.md` | §3-2(확보된소재 — 차시×SLO×GRR 매핑) | 검증된 외부 소재 |
| `input_data.json` | `script_config` (teaching_model, time_ratio, bloom_question_map, formative_assessment, instructional_model_map, activity_strategies, tone_examples) | 설정값 |
| `context7_reference.md` | 라이브러리별 API/문서/코드 예제 (존재 시) | 기술 교육용 참조 |
| `context7_block_{block_id}.md` | 블록별 정밀 기술 문서·코드 예제 (블록 모드 시, 존재하면) | 블록별 기술 참조 |

3. 템플릿 로드:
   - `.claude/templates/script-template.md` Read

4. 데이터 무결성 검증:
   - architecture.md §3의 차시 수 = input_data.json의 schedule에서 계산한 총 교시 수
   - architecture.md §8 검증 결과에서 6항목 모두 Pass 확인
   - brainstorm_result.md §1~§6 각 섹션 존재 확인
   - 파일 누락 시 → 해당 파일명 명시하고 중단

---

### Step 1: §1 강의 개요 + §2 학습 목표 요약

| 항목 | 내용 |
|------|------|
| 입력 | input_data.json, architecture.md §1~§2 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_header.md`에 포함 |

구성안과 달리 **교안 실행에 필요한 최소한의 개요만** 작성한다 (구성안에 상세 내용이 이미 있으므로).

**동작**:

#### 1-1. §1 강의 개요

- **§1-1 기본 정보**: input_data.json에서 강의명, 대상, 형태, 교수모델, 일정 (5행 테이블)
- **§1-2 교수 모델 및 시간 구조**: teaching_model, time_ratio, GRR 중심 단계 (architecture.md §2에서)
- **§1-3 표기법 안내**: 교안 전체에서 사용하는 마크다운 표기 규칙

**표기법 안내** (교안 고유):

| 표기 | 의미 | 예시 |
|------|------|------|
| `> "..."` | 강사 발화문 (실제 말할 내용) | `> "오늘은 Claude Code의 기본 구조를 배워보겠습니다."` |
| `[...]` | 행동 지시 (비발화 동작) | `[슬라이드 3 표시]` `[30초 대기]` |
| `❓ [LN]` | 발문 (Bloom's 수준 태그) | `❓ [L3 적용] "이 상황에 어떻게 적용하겠습니까?"` |
| `📋` | 활동 지시 | `📋 개인 실습 (10분): ...` |
| `⏱️` | 시간 큐 | `⏱️ (경과: 15분 / 잔여: 35분)` |
| `🔄` | 전환 문구 | `🔄 "방금 ~를 살펴봤습니다. 이제 직접 해볼 차례입니다."` |
| `💬` | 예상 학습자 반응 | `💬 예상: "~" / 오답 시: "~"` |

#### 1-2. §2 학습 목표 요약

- **§2-1 CLO-SLO 매핑**: 구성안 architecture.md §2에서 CLO-SLO 테이블 간략 인용
- **§2-2 차시-SLO 배정 매트릭스**: 교시별 담당 SLO 한눈에 보기

---

### Step 2: §3 공통 교안 구조

| 항목 | 내용 |
|------|------|
| 입력 | architecture.md §2(교수모델), §3(차시내부구조), §5(발문수준) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_header.md`에 포함 |

**동작**:

#### 2-1. §3-1 50분 교시 내부 구조 (교수 모델별)

- 직접교수법 (8분/35분/7분): I Do→We Do→You Do 순차
- PBL (10분/35분/5분): We Do Together 중심
- 플립러닝 (5분/40분/5분): We Do→You Do Together 중심
- 각 모델별 Gagne 사태 강조점

#### 2-2. §3-2 GRR × Gagne 통합 패턴

```
도입 (Gagne 1+2+3): Hook → SLO 고지 → 선수학습 연결
전개 I Do (Gagne 4+5): 시연 + Think-Aloud 4대 메타인지 발화
전개 We Do (Gagne 5+6+7): 안내연습 + 즉각 피드백
전개 You Do (Gagne 6+7): 독립연습
정리 (Gagne 8+9): 형성평가 + 전이
```

#### 2-3. §3-3 발문 수준 가이드

- architecture.md §5의 Bloom's × Socratic 매핑을 교안 실행용으로 정리
- 도입(L1~L2 명료화) → 전개(L2~L4 가정탐색·근거탐구) → 정리(L4~L6 함의·메타인지)

---

### Step 3: §4 차시별 교안 ★ 핵심 Step

| 항목 | 내용 |
|------|------|
| 입력 | architecture.md §3(차시내부구조), brainstorm_result.md §1~§6, research_deep.md §3-2, input_data.json, context7_reference.md, context7_block_{block_id}.md (블록 모드 시) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/session_D{day}-{num}.md` (차시별 독립 파일) |

**이 Step이 교안 분량의 75~80%를 차지한다.**

각 Day → 각 교시에 대해 `script-template.md` 구조를 따라 full script를 작성한다.

#### 3-1. 교시별 작성 내용

```markdown
#### D{N}-{M}: {주제} ({분}분)

| 항목 | 내용 |
|------|------|
| SLO | {SLO 코드}: {목표} (Bloom's: {수준}) |
| 교수 모델 | {모델명} |
| GRR 중심 | {단계} |

##### 도입 ({분}분) — Gagne 1~3

[Gagne 1] 주의 획득
> "강사 발화문 — 흥미 유발"

[행동 지시]

❓ [L1 명료화] "발문 텍스트"
💬 예상: "..." / 오답 시: "..."

[Gagne 2] 학습목표 고지
> "오늘 이 시간이 끝나면 여러분은 ~를 할 수 있게 됩니다."

[Gagne 3] 선수학습 회상
> "지난 시간에 ~를 배웠습니다..."
❓ [L1~L2] "복습 발문"
📋 Entry 형성평가: {방법} ({분}분)

⏱️ (경과: {분}분)

##### 전개 ({분}분) — Gagne 4~7 × GRR

**I Do: 시범/설명** ({분}분) — Gagne 4+5
> "강사 발화문 — 개념 설명"
> [Think-Aloud — 계획] "먼저 ~부터 시작하겠습니다. 왜냐하면..."
> [Think-Aloud — 모니터링] "이 부분이 맞는지 확인해보겠습니다..."
[슬라이드 N 표시]
❓ [L2~L3 가정탐색] "발문"
💬 예상: "..."

🔄 "방금 ~를 살펴봤습니다. 이제 함께 해볼까요?"

**We Do: 안내 실습** ({분}분) — Gagne 5+6
> "강사 발화문 — 함께 실습 안내"
📋 안내 실습 ({분}분):
  - 시작: "지금부터 ~를 함께 해보겠습니다."
  - 단계: 1. ... 2. ... 3. ...
  - 성공 기준: "~가 되면 완성입니다."
❓ [L3~L4 근거탐구] "발문"
📋 During 형성평가: {방법} ({분}분)

⏱️ (경과: {분}분)

**You Do Together: 그룹 실습** ({분}분) — Gagne 6
📋 그룹 실습 ({분}분):
  - 구성: {인원/방법}
  - 과제: "..."
  - 성공 기준: "..."
> "강사 역할: 순회 피드백"

**You Do Alone: 독립 실습** ({분}분) — Gagne 6+7
📋 독립 실습 ({분}분):
  - 과제: "..."
  - 제출물: "..."
> "강사 역할: 개별 피드백"

🔄 "여기까지 잘 해오셨습니다. 이제 정리해볼까요?"
⏱️ (경과: {분}분)

##### 정리 ({분}분) — Gagne 8~9

[Gagne 8] 수행 평가
📋 Exit 형성평가: {방법} ({분}분)
  - 대상 SLO: {코드}
  - Bloom's: {수준}
❓ [L4+ 함의·결과] "정리 발문"

[Gagne 9] 파지·전이
> "오늘 배운 핵심은 세 가지입니다: ①... ②... ③..."
> "실제 업무에서는 ~할 때 이것을 활용할 수 있습니다."
🔄 "다음 시간에는 ~를 배울 예정입니다. 오늘 배운 ~가 기초가 됩니다."

**Gagne 체크**: {N}/9
**필요 자료**: {슬라이드, 핸즈아웃, 소프트웨어}
```

#### 3-2. 데이터 소스 우선순위

| 우선순위 | 소스 | 적용 대상 |
|---------|------|----------|
| 1 | architecture.md §3 | 시간 블록, GRR 단계, Gagne 사태 배정 (골격) |
| 2 | context7_block_{block_id}.md | 블록별 정밀 기술 문서·코드 예제 ★ (**content_type == "hands-on" 차시 I Do 필수** — 코드 블록 원본) |
| 3 | context7_reference.md | 기술 문서·코드 예제 ★ (**content_type == "hands-on" 차시 I Do 필수** — block 파일 없으면 이것 사용) |
| 4 | brainstorm_result.md §1 | 발문 텍스트 (도입/전개/정리별) |
| 5 | brainstorm_result.md §2 | 학습활동 (GRR 단계별) |
| 6 | brainstorm_result.md §3 | 실생활 사례·훅 (도입 Hook / 전개 사례 / 정리 전이) |
| 7 | brainstorm_result.md §5 | Gagne 9사태 구현 방안 |
| 8 | brainstorm_result.md §4 | 설명 전략·비유 (메타포, 예시-비예시) |
| 9 | brainstorm_result.md §6 | 오개념 교정 발문·활동 |
| 10 | research_deep.md §3-2 | 확보된 소재 (차시×SLO×GRR 매핑) |
| 11 | input_data.json tone_examples | 비유/메타포 |

#### 3-2a. brainstorm 소재 필수 통합 규칙

brainstorm_result.md의 소재는 "참조"가 아니라 **"교안 발화문으로 통합"**해야 한다. 레이블이나 항목명만 남기지 않는다.

| brainstorm 섹션 | 통합 방법 | 금지 |
|---------------|---------|------|
| §1 발문 | 발문 텍스트 + 예상 답변을 교안 해당 구간에 삽입. 발문 앞뒤에 강사 도입·정리 발화 추가 | 발문만 단독 배치 |
| §3 사례·훅 | 도입부 Hook에 **스토리텔링 형태**로 전개 (인물·상황·결과 포함) | 사례명만 레이블로 표기 |
| §4 설명전략 | I Do 발화문에 **비유 전개 + 예시-비예시 쌍**을 강사 말로 풀어쓰기 | 표나 리스트로만 제시 |
| §5 Gagne 구현 방안 | 해당 Gagne 사태 발화문에 구현 방안 내용을 자연스럽게 반영 | 구현 방안 칼럼 무시 |
| §6 오개념 | 해당 차시 전개부에 교정 발문·활동을 삽입 | 오개념 목록만 §8에 배치 |

#### 3-3. 강사 발화문 작성 규칙

**기본 원칙**: 강사가 이 교안만 읽고 수업을 진행할 수 있어야 한다. 발화문은 실제 말할 내용을 빠짐없이 담는다.

- 전문 용어 사용 시 즉시 일상 언어로 부연
- input_data.json의 tone(비유 중심 등) 반영

**어조 및 화법**:
- 친절한 구어체를 사용한다. 딱딱한 문어체(~한다)가 아닌 부드러운 설명체(~해요, ~입니다)를 기본으로 한다
- 나쁜 예: "변수를 선언한다. 코드는 다음과 같다."
- 좋은 예: "자, 이제 변수를 선언해 볼까요? 이 변수는 데이터를 담는 그릇 역할을 해요."
- 단, 실습 지시는 명확하고 간결한 명령조를 유지하되, 앞뒤로 부드러운 연결 멘트를 추가한다

**GRR 구간별 내용 기준** (분량 제한 없음 — 내용이 충분해야 한다):

| GRR 구간 | 내용 기준 |
|---------|---------|
| 도입 (Gagne 1~3) | Hook 스토리 + 학습목표 설명 + 선수학습 연결. brainstorm §3의 사례·훅을 스토리텔링 형태로 전개 |
| I Do 시범 (Gagne 4~5) | **핵심 개념 설명** + 비유/메타포 전개 + 예시-비예시 쌍 + Think-Aloud 4대 메타인지. brainstorm §4의 설명전략을 발화문으로 풀어쓴다. **content_type == "hands-on" 시: context7 코드를 fenced code block으로 삽입하고, 강사 발화로 코드를 줄 단위로 설명한다. 코드 없는 I Do 금지.** content_type == "concept" 시: 코드 선택적, 개념 설명에 도움이 되면 간단한 예시 코드 포함. |
| We Do 안내 (Gagne 5~6) | 절차 안내 + 각 단계별 강사 코멘트 + 예상 실수 대응. 학습자와 함께 진행하는 과정을 대화체로 작성. **content_type == "hands-on" 시: 스캐폴드 코드(빈 칸/TODO 포함)를 제공하고, 각 단계에서 채울 부분을 발화로 안내한다.** |
| You Do (Gagne 6~7) | 과제 안내 + 성공 기준 설명 + 순회 피드백 시 강사 발화 예시. **content_type == "hands-on" 시: 시작 코드 골격 + 완성 시 예상 실행 결과(콘솔 출력, API 응답)를 코드 블록으로 제공한다.** |
| 정리 (Gagne 8~9) | 핵심 요약 + 전이 시나리오 + 다음 차시 연결 |

**강사 발화 = 실제 대본**: `> "..."` 블록은 강사가 말할 내용 전체를 담는다. 개념을 설명하고, 비유를 들고, 예시를 보여주고, 학습자에게 질문하는 흐름이 자연스럽게 이어져야 한다.

#### 3-3a. 기술 교육 코드·시각화 규칙

**(A) 코드 배치 원칙** (content_type == "hands-on" 차시 I Do·We Do·You Do 공통, concept 차시 선택적):

| 코드 규모 | 배치 방법 |
|-----------|----------|
| 짧은 코드 (≤20줄) | 강사 발화 직후에 전체 코드 블록 배치 |
| 중간 코드 (21~50줄) | 강사 발화 직후에 전체 코드 블록 배치 + §7 코드 모음에도 포함 |
| 긴 코드 (>50줄) | 핵심 부분만 발췌하여 발화 직후 배치 + 전체 코드는 §7 코드 모음 참조 링크 |

**(B) GRR 구간별 코드 형식**:

| GRR 구간 | 코드 형식 | 예시 |
|---------|---------|------|
| I Do | **완성 코드** — 강사가 시연할 전체 코드. 주석으로 핵심 포인트 표시 | `// ← @Service 어노테이션으로 Bean 등록` |
| We Do | **스캐폴드 코드** — 빈 칸/TODO가 있는 코드. 학습자가 채울 부분 표시 | `@___Mapping("/{id}") // TODO: HTTP 메서드` |
| You Do | **과제 명세 + 예상 결과** — 시작 코드 골격 + 완성 시 예상 출력 | 시작 코드 → 예상 API 응답 JSON |

**(C) 코드 블록 작성 규칙**:
- 언어 지정 필수: ` ```java `, ` ```python `, ` ```bash ` 등
- 파일명 주석: 첫 줄에 `// 파일: src/main/java/com/example/CustomerService.java`
- 실행 결과: 코드 다음에 `**예상 결과**:` + 출력 코드 블록

**(D) 시각화 규칙** (아키텍처·흐름 설명 시):
- 아키텍처/데이터 흐름 → Mermaid `flowchart` 또는 `graph`
- 시간 순서 상호작용 → Mermaid `sequence diagram`
- 한글 레이블 → 따옴표 필수: `["한글 노드명"]`
- Mermaid 블록은 설명 발화 바로 아래에 배치

**(E) `[코드 시연: ...]` 플레이스홀더 금지 규칙** (content_type == "hands-on" 차시 적용):
- `[코드 시연: ...]`, `[코드 예시]`, `[데모]` 같은 행동 지시로 실제 코드를 대체하는 것을 **금지**한다
- 대신: `[코드 시연]` 행동 지시 + 바로 아래에 **실제 코드 블록** + 강사 발화로 코드 설명

형식 예시:
```
[코드 시연: CustomerService 생성]

```java
// 파일: src/main/java/com/example/service/CustomerService.java
@Service
public class CustomerService {
    private final List<Customer> customers = new ArrayList<>();

    public List<Customer> getAllCustomers() {  // ← Controller에서 위임받은 메서드
        return customers;
    }
}
```

> "먼저 @Service 어노테이션을 봐주세요. 이게 Spring에게 '이 클래스는 서비스 역할이에요'라고 알려주는 표시예요. Controller의 @RestController와 같은 원리입니다. 그리고 getAllCustomers()는 Controller에 있던 그 메서드를 그대로 옮긴 거예요."
```

#### 3-4. Think-Aloud 패턴 (I Do 단계 필수)

4대 메타인지 발화:
- **계획**: "먼저 ~부터 시작하겠습니다. 왜냐하면..."
- **모니터링**: "이 부분이 맞는지 확인해보겠습니다..."
- **평가**: "이 방법이 효과적인 이유는..."
- **자기교정**: "아, 이 부분은 다시 해야겠습니다..."

brainstorm §5의 Gagne 사태4(자료 제시) 구현 방안에서 구체적 내용을 참조한다.

#### 3-5. 발문 스크립트 작성 규칙

- brainstorm_result.md §1의 발문을 기본으로 사용
- 각 발문에 Bloom's 수준 태그 필수: `❓ [L3 적용]`
- 예상 답변 또는 오답 처리를 1개 이상 포함: `💬 예상: "..." / 오답 시: "..."`
- brainstorm §1에 발문이 없는 차시는 architecture.md §5의 수준에 맞춰 발문 스템 패턴으로 생성

#### 3-6. 활동 지시문 작성 규칙

- 시작 시점, 소요 시간, 성공 기준 3요소 필수
- brainstorm §2의 활동 설명을 우선 사용
- research_deep §3-2의 확보된 소재 중 해당 차시/SLO/GRR에 매핑된 것을 통합

#### 3-7. 전환 문구 작성 규칙

- architecture.md §6의 전환 설계(Bridge/Review/Preview)를 발화문으로 변환
- 도입→전개, GRR 단계 간, 전개→정리 전환에 각 1개 이상
- 패턴: "방금 ~를 살펴봤습니다. 이제 ~를 해볼 차례입니다."

#### 3-8. 15분 법칙 적용

- I Do 세그먼트가 15분 초과 시 중간에 Bridging Activity 삽입
- Bridging: Think-Pair-Share, 확인 발문, 마이크로 실습 (1~2분)

---

### Step 4: §5 형성평가 집계 + §6 발문 모음 (Quick Reference)

| 항목 | 내용 |
|------|------|
| 입력 | Step 3(§4)에서 작성된 인라인 형성평가·발문 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_footer.md`에 포함 |

**동작**:

#### 4-1. §5 형성평가 집계

- **§5-1 차시별 형성평가 일람**: §4에서 작성한 Entry/During/Exit 형성평가를 테이블로 집계
  - 컬럼: 차시 | 시점 | 유형 | 대상 SLO | 방법 | 소요시간
- **§5-2 총괄평가 설계**: 구성안 architecture.md §3-3에서 가져오기
- **§5-3 루브릭**: 구성안 architecture.md §3-4에서 가져오기 (필요 시 보완)

#### 4-2. §6 발문 모음 (교안 고유 — Quick Reference)

§4에서 인라인 작성된 발문을 수업 단계별로 집계한다. 강사가 수업 전 한눈에 발문 흐름을 확인하는 레퍼런스 용도.

- **§6-1 도입부 발문 (L1~L2)**: 차시 | 발문 | Bloom's | 소크라테스유형
- **§6-2 전개부 발문 (L2~L5)**: 차시 | 발문 | Bloom's | 소크라테스유형
- **§6-3 정리부 발문 (L4~L6)**: 차시 | 발문 | Bloom's | 소크라테스유형

---

### Step 5: §7 교재/참고자료 + §8 강사 가이드

| 항목 | 내용 |
|------|------|
| 입력 | research_deep §3-2(소재), §3-3(미해결), input_data.json(tone_examples), brainstorm §2(Should/Could), §6(오개념) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_footer.md` |

**동작**:

#### 5-1. §7 교재 및 참고자료

- **§7-1 Day별 필요 자료/도구**: §4에서 각 교시에 기록한 "필요 자료"를 Day별로 집계
- **§7-2 필수 참고자료**: research_deep §3-2의 확보된 소재에서 출처가 있는 자료 + context7 기술 문서
- **§7-3 보충 자료**: 자율학습용

#### 5-2. §8 강사 가이드 (교안 고유 확장)

- **§8-1 오개념 대응 카드**: brainstorm §6의 오개념 목록을 카드 형식으로 정리
  - 각 카드: 오개념 | 발생 예상 차시 | 교정 발문 | 교정 활동 | 출처
- **§8-2 시간 초과 축소 전략**: brainstorm §2의 Should/Could 항목에서 축소 가능 항목
- **§8-3 메타포 목록**: input_data.json tone_examples 테이블
- **§8-4 환경 설정 트러블슈팅**: research_deep §3-2에서 추출 (없으면 "해당 없음")
- **§8-5 사전 확인 필요 항목**: research_deep §3-3 미해결 항목

---

### Step 6 (삭제됨 — 통합은 Phase 8 오케스트레이터가 수행)

> **주의**: Bottom-Up 3계층 구조에서 writer-agent는 개별 파일(`_header.md`, `session_*.md`, `_footer.md`)만 작성한다.
> 블록 병합(`block_*.md`) 및 최종 통합(`lecture_script.md`)은 Phase 8 오케스트레이터(SKILL.md)가 직접 Read+Write로 수행한다.

---

## lecture_script.md 산출물 구조 (Phase 8 병합 후 최종 형태)

```markdown
# 강의교안

## 메타데이터
## 1. 강의 개요
  ### 1-1. 기본 정보
  ### 1-2. 교수 모델 및 시간 구조
  ### 1-3. 표기법 안내
## 2. 학습 목표 요약
  ### 2-1. CLO-SLO 매핑
  ### 2-2. 차시-SLO 배정 매트릭스
## 3. 공통 교안 구조
  ### 3-1. 50분 교시 내부 구조 (교수 모델별)
  ### 3-2. GRR × Gagne 통합 패턴
  ### 3-3. 발문 수준 가이드
## 4. 차시별 교안 ★
  ### Day {N}: {테마}
    #### D{N}-{M}: {주제} ({분}분)
      [script-template.md 구조 반복]
## 5. 형성평가 집계
  ### 5-1. 차시별 형성평가 일람
  ### 5-2. 총괄평가 설계
  ### 5-3. 루브릭
## 6. 발문 모음 (Quick Reference)
  ### 6-1. 도입부 발문
  ### 6-2. 전개부 발문
  ### 6-3. 정리부 발문
## 7. 교재 및 참고자료
  ### 7-1. Day별 필요 자료/도구
  ### 7-2. 필수 참고자료
  ### 7-3. 보충 자료
## 8. 강사 가이드
  ### 8-1. 오개념 대응 카드
  ### 8-2. 시간 초과 축소 전략
  ### 8-3. 메타포 목록
  ### 8-4. 환경 설정 트러블슈팅
  ### 8-5. 사전 확인 필요 항목
```
