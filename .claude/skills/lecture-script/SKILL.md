---
name: lecture-script
description: 강의교안 생성 - 7단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 구조설계 → 작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
---

# 강의교안 생성 워크플로우

<!-- TODO: 오케스트레이터 로직 구현 예정 -->

## 작업 지시

$ARGUMENTS

## 파이프라인 (7단계, 2-Pass Research)

### Phase 1: 입력 수집 → input-agent (구성안 로드 + 교수법 선택)
### Phase 2: 탐색적 리서치 → research-agent (교수법 사례, 유사 교안 벤치마킹)
### Phase 3: 브레인스토밍 → brainstorm-agent (발문, 활동, 사례 구상)
### Phase 4: 심화 리서치 → research-agent (브레인스토밍 기반 예시·보충 콘텐츠 수집)
### Phase 5: 교안 구조 설계 → architecture-agent (도입-전개-정리, Gagne 9사태)
### Phase 6: 교안 작성 → writer-agent (섹션별 스크립트, 발문, 활동, 평가문항)
### Phase 7: 품질 검토 → review-agent (목표-활동-평가 정렬, 시간 배분)

## 산출물 (02_script/)

```
lectures/YYYY-MM-DD_{강의명}/02_script/
├── input_data.json              # Phase 1: 구성안 로드 + 교수법 선택
├── research_exploration.md      # Phase 2: 탐색적 리서치
├── brainstorm_result.md         # Phase 3: 브레인스토밍
├── research_deep.md             # Phase 4: 심화 리서치
├── architecture.md              # Phase 5: 교안 구조 설계
├── lecture_script.md            # Phase 6: 최종 교안 ★
└── quality_review.md            # Phase 7: 품질 검토
```
