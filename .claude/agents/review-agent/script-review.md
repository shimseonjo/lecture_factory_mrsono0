# 강의교안 품질 검토 (Phase 7) 세부 워크플로우

### 설계 원칙

1. **구성안 Phase 7 패턴 재사용**: 점진적 Write(중간 파일 → 통합), 인용 규칙(기대값/실제값/수정가이드), 3단계 판정(PASS/CONDITIONAL PASS/REVISION REQUIRED)
2. **교안 고유 검증 영역 독립 분리**: Gagne 9사태, GRR 4단계, 2-레이어 표기법, Think-Aloud 4대 패턴, CMU 3점 형성평가 배치, 15분 분절 규칙
3. **51개 항목, 6개 영역**: 핵심에 집중하되 교수법 검증을 충분히 커버
4. **자동 판별 기준**: "Gagne 체크 ≥7/9", "I Do ≤15분", "time_ratio ±5%" 등 정량적 기준 최대화
5. **가중치 미적용**: 6개 영역 모두 "강사가 교안만으로 수업 진행 가능한가"에 수렴. Major/Minor 분류로 충분
6. **3단계 판정**: `shared/judgment-criteria.md` 참조

### 구성안 Phase 7 vs 교안 Phase 7

| 차원 | 구성안 Phase 7 | 교안 Phase 7 |
|------|--------------|-------------|
| 검증 대상 | `lecture_outline.md` (설계 문서) | `lecture_script.md` (실행 문서 — 발화문+행동지시) |
| 검증 기준 파일 수 | 4개 | 6개 (+구성안 2파일) |
| 핵심 분량 | §5 교시당 10~15줄 | §4 교시당 80~120줄, 전체 4,000~6,000행 |
| 고유 검증 영역 | 없음 | Gagne, GRR, 2-레이어, Think-Aloud, CMU 3점, 15분 분절, 발화문 자연성 |
| 검증 항목 수 | 38개 (S:6 + L:5 + A:5 + F:4 + T:7 + C:11) | **51개** (S:7 + G:8 + P:7 + T:8 + C:12 + N:9) |
| Step 수 | Step 0~5 (6단계) | Step 0~7 (8단계) |

### 전체 흐름

```
Step 0: 입력 로드
  │     lecture_script.md (검증 대상)
  │     + 02_script/architecture.md + brainstorm_result.md + research_deep.md + input_data.json (검증 기준-교안)
  │     + 01_outline/lecture_outline.md + 01_outline/architecture.md (검증 기준-구성안)
  │
  ├── Step 1: 구조 완전성 검증 (S-1~S-7, 7항목)
  │   └── Write → _review_step1.md
  │
  ├── Step 2: 교수설계 프레임워크 검증 — Gagne/GRR/2-레이어/Think-Aloud (G-1~G-8, 8항목)
  │   └── Write → _review_step2.md
  │
  ├── Step 3: 발문·평가·흐름 검증 — Bloom's/CMU 3점/차시 간 전환 (P-1~P-7, 7항목)
  │   └── Write → _review_step3.md
  │
  ├── Step 4: 시간 배분 현실성 검증 (T-1~T-8, 8항목)
  │   └── Write → _review_step4.md
  │
  ├── Step 5: 콘텐츠 정확성 검증 — Anti-Hallucination (C-1~C-12, 12항목)
  │   └── Write → _review_step5.md
  │
  ├── Step 6: 교안 실행 품질 검증 — 발화문/활동지시/강사가이드 (N-1~N-9, 9항목)
  │   └── Write → _review_step6.md
  │
  └── Step 7: Read _review_step1~6.md → 통합 판정 → Write quality_review.md
```

**점진적 Write 패턴**: Step 1~6 각각의 검증 결과를 중간 파일로 Write한 뒤, Step 7에서 Read하여 통합한다. 7개 입력 파일 + 51개 검증 결과를 동시에 메모리에 유지하는 부담을 줄여 정확도를 높인다.

### 검토 모드

오케스트레이터가 prompt에 명시하는 검토 모드에 따라 검증 범위와 산출물이 달라진다.

| 모드 | 범위 | 검증 영역 | 산출물 |
|------|------|----------|--------|
| **블록별 검토** | 해당 블록의 `session_D*.md` 파일들 (3-4개 차시) | ~44항목 (G+P+T+C+N) | `_review_block_{block_id}.md` |
| **통합 검토** | §1~§8 전체 (블록 검토 완료 후) | ~15항목 (S+블록간일관성) | `quality_review.md` |

**모드 판별**: prompt에 "블록별 검토 모드" 키워드가 있으면 블록별 검토, "통합 검토 모드" 키워드가 있으면 통합 검토를 수행한다.

#### 블록별 검토 모드

블록 범위의 세션만 집중 검증한다. 구조 완전성(S-1~S-7)은 통합 검토에서 수행하므로 **생략**한다.

**절차**:
1. Step 0: 입력 로드 — 해당 블록의 `session_D{day}-{num}.md` 파일들을 Read (lecture_script.md 대신 차시 파일 직접 참조)
2. Step 2: 교수설계 프레임워크 검증 (해당 블록 세션만, G-1~G-8)
3. Step 3: 발문·평가·흐름 검증 (해당 블록 세션만, P-1~P-7)
4. Step 4: 시간 배분 검증 (해당 블록 세션만, T-1~T-8)
5. Step 5: 콘텐츠 정확성 검증 (해당 블록 세션만, C-1~C-12)
6. Step 6: 교안 실행 품질 검증 (해당 블록 세션만, N-1~N-9)
7. 블록 판정 통합 → `_review_block_{block_id}.md`에 Write

중간 산출물(`_review_step1~6.md`)은 블록별 검토에서는 생성하지 않는다. 단일 파일(`_review_block_{block_id}.md`)에 순차 Write한다.

#### 통합 검토 모드

블록별 검토 완료 후, 전체 문서의 교차 일관성을 검증한다.

**절차**:
1. Step 0: 입력 로드 + `_review_block_*.md` 전부 Read + Phase 8에서 병합된 `lecture_script.md` Read
2. Step 1: 구조 완전성 검증 (S-1~S-7) — 병합된 `lecture_script.md` 대상
3. 블록 간 전환 일관성 검증: AM→PM, Day간 전환 문구 자연스러움
4. SLO 커버리지 전체 확인: 모든 SLO가 §4에서 다뤄지는지
5. 집계 정합 검증: §5 형성평가 집계 = §4 인라인 합계, §6 발문 모음 = §4 인라인 발문
6. 용어/표기 통일 검증
7. 블록별 검토 결과 통합 + 최종 판정 → `quality_review.md` Write

### 산출물 목록

```
{output_dir}/
├── _review_step1.md              # 전체 검토 시: Step 1 결과 (중간)
├── _review_step2.md              # 전체 검토 시: Step 2 결과 (중간)
├── _review_step3.md              # 전체 검토 시: Step 3 결과 (중간)
├── _review_step4.md              # 전체 검토 시: Step 4 결과 (중간)
├── _review_step5.md              # 전체 검토 시: Step 5 결과 (중간)
├── _review_step6.md              # 전체 검토 시: Step 6 결과 (중간)
├── _review_block_{block_id}.md   # 블록별 검토 시: 블록 검증 결과 (블록 수만큼)
└── quality_review.md             # 최종 품질 검토 결과 ★
```

### 위반 분류 (교안 기준)

| 유형 | 기준 | 예시 |
|------|------|------|
| **Major** | 교수 설계의 핵심 무결성을 손상하거나, 강사가 교안만으로 수업 진행 불가능 | Gagne 커버리지 <7/9, GRR 순서 위반(I Do→You Do 점프), CLO/SLO 변경, 차시 교안 누락, Exit 형성평가 누락, 근거 없는 팩트 창작, 표기법 체계적 혼용 |
| **Minor** | 품질에 영향을 주나 핵심 설계와 수업 진행은 가능 | 시간큐 역행, 발화문 문어체, Think-Aloud 라벨 누락, 메타포 출처 미명시, 발문 예상반응 누락, 활동 성공기준 미명시 |

### 인용 규칙

`shared/judgment-criteria.md`의 인용 규칙을 따른다.

**예시**:

```
| G-1 | Gagne 9사태 커버리지 | D2-3에서 Gagne 체크 6/9 — 사태5(학습 안내), 사태7(피드백), 사태9(파지·전이) 누락 | architecture §3 D2-3: 9/9 | §4 D2-3: 6/9 | We Do에 "학습 안내" 발화문 추가, You Do에 피드백 절차 추가, 정리에 전이 발문 추가 |
```

---

### Step 0: 입력 로드

| 항목 | 내용 |
|------|------|
| 입력 | 7개 파일 (아래 목록) |
| 도구 | Read |
| 산출물 | (내부 컨텍스트 — Step 1~6에서 점진적 Write) |

**동작**:

0. `.claude/templates/input-schema-script.json` 읽기 — script_config 각 필드의 enum 값, 유효 범위를 사전 이해 (검증 기준 해석에 필요)
1. 검증 대상 로드 — 블록별 검토: 해당 블록의 `session_D{day}-{num}.md` 파일들을 Read / 통합 검토: Phase 8 병합 후 `lecture_script.md` Read
2. 교안 검증 기준 4개 파일 Read:
   - `{output_dir}/architecture.md`: 차시 내부 구조(Gagne/GRR/시간 블록), 형성평가 배치, 발문 수준 배정, 전환 설계
   - `{output_dir}/brainstorm_result.md`: 발문 텍스트, 활동 아이디어, 사례/훅, Gagne 구현 방안, 오개념
   - `{output_dir}/research_deep.md`: 확정된 전제, 확보된 소재, 미해결 항목
   - `{output_dir}/input_data.json`: teaching_model, time_ratio, bloom_question_map, formative_assessment
4. 구성안 검증 기준 2개 파일 Read:
   - `{outline_dir}/lecture_outline.md`: CLO/SLO 원본, 차시 배치 원본
   - `{outline_dir}/architecture.md`: 정렬 맵 원본, 평가 체계 원본, 시간 예산 원본

**파일별 역할**:

| # | 파일 | 역할 | 검증 단계 |
|---|------|------|----------|
| 1 | `session_D{day}-{num}.md` (블록별 묶음) | **검증 대상** — 해당 블록의 차시 파일들을 Read | Step 2~6 (블록별 검토) |
| 2 | `02_script/architecture.md` | Gagne/GRR/발문/전환 기준 | Step 2, 3, 4, 5 |
| 3 | `02_script/brainstorm_result.md` | 발문/활동/사례/오개념 원본 | Step 5, 6 |
| 4 | `02_script/research_deep.md` | 소재/미해결 항목 기준 | Step 5, 6 |
| 5 | `02_script/input_data.json` | 설정값/교수 모델 기준 | Step 1, 2, 3, 4 |
| 6 | `01_outline/lecture_outline.md` | CLO/SLO 원본 기준 | Step 5 |
| 7 | `01_outline/architecture.md` | 정렬 맵/평가/시간 원본 기준 | Step 4, 5 |

---

### Step 1: 구조 완전성 검증

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step1.md` |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | S-1 | 8개 섹션 존재 | §1~§8 헤딩 모두 존재 (강의 개요, 학습 목표 요약, 공통 교안 구조, 차시별 교안, 형성평가 집계, 발문 모음, 교재/참고자료, 강사 가이드) | Major (누락 섹션당) |
| 2 | S-2 | 메타데이터 완전성 | 작성일자, 입력소스, 교수 모델, 적용 프레임워크 모두 기재 | Minor |
| 3 | S-3 | 필수 테이블 존재 | §1-1 기본정보, §2-1 CLO-SLO매핑, §2-2 차시-SLO매트릭스, §5-1 형성평가일람, §6-1~6-3 발문모음, §8-1 오개념카드 | Major (누락 테이블당) |
| 4 | S-4 | 빈 셀/플레이스홀더 | `{중괄호}` 플레이스홀더 잔존 검출. 학습자 실습용 양식 내부의 `[직접 입력]`은 제외 | Major (5개+), Minor (1~4개) |
| 5 | S-5 | 표기법 안내 존재 | §1-3에 7개 표기법(발화문 `> "..."`, 행동지시 `[...]`, 발문 `❓ [Ln]`, 활동 `📋`, 시간큐 `⏱️`, 전환 `🔄`, 예상반응 `💬`) 정의 존재 | Major (§1-3 누락), Minor (일부 표기 정의 누락) |
| 6 | S-6 | 서브섹션 완전성 | §1(1-1~1-3), §2(2-1~2-2), §3(3-1~3-3), §5(5-1~5-3), §6(6-1~6-3), §7(7-1~7-3), §8(8-1~8-5) 총 22개 서브섹션 모두 존재 | Major (누락 서브섹션당) |
| 7 | S-7 | 차시 교안 커버리지 | §4에서 input_data.json schedule 기반 전체 Day/교시가 빠짐없이 존재. 검증 공식: `total_sessions = Σ(sessions_per_day[])` → §4에 D1-1 ~ D{N}-{M} 모두 존재 | Major (누락 차시당) |

**동작**: S-1~S-7 검증 결과를 `_review_step1.md`에 Write한다.

---

### Step 2: 교수설계 프레임워크 검증 (Gagne/GRR/2-레이어/Think-Aloud)

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, 02_script/architecture.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step2.md` |

이 Step은 **교안 고유**의 교수법 프레임워크 준수 여부를 검증한다. 구성안 Phase 7에는 없던 영역이다.

**체크리스트**:

#### 2-1. Gagne 9사태 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | G-1 | Gagne 9사태 커버리지 | 모든 차시에서 Gagne 체크 ≥ 7/9. §4의 각 교시 하단 "Gagne 체크: N/9" 값을 architecture.md §3과 대조 | Major (차시당 <7/9), Minor (사태9만 누락) |
| 2 | G-2 | Gagne 도입부 사태 매핑 | 각 교시 도입부에 [Gagne 1] 주의획득, [Gagne 2] 목표 고지, [Gagne 3] 선수학습 회상이 순서대로 존재 | Major (사태1~3 중 하나 누락), Minor (순서 역전) |

#### 2-2. GRR 4단계 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 3 | G-3 | GRR 4단계 순차성 | 전개부에서 I Do → We Do → You Do Together → You Do Alone 순서 준수. "I Do → You Do 점프" (We Do 생략) 검출 | Major (We Do 생략 = I Do→You Do 점프), Minor (You Do Together/Alone 구분 미명시) |
| 4 | G-4 | GRR 시간 배분 일치 | 각 교시의 I Do/We Do/You Do 시간이 architecture.md §2-3 GRR 배분표와 ±3분 이내 일치 | Major (5분+ 차이), Minor (3~5분 차이) |

#### 2-3. 2-레이어 표기법 및 Think-Aloud 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 5 | G-5 | 2-레이어 표기 일관성 | §4 전체에서 발화문(`> "..."`)과 행동지시(`[...]`)가 혼용 없이 구분. 발화문 내에 행동지시가 혼입되거나 그 반대 검출 | Major (체계적 혼용 — 50%+ 교시), Minor (산발적 혼용 — 1~3교시) |
| 6 | G-6 | Think-Aloud 4대 패턴 | I Do 단계에서 4대 메타인지 발화(계획/모니터링/평가/자기교정) 중 최소 3가지 포함. architecture.md §3에서 I Do로 배정된 모든 차시 대상 | Major (2가지 이하 포함 차시 존재), Minor (3가지 포함이나 패턴 라벨 `[Think-Aloud — ...]` 누락) |

#### 2-4. 분절 규칙 및 Gagne 정합

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 7 | G-7 | 15분 분절 규칙 | I Do 세그먼트가 15분 초과 시 Bridging Activity(Think-Pair-Share, 확인 발문, 마이크로 실습) 삽입 여부 | Major (15분 초과 + Bridging 미삽입), Minor (14~15분 경계 — Bridging 권장) |
| 8 | G-8 | Gagne 사태-수업단계 정합 | 사태1~3이 도입에, 사태4~7이 전개에, 사태8~9가 정리에 배치. 단계 역전 검출 (예: 사태8이 전개에 배치) | Major (사태8이 정리 외 배치), Minor (사태9가 전개에 중복 배치) |

**동작**: G-1~G-8 검증 결과를 `_review_step2.md`에 Write한다.

---

### Step 3: 발문·평가·흐름 검증 (Bloom's / CMU 3점 / 차시 간 전환)

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, 02_script/architecture.md, input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step3.md` |

**체크리스트**:

#### 3-1. Bloom's 발문 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | P-1 | Bloom's 발문 수준 점진 상승 | 각 교시 내에서 도입(L1~L2) → 전개(L2~L4) → 정리(L4~L6) 점진 상승. `❓ [LN]` 태그 값으로 검증 | Major (전반적 역행 — 정리에서 L1~L2만 사용), Minor (1~2회 미세 역행) |
| 2 | P-2 | 발문 수준-SLO 정합 | 해당 교시 SLO의 Bloom's 수준 ≥ 교시 내 최고 발문 수준. SLO가 "적용(L3)"인데 정리 발문이 L5(평가)이면 위반 | Major (SLO보다 2단계+ 높은 발문), Minor (1단계 초과) |

#### 3-2. CMU 3점 형성평가 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 3 | P-3 | CMU 3점 형성평가 배치 | 각 교시에 Entry(도입 Gagne 사태3 후) / During(전개 We Do 후) / Exit(정리 Gagne 사태8) 3시점 중 Exit 필수, Entry+During 권장. architecture.md §4-1 배치표와 대조 | Major (Exit 누락 차시 존재), Minor (Entry 또는 During 누락) |
| 4 | P-4 | Exit 평가-SLO Bloom's 일치 | Exit 형성평가의 Bloom's 수준이 해당 차시 SLO의 Bloom's 수준과 동일 | Major (2단계+ 차이), Minor (1단계 차이) |

#### 3-3. 흐름 및 전환 검증

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 5 | P-5 | 예상 반응 포함 | 모든 발문(`❓`)에 예상 학습자 반응(`💬`) 1개 이상 포함. 오답 시 교정 발화 존재 | Minor (예상 반응 누락 발문당) |
| 6 | P-6 | 차시 간 전환 존재 | 인접 차시 사이에 `🔄` Preview/Bridge/Review 전환 문구 존재. architecture.md §6-1 전환 매핑과 대조 | Major (Day 간 전환 누락), Minor (같은 Day 내 전환 누락) |
| 7 | P-7 | Day별 Bloom's 점진 상승 | Day 1 → Day N으로 갈수록 교시 평균 Bloom's 수준 상승 추세 유지. §6 발문 모음 집계 데이터로 검증 | Minor (1~2회 역행), Major (전반적 역행) |

**동작**: P-1~P-7 검증 결과를 `_review_step3.md`에 Write한다.

---

### Step 4: 시간 배분 현실성 검증

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, 02_script/architecture.md, input_data.json, 01_outline/architecture.md |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step4.md` |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | T-1 | 교시 시간 합산 | 각 교시의 도입+전개+정리 시간 합 = session_minutes. 각 단계 헤딩의 `({분}분)` 값 합산으로 검증 | Major (5분+ 차이), Minor (1~4분 차이) |
| 2 | T-2 | 도입:전개:정리 비율 준수 | input_data.json의 time_ratio (예: 16:70:14) 대비 각 교시의 실제 비율이 ±5% 이내 | Major (10%+ 차이), Minor (5~10% 차이) |
| 3 | T-3 | GRR 시간 비율 현실성 | 직접교수법 기준: I Do ≤22%, We Do 22~28%, You Do ≥28%. 교수 모델별 기준 적용 (PBL: We Do 중심, 플립: You Do 중심) | Minor (기준 범위 소폭 이탈) |
| 4 | T-4 | 일일 교시 수 | 각 Day의 교시 수 × session_minutes ≤ hours_per_day × 60. 검증 공식: `일일 최대 교시 = (hours_per_day × 60) ÷ (session_minutes + break_minutes)` | Major (초과 10%+), Minor (초과 5% 미만) |
| 5 | T-5 | 15분 분절 준수 | I Do 세그먼트에서 15분 초과 연속 설명 없이 Bridging Activity 삽입 여부 확인 | Minor (15분 초과 연속 설명) |
| 6 | T-6 | 활동 시간 명시 | 모든 활동 지시(`📋`)에 소요 시간 명시 (`(N분)` 형태) | Minor (시간 미명시 활동) |
| 7 | T-7 | 시간 예산 일치 | §1-2 교수 모델 및 시간 구조의 값이 input_data.json의 teaching_model, time_ratio와 일치 | Major (불일치) |
| 8 | T-8 | 시간큐 연속성 | `⏱️` 경과/잔여 시간큐가 교시 내에서 시간 순서대로 증가하며, 마지막 시간큐의 경과 시간이 session_minutes와 ±2분 이내 | Minor (시간큐 역행 또는 누락) |

**동작**: T-1~T-8 검증 결과를 `_review_step4.md`에 Write한다.

---

### Step 5: 콘텐츠 정확성 검증 — Anti-Hallucination

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, 02_script/architecture.md, 02_script/brainstorm_result.md, 02_script/research_deep.md, 02_script/input_data.json, 01_outline/lecture_outline.md, 01_outline/architecture.md, context7_verify_{block_id}.md (존재 시 — 코드 API 검증 기준) |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step5.md` |

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | C-1 | CLO/SLO 원본 일치 | §2-1의 CLO-SLO 매핑 텍스트가 구성안 `01_outline/architecture.md` §2-1, §2-2와 동일 | Major (변경됨) |
| 2 | C-2 | 차시 배치 원본 일치 | §4의 교시 순서, 하위 주제 배정이 교안 `02_script/architecture.md` §3 차시별 내부 구조의 교시 순서와 동일 | Major (변경됨) |
| 3 | C-3 | Gagne/GRR 배정 원본 일치 | §4의 각 교시 GRR 단계(I Do/We Do/You Do)와 Gagne 사태 배정이 교안 architecture.md §3의 설계와 일치 | Major (변경됨) |
| 4 | C-4 | 발문 텍스트 근거 존재 | §4/§6의 발문이 brainstorm_result.md §1(발문)에 근거하거나, architecture.md §5(발문 수준)의 Bloom's-Socratic 패턴에 따라 생성됨 | Major (근거 없는 발문 — brainstorm에도 architecture 패턴에도 해당 없음) |
| 5 | C-5 | 활동 소재 근거 존재 | §4의 학습활동 내 구체적 사례/수치/코드가 brainstorm §2(활동), research_deep §3-2(확보된 소재), 또는 input_data.json에 근거 | Major (근거 없는 팩트 창작) |
| 6 | C-6 | 오개념 대응 일치 | §8-1 오개념 대응 카드가 brainstorm §6(오개념) 목록을 빠짐없이 반영 | Major (brainstorm §6 오개념 누락), Minor (추가 오개념 신규 생성) |
| 7 | C-7 | 미해결 항목 반영 | research_deep §3-3의 미해결 항목이 §8-5 사전 확인 필요 항목에 반영 | Minor (누락) |
| 8 | C-8 | 참고자료 출처 일치 | §7-2 필수 참고자료의 출처가 research_deep 또는 brainstorm_result의 출처 목록에 존재 | Minor (새로 추가된 출처) |
| 9 | C-9 | 실습 환경 반영 | input_data.json lab_environment가 non-null일 때: §4 실습 교시의 필요 자료에 해당 도구/환경 명시, §8-5 사전 확인 필요 항목에 환경 설정 절차 포함 | Major (lab_environment 존재 시 실습 교시에 도구 미명시), Minor (§8-5 환경 설정 누락) |
| 10 | C-10 | 코드 예제 API 정확성 | `context7_verify_{block_id}.md` 존재 시만 적용. §4 코드 블록의 함수명·파라미터·반환 타입이 공식 문서와 일치. 비기술 교육(`context7_verify` 미존재): 자동 Pass | Major (존재하지 않는 API 호출 — 함수명 자체가 공식 문서에 없음), Minor (파라미터 순서/타입 차이, deprecated API 사용) |
| 11 | C-11 | 코드 콘텐츠 밀도 (기술 교육 시 필수) | 각 차시의 I Do 세그먼트에 최소 1개 이상의 fenced code block(``` ```) 존재. 각 session_*.md에서 ``` 패턴 카운트. 비기술 교육(input_data.json의 keywords에 기술 라이브러리 없으면): 자동 Pass | Major (I Do에 코드 블록 0개 — 기술 교육 차시), Minor (코드 블록에 언어 미지정, 파일명 주석 누락) |
| 12 | C-12 | 플레이스홀더 잔존 검출 | `[코드 시연: ...]`, `[코드 예시]`, `[데모: ...]` 같은 코드 대체 플레이스홀더 존재 여부. 각 session_*.md에서 `\[코드 시연` `\[코드 예시` `\[데모` 패턴 검색 | Major (코드 블록 없이 플레이스홀더만 있는 경우), Minor (플레이스홀더 + 코드 블록 병존 — 플레이스홀더는 삭제해야 함) |

**동작**: C-1~C-12 검증 결과를 `_review_step5.md`에 Write한다.

---

### Step 6: 교안 실행 품질 검증 (발화문/활동지시/강사 가이드)

| 항목 | 내용 |
|------|------|
| 입력 | lecture_script.md, 02_script/brainstorm_result.md, 02_script/input_data.json |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/_review_step6.md` |

이 Step은 교안의 **실행 가능성** — 즉, 강사가 교안만 보고 실제 수업을 진행할 수 있는지를 검증한다. 구성안에는 없던 교안 고유 검증이다.

**체크리스트**:

| # | 검증 ID | 검증 항목 | 기준 | 위반 유형 |
|---|---------|----------|------|----------|
| 1 | N-1 | 발화문 자연성 + 내용 충실도 | 발화문(`> "..."`)이 친절한 구어체(~해요, ~입니다)로 작성되고, 해당 구간의 개념 설명·비유·예시가 충분히 포함되었는지. 딱딱한 문어체(~한다) 또는 1줄 문장만으로 구성된 I Do/We Do 발화 블록 검출. **[추가] 기술 교육 시: 코드 블록 앞뒤에 강사 발화가 코드를 줄 단위로 설명하는지 확인. 코드 실행 예상 결과가 명시되어 있는지 확인** | Major (I Do/We Do에서 개념 설명 없이 1줄 발화만 존재 — 교시당, 기술 교육 I Do에서 코드 설명 발화 없이 코드만 단독 배치), Minor (발화문 문어체) |
| 2 | N-2 | 활동 지시 3요소 | 모든 활동(`📋`)에 시작 안내, 단계별 절차, 성공 기준 3요소 포함 | Minor (1~2요소 누락 활동당) |
| 3 | N-3 | §5-§6 집계 정합 | §5(형성평가 집계) 테이블의 내용이 §4 교시별 인라인 형성평가와 일치. §6(발문 모음) 테이블의 발문이 §4 인라인 발문과 일치 | Major (집계 누락 — 형성평가/발문 50%+ 불일치), Minor (일부 불일치) |
| 4 | N-4 | 강사 가이드 완전성 | §8-1(오개념 카드), §8-2(시간 초과 축소), §8-3(메타포), §8-5(사전 확인) 모두 존재하고 비어 있지 않음 | Major (섹션 존재하나 내용 없음), Minor (내용 미흡) |
| 5 | N-5 | 메타포 원본 존재 | §8-3 메타포 목록이 input_data.json tone_examples에 존재. 추가 메타포 있으면 출처 명시 여부 확인 | Minor (추가 메타포에 출처 미명시) |
| 6 | N-6 | 표기법 일관 사용 | §1-3에서 정의한 7가지 표기법이 §4 전체에서 일관되게 사용. 정의되지 않은 새 표기법 사용 검출, 같은 용도에 다른 표기 혼용 검출 | Major (체계적 혼용), Minor (산발적 1~3건) |
| 7 | N-7 | 차시별 필요 자료 존재 | §4의 각 교시에 "필요 자료" 항목 존재. §7-1 Day별 필요 자료와 정합 | Minor (누락) |
| 8 | N-8 | brainstorm 소재 활용도 | brainstorm_result.md §3(사례·훅), §4(설명전략·비유), §5(Gagne 구현 방안)의 핵심 소재가 교안 발화문에 반영되었는지. 레이블만 남고 내용이 없는 경우 검출 | Major (해당 차시 brainstorm 소재 50%+ 미활용), Minor (일부 소재 미활용) |
| 9 | N-9 | 산출물 범위 준수 | input_data.json output_scope에 명시된 산출물 범위가 §1-1 기본정보의 산출 범위와 일치하고, 교안 전체 구성이 output_scope를 벗어나지 않음 | Minor (§1-1 산출 범위 미기재 또는 불일치) |

**동작**: N-1~N-9 검증 결과를 `_review_step6.md`에 Write한다.

---

### Step 7: 판정 + 산출물 작성

| 항목 | 내용 |
|------|------|
| 입력 | `{output_dir}/_review_step1.md` ~ `_review_step6.md` |
| 도구 | Read, Write |
| 산출물 | `{output_dir}/quality_review.md` ★ 최종 산출물 |

**동작**:

1. `_review_step1~6.md` 6개 파일을 Read하여 모든 검증 결과를 로드한다
2. **위반 집계**: Major/Minor 위반 수 카운트
3. **판정 결정**: `shared/judgment-criteria.md`의 판정 기준에 따라 판정
4. **quality_review.md 작성**: 아래 구조에 따라 작성

---

## 교안 quality_review.md 산출물 구조

```markdown
# 교안 품질 검토 결과

## 메타데이터

| 항목 | 값 |
|------|-----|
| 검토 일자 | {date} |
| 검토 대상 | 블록별: session_D*.md (Phase 6 산출물) / 통합: lecture_script.md (Phase 8 병합 산출물) |
| 검토 기준 | Gagne 9사태 + GRR + Bloom's 발문 + CMU 3점 형성평가 + 시간 배분 + Anti-Hallucination + 교안 실행 품질 |
| 검증 항목 수 | 51개 (S:7 + G:8 + P:7 + T:8 + C:12 + N:9) |
| 판정 | {PASS / CONDITIONAL PASS / REVISION REQUIRED} |

---

## 1. 검토 요약

| 영역 | 검증 항목 수 | Pass | Fail (Major) | Fail (Minor) |
|------|------------|------|-------------|-------------|
| 구조 완전성 (S) | 7 | {N} | {N} | {N} |
| 교수설계 프레임워크 (G) | 8 | {N} | {N} | {N} |
| 발문·평가·흐름 (P) | 7 | {N} | {N} | {N} |
| 시간 배분 현실성 (T) | 8 | {N} | {N} | {N} |
| 콘텐츠 정확성 (C) | 12 | {N} | {N} | {N} |
| 교안 실행 품질 (N) | 9 | {N} | {N} | {N} |
| **합계** | **51** | {N} | {N} | {N} |

---

## 2. 검증 상세

51개 검증 항목 전체의 Pass/Fail 결과를 기록한다.

| # | 검증 ID | 영역 | 결과 | 상세 |
|---|---------|------|------|------|
| 1 | S-1 | 구조 완전성 | {Pass/Major/Minor} | {검증 결과 요약} |
| 2 | S-2 | 구조 완전성 | {Pass/Major/Minor} | {검증 결과 요약} |
| ... | ... | ... | ... | ... |
| 51 | N-9 | 교안 실행 품질 | {Pass/Major/Minor} | {검증 결과 요약} |

---

## 3. Major 위반 사항

{Major 위반이 없으면: "Major 위반 없음"}

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (script) | 해당 교시/섹션 | 수정 가이드 |
|---|---------|------|----------|-------------|----------------|-------------|-----------|
| 1 | {G-1 등} | {영역} | {구체적 위반 내용} | {원본 파일명 §섹션의 값} | {lecture_script §섹션/교시의 값} | {D{N}-{M} 또는 §{N}} | {수정 방법} |

---

## 4. Minor 위반 사항

{Minor 위반이 없으면: "Minor 위반 없음"}

| # | 검증 ID | 영역 | 위반 내용 | 기대값 (원본) | 실제값 (script) | 해당 교시/섹션 | 수정 권고 |
|---|---------|------|----------|-------------|----------------|-------------|----------|
| 1 | {T-2 등} | {영역} | {구체적 위반 내용} | {원본 파일명 §섹션의 값} | {lecture_script §섹션/교시의 값} | {D{N}-{M} 또는 §{N}} | {권고 사항} |

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
| 1 | {C-1 등} | {Major/Minor} | {이 항목을 먼저 수정해야 하는 이유} | {영향받는 교시/§섹션 목록} |
| 2 | {G-3 등} | {Major/Minor} | {이유} | {교시/§섹션 목록} |

---

## 7. 최종 판정

**판정**: {PASS / CONDITIONAL PASS / REVISION REQUIRED}

**판정 근거**:
- Major 위반: {N}개
- Minor 위반: {N}개
- 총 검증 항목: 51개 중 Pass {N}개

{CONDITIONAL PASS인 경우}:
**권고 수정 사항**: §6 수정 우선순위 순서대로 Minor 위반을 수정한 뒤 재검토 권장.

{REVISION REQUIRED인 경우}:
**필수 수정 사항**: §6 수정 우선순위 순서대로 Major 위반의 수정 가이드를 따라 해당 교시/섹션을 재작성해야 합니다.
```
