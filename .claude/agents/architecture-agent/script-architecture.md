# 강의교안 아키텍처 설계 (Phase 5) 세부 워크플로우

### 설계 원칙

구성안 Phase 5가 **Top-down** 설계(학습 결과 → 평가 → 차시 배정)라면, 교안 Phase 5는 **Bottom-up** 설계(확정된 차시 내부를 교수 모델별로 채움)이다.

**변경 불가 기준**: 구성안 `architecture.md`의 모든 내용 (CLO, SLO, 차시 배정, 정렬 맵, 시간 예산)은 변경하지 않는다. 교안 Phase 5는 이 확정 구조의 **내부**를 설계한다.

**적용 프레임워크**:
- **Gagne 9사태** (9 Events of Instruction): 차시 내부 구조의 골격 (U. Florida CITT, Utah State, NIU CITL)
- **GRR** (Gradual Release of Responsibility): 전개부 시간 배분 (Fisher & Frey, DePaul University, ASCD)
- **Bloom's 발문 수준 패턴**: 수업 단계별 발문 수준 (U. Pittsburgh, UNC Learning Center, TopHat)
- **CMU Eberly 3점 형성평가 배치 모델**: Entry-During-Exit (CMU Eberly Center, Columbia CPET)
- **교수 모델별 수업 구조**: Hunter 6단계(직접교수법), PBL 6단계, Before/During/After(플립러닝) (CITL Illinois, CMU)
- **강의 분절 10~15분 규칙**: 연속 강의 15분 이하 분절 (Michigan CRLT)
- **Socratic × Bloom's 교차 매핑**: 발문 유형과 인지 수준 교차 (Paul & Elder)

### 전체 흐름

```
Step 0: 입력 로드 + 변경 불가 기준 확정
  │     구성안 architecture.md(변경 불가) + brainstorm + research_deep + input_data.json + context7_reference(존재 시)
  │
  ├── Step 1: 차시별 교수 모델 확정 + 시간 비율 + GRR 배분
  │
  ├── Step 2: 차시 내부 구조 설계 (Gagne 9사태 × GRR × Bloom's)
  │
  ├── Step 3: 형성평가 3점 배치 + 발문 수준 배정
  │
  └── Step 4: 차시 간 전환 설계 + 검증 + 산출물 통합 → architecture.md
```

### 산출물 목록

```
{output_dir}/
└── architecture.md    # Phase 5: 교안 아키텍처 설계 최종 산출물 ★
```

---

### Step 0: 입력 로드 + 변경 불가 기준 확정

| 항목 | 내용 |
|------|------|
| 입력 | 7개 파일 (아래 목록) |
| 도구 | Read |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

1. **스키마 사전 이해**: `.claude/templates/input-schema-script.json`을 읽고 script_config 각 필드의 enum 값, 의미, 필드 간 관계를 이해한다.

2. **7개 파일 로드**:

| # | 파일 | 역할 | 변경 가능 |
|---|------|------|----------|
| 1 | 구성안 `architecture.md` | CLO, SLO, 차시 배치, 정렬 맵, 시간 예산 | ✗ 변경 불가 |
| 2 | 교안 `input_data.json` | teaching_model, time_ratio, activity_strategies, bloom_question_map, formative_assessment | ✗ 변경 불가 |
| 3 | `brainstorm_result.md` | §1 발문, §2 활동, §3 사례/훅, §4 설명 전략, §5 Gagne, §6 오개념 | 참조용 |
| 4 | `research_deep.md` | 통합 시사점 (확정된 전제, 확보된 소재, 미해결 항목) | 참조용 |
| 5 | `context7_reference.md` | 오케스트레이터가 사전 수집한 기술 문서/코드 예제 (존재 시) | 참조용 |
| 6 | 구성안 `lecture_outline.md` | 강의 전체 구조 참조 | 참조용 |
| 7 | 구성안 `input_data.json` | 원본 강의 입력 참조 | 참조용 |

3. **구성안 architecture.md에서 추출**:
   - §2-2: SLO 목록 (차시별 Bloom's 수준 포함)
   - §3-2: 형성평가 계획
   - §4-2: 차시별 상세 배치 (Day별 → 교시별 하위 주제, 활동 유형, SLO)
   - §4-2.5: 일별 시간표
   - §5-1: 종합 정렬 매트릭스

4. **교안 input_data.json에서 추출**:
   - `script_config.teaching_model`: 교수 모델 (direct_instruction/pbl/flipped/mixed)
   - `script_config.mixed_model_map`: mixed일 때 Day별 모델
   - `script_config.time_ratio`: 도입:전개:정리 비율
   - `script_config.activity_strategies`: 활동 전략 목록
   - `script_config.formative_assessment`: 형성평가 계획
   - `script_config.bloom_question_map`: 차시별 발문 수준 매핑
   - `script_config.instructional_model_map`: 교수설계 모델 매핑
   - `source_outline.lecture_root`: 강의 루트 경로

5. **차시 목록 구성**:
   - `script_config.target_sessions == "all"`: 구성안 architecture.md의 전체 차시
   - `script_config.target_sessions == "selected"`: `selected_days`에 해당하는 Day만

---

### Step 1: 차시별 교수 모델 확정 + 시간 비율 + GRR 배분

| 항목 | 내용 |
|------|------|
| 입력 | Step 0에서 추출한 데이터 |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

#### 1-1. 교수 모델별 시간 비율

`input_data.json`의 `time_ratio`를 기반으로 차시별 시간을 계산한다 (50분 기준):

| 교수 모델 | 도입 | 전개 | 정리 | GRR 중심 |
|-----------|------|------|------|---------|
| direct_instruction | 10% (5분) | 60% (30분) | 30% (15분) | I Do → We Do → You Do |
| pbl | 10% (5분) | 75% (38분) | 15% (7분) | We Do Together 중심 |
| flipped | 5% (3분) | 80% (40분) | 15% (7분) | We Do → You Do Together |
| mixed | 10% (5분) | 70% (35분) | 20% (10분) | 차시별 모델 비율 적용 |

`session_minutes`가 50분이 아닌 경우, 비율(%)을 기준으로 시간(분)을 재계산한다.

#### 1-2. Gagne 9사태 강조점 (교수 모델별)

각 교수 모델에서 특별히 강조할 Gagne 사태를 결정한다:

| 교수 모델 | 강조 사태 | 약화/이동 사태 | 근거 |
|-----------|----------|-------------|------|
| direct_instruction | 사태4(자료 제시) + 사태5(학습 안내) | — | Hunter: 정보제공+시범이 핵심 |
| pbl | 사태1(문제 시나리오) + 사태6(그룹 문제해결) | 사태4 축소 (학습자 발견) | PBL: 문제 시나리오가 학습 촉발 |
| flipped | 사태6(수업 중 활동) + 사태7(피드백) | 사태3·4 수업 전 이동 | 사전학습에서 내용 습득, 수업 중 활동·피드백 중심 |

#### 1-3. GRR 시간 배분 (전개 시간 내)

차시 유형에 따라 전개부 내 GRR 4단계 시간 비율을 차등 배분한다:

| 차시 유형 | I Do | We Do | You Do Together | You Do Alone |
|-----------|------|-------|-----------------|-------------|
| 신규 개념 | 35~40% | 25~30% | 20~25% | 10~15% |
| 기존 심화 | 15~20% | 20~25% | 30~35% | 20~25% |
| 복습/통합 | 5~10% | 15~20% | 25~30% | 35~40% |

**차시 유형 판별 알고리즘**:

```
for each 차시:
  bloom_level = 구성안 architecture.md §2-2 SLO의 Bloom's 수준
  is_first_appearance = 해당 하위 주제가 이 차시에서 처음 등장하는가
  position = 차시가 전체 과정에서 어디에 위치하는가 (초반/중반/후반)

  if is_first_appearance AND bloom_level in [기억, 이해]:
    → 신규 개념
  elif bloom_level in [적용, 분석] AND NOT is_first_appearance:
    → 기존 심화
  elif bloom_level in [평가, 창조] OR position == 후반:
    → 복습/통합
  else:
    → 기존 심화 (기본값)
```

#### 1-4. 교수설계 모델 매핑

`instructional_model_map`에서 주 모델과 보조 모델을 확인한다:

| teaching_model | primary_model | secondary_model | grr_focus |
|---------------|--------------|----------------|-----------|
| direct_instruction | Hunter_6step | Gagne | i_do_we_do_you_do |
| pbl | PBL_6step | Gagne | you_do_together |
| flipped | Before_During_After | Gagne | we_do_you_do_together |

---

### Step 2: 차시 내부 구조 설계 (Gagne × GRR × Bloom's)

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~1 결과, brainstorm_result.md, context7_reference.md |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

각 차시별로 도입-전개-정리의 세부 시간 블록을 설계한다.

#### 2-1. 도입부 설계 (Gagne 사태 1~3)

교수 모델별로 도입부 내부 시간 블록을 다르게 구성한다:

**직접교수법 도입부** (8분, 16%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 2분 | 사태1: 주의획득 | 흥미 유발 질문/사례/시연 | 발문 또는 시연 |
| 1분 | 사태2: 목표 고지 | "이 시간에 배울 것" 안내 | SLO 직접 제시 |
| 5분 | 사태3: 선수학습 회상 | 전 차시 복습 Q&A | 발문 + 확인 |

**PBL 도입부** (10분, 20%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 5분 | 사태1: 문제 시나리오 | 실세계 문제 상황 제시 | 시나리오 내레이션 |
| 5분 | 사태2+3: 문제 분석 + 목표 설정 | 문제 구조화, 알고 있는 것/모르는 것 분류 | 질문 촉진자 |

**플립러닝 도입부** (5분, 10%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 3분 | 사태3: 사전학습 확인 | Poll/퀴즈로 사전학습 이해도 확인 | Poll 진행 |
| 2분 | 사태1+2: 질문 수집 + 목표 | 사전학습 중 궁금했던 점 수집 | 질문 정리 |

#### 2-2. 전개부 설계 (Gagne 사태 4~7 × GRR)

전개부는 GRR 4단계를 Gagne 사태와 교차 매핑하여 설계한다:

| GRR 단계 | Gagne 사태 | 활동 유형 | 강사 역할 | 분절 규칙 |
|----------|-----------|----------|----------|----------|
| I Do | 사태4+5 (자료 제시, 학습 안내) | 설명, 시연, 예시 | 시범 제공자 | **10~15분 이하 분절** 필수 |
| We Do | 사태5+6 (학습 안내, 수행 유도) | 안내 실습, 함께 문제 해결 | 가이드 |  |
| You Do Together | 사태6 (수행 유도) | 그룹 실습, 협업 활동 | 관찰 + 순회 | |
| You Do Alone | 사태6+7 (수행 유도, 피드백) | 독립 실습, 개인 과제 | 피드백 제공자 | |

**I Do 분절 규칙** (Michigan CRLT):
- 연속 강의 15분 초과 금지
- 15분 이상 설명 필요 시 → 중간에 bridging activity(짧은 확인 질문, Think-Pair-Share) 삽입
- 분절 단위: 10~15분 설명 + 2~3분 확인 활동

**교수 모델별 전개부 GRR 차이**:

- **직접교수법**: I Do → We Do → You Do 순차적 진행. I Do 비중 최대.
- **PBL**: We Do Together 중심. I Do는 필요 시 미니 레슨(5분 이내)으로 삽입.
- **플립러닝**: 사태4(자료 제시)가 수업 전으로 이동됨. We Do + You Do Together 중심.

`context7_reference.md`가 존재하면, 각 시간 블록에서 커버할 기술 문서/API/코드 예제를 `기술 참조` 컬럼으로 배정한다.

#### 2-3. 정리부 설계 (Gagne 사태 8~9)

교수 모델별로 정리부를 설계한다:

**직접교수법 정리부** (7분, 14%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 5분 | 사태8: 수행 평가 | Exit 평가 (퀴즈/체크포인트) | 평가 진행 |
| 2분 | 사태9: 파지·전이 | 핵심 요약 + 다음 차시 Preview | 요약 제시 |

**PBL 정리부** (5분, 10%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 3분 | 사태8: 성찰 + 자기 평가 | 학습 일지 / 성찰 질문 | 성찰 촉진자 |
| 2분 | 사태9: 다음 단계 계획 | 다음 차시 문제 해결 계획 공유 | 계획 정리 |

**플립러닝 정리부** (5분, 10%):

| 시간 | Gagne 사태 | 활동 | 강사 역할 |
|------|-----------|------|----------|
| 3분 | 사태8: Exit Ticket | 핵심 개념 확인 질문 | 평가 진행 |
| 2분 | 사태9: 사전학습 안내 | 다음 차시 사전학습 자료 안내 | 자료 배포 |

#### 2-4. Gagne 9사태 커버리지 체크

각 차시 설계 완료 후 Gagne 9사태 커버리지를 확인한다:

| # | Gagne 사태 | 수업 단계 | 필수 여부 |
|---|-----------|----------|----------|
| 1 | 주의획득 (Gaining Attention) | 도입 | 필수 |
| 2 | 목표 고지 (Informing Learners of Objectives) | 도입 | 필수 |
| 3 | 선수학습 회상 (Stimulating Recall) | 도입 | 필수 |
| 4 | 자료 제시 (Presenting Content) | 전개 I Do | 필수 |
| 5 | 학습 안내 (Providing Guidance) | 전개 I Do/We Do | 필수 |
| 6 | 수행 유도 (Eliciting Performance) | 전개 We Do/You Do | 필수 |
| 7 | 피드백 제공 (Providing Feedback) | 전개 You Do | 필수 |
| 8 | 수행 평가 (Assessing Performance) | 정리 | 필수 (사태6 이후) |
| 9 | 파지·전이 촉진 (Enhancing Retention & Transfer) | 정리 | 권장 |

**최소 커버리지**: 각 차시 7/9 이상. 사태8은 반드시 사태6 이후에 배치.

---

### Step 3: 형성평가 3점 배치 + 발문 수준 배정

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~2 결과, input_data.json의 formative_assessment, bloom_question_map |
| 도구 | Read, Write |
| 산출물 | (Step 4에서 architecture.md에 통합) |

**동작**:

#### 3-1. CMU Eberly 3점 배치 모델

각 차시에 형성평가를 3개 시점에 배치한다 (CMU Eberly Center, Columbia CPET):

| 배치 시점 | 수업 단계 | Gagne 사태 후 | 소요 시간 | 목적 | 필수 여부 |
|----------|----------|-------------|----------|------|----------|
| Entry | 도입 (사태3 후) | 선수학습 회상 후 | 1~3분 | 선수 지식 확인, 출발점 파악 | 권장 |
| During | 전개 (We Do 후) | 수행 유도 중간 | 2~3분 | 오개념 실시간 포착, 이해 확인 | 권장 |
| Exit | 정리 (사태8) | 수행 평가 시점 | 3~5분 | SLO 달성 확인 | **필수** (모든 차시) |

**평가 방법 예시**:
- Entry: 짧은 Poll, Warm-up 퀴즈, 전 차시 핵심 개념 1문항
- During: Think-Pair-Share 결과 확인, 실습 체크포인트, 빠른 손들기
- Exit: Exit Ticket(1~3문항), 실행 결과 캡처, 1분 요약

#### 3-2. SLO-평가 정합

구성안 architecture.md §3-2의 형성평가 계획과 교안 input_data.json의 `formative_assessment.assessment_plan`을 교차 확인한다:

- Exit 질문의 Bloom's 수준 = 해당 SLO의 Bloom's 수준
  - 예: SLO가 "적용" 수준이면 Exit 질문도 "적용" 수준 (실습 수행 확인)
- `formative_assessment.slo_coverage`에서 모든 SLO가 최소 1회 평가되는지 확인
- 미커버 SLO 발견 시 → 해당 차시의 During 또는 Exit에 평가 추가

#### 3-3. Bloom's 발문 수준 패턴

`input_data.json`의 `bloom_question_map.per_session`을 참조하여 수업 단계별 발문 수준을 배정한다:

| 수업 단계 | 발문 수준 | 설명 | 예시 패턴 |
|----------|----------|------|----------|
| 도입 | L1~L2 (기억·이해) | 선수 지식 활성화 | "~은 무엇이었죠?" "차이를 설명해 보세요" |
| 전개 I Do | L2~L3 (이해·적용) | 개념 이해 확인 | "이 상황에 어떻게 적용할까요?" |
| 전개 We/You Do | L3~L4 (적용·분석) | 적용 및 분석 촉진 | "A와 B 방법의 차이점은?" |
| 정리 | L4~L6 (분석~창조) | 심화 사고, 전이 촉진 | "새로운 상황에서 어떻게 활용하겠습니까?" |

**진행 패턴**: 한 차시 내에서 L1→L2→L3→L4 이상으로 점진적 상승.

#### 3-4. Socratic × Bloom's 교차 매핑

`bloom_question_map`의 발문 수준에 Socratic 6유형을 교차 매핑한다 (Paul & Elder):

| Bloom's 수준 | 적합한 Socratic 유형 | 발문 예시 |
|-------------|-------------------|----------|
| L1~L2 (기억·이해) | 명료화 질문 | "~이란 무엇을 의미하나요?" |
| L2~L3 (이해·적용) | 가정 탐색 | "왜 그렇게 생각하나요?" |
| L3~L4 (적용·분석) | 근거 탐구 | "어떤 증거가 그것을 뒷받침하나요?" |
| L4~L5 (분석·평가) | 함의·결과 | "이 접근법의 장단점은?" |
| L5~L6 (평가·창조) | 관점·시각 / 메타인지 | "다른 관점에서 보면?" / "이 과정에서 무엇을 배웠나요?" |

---

### Step 4: 차시 간 전환 설계 + 검증 + 산출물 통합

| 항목 | 내용 |
|------|------|
| 입력 | Step 0~3의 모든 결과 |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/architecture.md` ★ 최종 산출물 |

**동작**:

#### 4-1. 차시 간 전환 패턴

인접 차시 사이의 전환을 설계한다 (Oregon GTF Manual, Ausubel):

| 전환 유형 | 적용 위치 | 소요 시간 | 목적 |
|----------|----------|----------|------|
| Review (복습) | 다음 차시 도입부 | 2~3분 | 전 차시 핵심 요약 recall |
| Bridge (연결) | 도입부 | 1분 | 전·현 차시 개념 간 명시적 연결 |
| Preview (예고) | 정리부 | 1~2분 | 다음 차시 기대감 형성 |
| Advance Organizer | 사태3 후, 사태4 전 | 1~2분 | 새 내용의 전체 구조 제시 (Ausubel) |

**일별 전환 설계**:
- 같은 Day 내 인접 차시: Bridge (1분)
- Day 간 전환 (Day N 마지막 → Day N+1 첫 차시): Review (2~3분) + Preview (1~2분)
- Day 1 첫 차시: 오리엔테이션에서 전체 Preview (구성안 §4-2 참조)

#### 4-2. GRR 연속성 확인

인접 차시 간 GRR 수준이 자연스럽게 이어지는지 확인한다:

```
차시 N의 You Do 수준 → 차시 N+1의 I Do 진입 수준
격차 기준: 인접 GRR 단계 차이 ≤ 1

예시:
  D1-3: You Do Together (Level 3) → D1-4: I Do (Level 1) = 격차 2 ⚠️
  → 조정: D1-4를 We Do(Level 2)로 시작하여 격차 1로 축소
```

#### 4-3. 검증 체크리스트 (6항목)

모든 차시 설계 완료 후 다음 6항목을 검증한다:

| # | 검증 항목 | 기준 | 위반 시 조치 |
|---|----------|------|------------|
| 1 | 시간 합산 | 도입+전개+정리 = session_minutes (각 차시) | 시간 재배분 |
| 2 | Gagne 커버리지 | ≥ 7/9 (각 차시) | 누락 사태 삽입 |
| 3 | SLO 평가 커버리지 | 100% (모든 SLO가 Exit에 포함) | 미커버 SLO에 평가 추가 |
| 4 | GRR 연속성 | 인접 격차 ≤ 1 | 진입 수준 조정 |
| 5 | 강의 분절 | I Do 연속 ≤ 15분 | bridging activity 삽입 |
| 6 | time_ratio 준수 | input_data.json 비율 대비 5% 이내 | 비율 재조정 |

검증 실패 시 해당 Step으로 돌아가 수정한다 (최대 2회 반복).

#### 4-4. architecture.md 통합 작성

Step 0~3의 결과와 검증 결과를 아래 구조로 통합하여 `{output_dir}/architecture.md`를 작성한다.

---

## 교안 architecture.md 산출물 구조

```markdown
# 교안 아키텍처 설계

## 메타데이터
- 강의 주제: {topic}
- 설계 일자: {date}
- 설계 방법론: Gagne 9사태 × GRR × Bloom's 발문 (Bottom-up 차시 내부 설계)
- 변경 불가 기준: 구성안 architecture.md (CLO/SLO/차시 배정/정렬 맵)
- 입력 소스: input_data.json, brainstorm_result.md, research_deep.md, context7_reference.md

---

## 1. 변경 불가 기준 요약

### 1-1. 구성안 참조 정보

| 항목 | 값 | 출처 |
|------|-----|------|
| 총 일수 | {days}일 | 구성안 architecture.md §1 |
| 일일 교시 수 | {N}교시 | 구성안 architecture.md §1 |
| 1교시 시간 | {session_minutes}분 | 구성안 architecture.md §1 |
| CLO 수 | {N}개 | 구성안 architecture.md §2-1 |
| SLO 수 | {N}개 | 구성안 architecture.md §2-2 |

### 1-2. 대상 차시 목록

| Day | 교시 | 하위 주제 | SLO | Bloom's | content_type |
|-----|------|----------|-----|---------|-------------|
| D1 | 1 | {주제} | SLO1-1 | {수준} | {hands-on/concept/activity} |
| ... | ... | ... | ... | ... | ... |

---

## 2. 교수 모델 + 시간 비율 설계

### 2-1. 차시별 교수 모델 배정

| 교수 모델 | {teaching_model_한글} |
| 적용 방식 | {단일/혼합 — mixed인 경우 Day별 모델} |

{mixed인 경우}
| Day | 교수 모델 | 근거 |
|-----|----------|------|
| 1 | {모델} | {근거} |
| ... | ... | ... |

### 2-2. 시간 비율

| 구분 | 비율 | 시간(분) |
|------|------|---------|
| 도입 | {intro}% | {분} |
| 전개 | {main}% | {분} |
| 정리 | {wrap}% | {분} |

### 2-3. GRR 배분 (전개 시간 내)

| 차시 | 차시 유형 | I Do | We Do | You Do Together | You Do Alone |
|------|----------|------|-------|-----------------|-------------|
| D1-1 | 신규 개념 | {분} | {분} | {분} | {분} |
| ... | ... | ... | ... | ... | ... |

### 2-4. Gagne 9사태 강조점

| 사태 | 도입 | 전개 I Do | 전개 We Do | 전개 You Do | 정리 | 강조도 |
|------|------|----------|-----------|-----------|------|--------|
| 1. 주의획득 | ★ | | | | | 필수 |
| 2. 목표 고지 | ★ | | | | | 필수 |
| 3. 선수학습 회상 | ★ | | | | | 필수 |
| 4. 자료 제시 | | ★ | | | | {모델별} |
| 5. 학습 안내 | | ★ | ★ | | | {모델별} |
| 6. 수행 유도 | | | ★ | ★ | | 필수 |
| 7. 피드백 제공 | | | | ★ | | 필수 |
| 8. 수행 평가 | | | | | ★ | 필수 |
| 9. 파지·전이 | | | | | ★ | 권장 |

---

## 3. 차시별 내부 구조

### Day {N}: {테마}

#### D{N}-{M}: {하위 주제}

| 구분 | 시간 | Gagne | GRR | 활동 | 기술 참조 |
|------|------|-------|-----|------|----------|
| 도입 | {분} | 사태1~3 | — | {활동 내용} | — |
| 전개: I Do | {분} | 사태4+5 | I Do | {설명/시연 내용} | {Context7 참조} |
| 전개: We Do | {분} | 사태5+6 | We Do | {안내 실습 내용} | {Context7 참조} |
| 전개: You Do Together | {분} | 사태6 | You Do Together | {그룹 실습 내용} | {Context7 참조} |
| 전개: You Do Alone | {분} | 사태6+7 | You Do Alone | {독립 실습 내용} | — |
| 정리 | {분} | 사태8~9 | — | {평가 + 요약} | — |

**Gagne 체크**: {체크된 사태 수}/9

(차시별 반복)

---

## 4. 형성평가 배치표

### 4-1. 3점 배치 (Entry-During-Exit)

| 차시 | Entry (도입) | During (전개) | Exit (정리) | 대상 SLO |
|------|------------|-------------|-----------|---------|
| D1-1 | {방법, 시간} | {방법, 시간} | {방법, 시간} | SLO1-1 |
| ... | ... | ... | ... | ... |

### 4-2. SLO 커버리지

| SLO | Bloom's | 평가 차시 | 평가 유형 | 커버 |
|-----|---------|----------|----------|------|
| SLO1-1 | {수준} | D1-1 | Exit | ✓ |
| ... | ... | ... | ... | ... |

커버리지: {N}/{N} = 100%

---

## 5. 발문 수준 배정

### 5-1. 차시별 Bloom's-Socratic 매핑

| 차시 | 차시 Bloom's | 도입 발문 | 전개 I Do 발문 | 전개 We/You Do 발문 | 정리 발문 |
|------|------------|----------|-------------|-------------------|----------|
| D1-1 | {수준} | L1~L2 명료화 | L2~L3 가정탐색 | L3~L4 근거탐구 | L4+ 함의·결과 |
| ... | ... | ... | ... | ... | ... |

---

## 6. 차시 간 전환 설계

### 6-1. 전환 매핑

| 전환 | 유형 | 시간 | 내용 |
|------|------|------|------|
| D1-1 → D1-2 | Bridge | 1분 | {연결 내용} |
| D1 → D2 | Review + Preview | 3분 | {복습 + 예고 내용} |
| ... | ... | ... | ... |

### 6-2. GRR 연속성

| 전환 | 이전 You Do 수준 | 다음 I Do 수준 | 격차 | 상태 |
|------|----------------|--------------|------|------|
| D1-1 → D1-2 | Level 3 | Level 2 | 1 | Pass |
| ... | ... | ... | ... | ... |

---

## 7. 기술 문서 참조 매핑

{context7_reference.md 존재 시에만 작성}

| 차시 | GRR 단계 | 라이브러리 | 문서/API | 코드 예제 |
|------|---------|----------|---------|----------|
| D1-1 | I Do | {라이브러리명} | {API/문서 제목} | {예제 요약} |
| ... | ... | ... | ... | ... |

{context7_reference.md 미존재 시: "기술 교육이 아니거나 Context7 수집 결과 없음 — 해당 없음"}

---

## 8. 검증 결과

| # | 검증 항목 | 기준 | 결과 | 상태 |
|---|----------|------|------|------|
| 1 | 시간 합산 | 도입+전개+정리 = {session_minutes}분 | {상세} | Pass/Fail |
| 2 | Gagne 커버리지 | ≥ 7/9 (각 차시) | {최소값}/9 | Pass/Fail |
| 3 | SLO 평가 커버리지 | 100% | {%} | Pass/Fail |
| 4 | GRR 연속성 | 인접 격차 ≤ 1 | {최대 격차} | Pass/Fail |
| 5 | 강의 분절 | I Do ≤ 15분 | {최대 I Do 시간} | Pass/Fail |
| 6 | time_ratio 준수 | 5% 이내 | {최대 차이} | Pass/Fail |

{위반 항목 있으면 조정 내역 기록}

---

## 9. 설계 결정 로그

| # | 결정 | 대안 | 선택 근거 |
|---|------|------|----------|
| 1 | {결정 내용} | {고려한 대안} | {근거} |
```
