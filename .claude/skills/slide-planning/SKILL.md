---
name: slide-planning
description: 슬라이드 기획 - 5단계 파이프라인 (입력수집 → 브레인스토밍 → 구조설계 → 기획안작성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, AskUserQuestion
---

# 슬라이드 기획 워크플로우

<!-- TODO: 오케스트레이터 로직 구현 예정 -->

## 작업 지시

$ARGUMENTS

## 파이프라인 (5단계)

### Phase 1: 입력 수집 → input-agent (교안 로드 + 슬라이드 도구/형식 선택)
### Phase 2: 브레인스토밍 → brainstorm-agent (시각화 아이디어, 레이아웃 구상)
### Phase 3: 슬라이드 구조 설계 → architecture-agent (슬라이드 수, 유형, 순서, 시간 배분)
### Phase 4: 기획안 작성 → writer-agent (슬라이드별 목적, 레이아웃, 핵심 콘텐츠)
### Phase 5: 품질 검토 → review-agent (정보 밀도, 시각 계층, 학습목표 정렬)
