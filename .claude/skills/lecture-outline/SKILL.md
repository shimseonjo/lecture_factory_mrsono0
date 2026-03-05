---
name: lecture-outline
description: 강의구성안 생성 - 7단계 파이프라인 (입력수집 → 탐색리서치 → 브레인스토밍 → 심화리서치 → 아키텍처 → 작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
---

# 강의구성안 생성 워크플로우

<!-- TODO: 오케스트레이터 로직 구현 예정 -->

## 작업 지시

$ARGUMENTS

## 파이프라인 (7단계, 2-Pass Research)

### Phase 1: 입력 수집 → input-agent
### Phase 2: 탐색적 리서치 → research-agent (문제 공간 이해, 트렌드, 유사 강의 현황)
### Phase 3: 브레인스토밍 → brainstorm-agent (리서치 기반 informed brainstorming)
### Phase 4: 심화 리서치 → research-agent (브레인스토밍 결과 검증, 사례·참고문헌 수집)
### Phase 5: 아키텍처 설계 → architecture-agent
### Phase 6: 구성안 작성 → writer-agent
### Phase 7: 품질 검토 → review-agent

## 산출물 (01_outline/)

```
lectures/YYYY-MM-DD_{강의명}/01_outline/
├── input_data.json              # Phase 1: 사용자 입력 (Q1~Q12)
├── research_exploration.md      # Phase 2: 탐색적 리서치
├── brainstorm_result.md         # Phase 3: 브레인스토밍
├── research_deep.md             # Phase 4: 심화 리서치
├── architecture.md              # Phase 5: 아키텍처 설계
├── lecture_outline.md           # Phase 6: 최종 구성안 ★
└── quality_review.md            # Phase 7: 품질 검토
```
