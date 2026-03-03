---
name: lecture-script
description: 강의교안 생성 - 6단계 파이프라인 (입력수집 → 브레인스토밍 → 리서치 → 구조설계 → 작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
---

# 강의교안 생성 워크플로우

<!-- TODO: 오케스트레이터 로직 구현 예정 -->

## 작업 지시

$ARGUMENTS

## 파이프라인 (6단계)

### Phase 1: 입력 수집 → input-agent (구성안 로드 + 교수법 선택)
### Phase 2: 브레인스토밍 → brainstorm-agent (발문, 활동, 사례 구상)
### Phase 3: 인터넷 리서치 → research-agent (예시 자료, 보충 콘텐츠)
### Phase 4: 교안 구조 설계 → architecture-agent (도입-전개-정리, Gagne 9사태)
### Phase 5: 교안 작성 → writer-agent (섹션별 스크립트, 발문, 활동, 평가문항)
### Phase 6: 품질 검토 → review-agent (목표-활동-평가 정렬, 시간 배분)
