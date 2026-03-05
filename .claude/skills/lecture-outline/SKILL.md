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
### Phase 2: 탐색적 리서치 → research-agent

**지시**: 강의구성안을 위한 탐색적 리서치를 수행하세요.
**입력 파일**: `{output_dir}/input_data.json`
**산출물 위치**: `{output_dir}/` (research_plan.md, local_findings.md, nblm_findings.md, web_findings.md, research_exploration.md)
**모드**: 탐색적 (orientation) — 구체적 강의 목차/구성 노출 금지 (고착 효과 방지)
**제약**: 총 웹 검색 15회 이내, NBLM 쿼리 노트북당 5회 이내
**워크플로우**: Step 0(계획) → Step 1(로컬) → Step 2(NBLM) → Step 3(웹) → Step 4(통합)
**상세**: `.claude/agents/research-agent/AGENT.md`의 "강의구성안 탐색적 리서치" 섹션 참조
### Phase 3: 브레인스토밍 → brainstorm-agent (리서치 기반 informed brainstorming)

**지시**: 탐색적 리서치 결과를 기반으로 강의 하위 주제를 발산적으로 도출하고, 다관점 검증을 거쳐 우선순위를 분류하세요.
**입력 파일**: `{output_dir}/input_data.json`, `{output_dir}/research_exploration.md`
**산출물 위치**: `{output_dir}/` (brainstorm_plan.md, divergent_ideas.md, idea_clusters.md, review_result.md, brainstorm_result.md)
**모드**: informed brainstorming — 리서치 인사이트를 시드로 활용하되, 특정 목차 구조에 얽매이지 않고 발산적 탐색
**제약**: 도구 Read, Write만 사용. 외부 검색 없음. Agent 중첩 금지.
**발산 기법**: 교차 도메인 비유, 전제 뒤집기, SCAMPER 교육 버전, 범위 전환 (scientific-brainstorming 참조)
**검증 관점**: 교수 설계자, 비판적 교육자, 시간/자원 관리자, 학습자 대변인, 통합 판단자 (multi-agent-brainstorming 참조)
**워크플로우**: Step 0(계획) → Step 1(발산) → Step 2(클러스터링) → Step 3(다관점 검증) → Step 4(우선순위+Bloom's) → Step 5(통합)
**상세**: `.claude/agents/brainstorm-agent/AGENT.md`의 "강의구성안 브레인스토밍" 섹션 참조
### Phase 4: 심화 리서치 → research-agent (브레인스토밍 결과 검증, 사례·참고문헌 수집)
### Phase 5: 아키텍처 설계 → architecture-agent
### Phase 6: 구성안 작성 → writer-agent
### Phase 7: 품질 검토 → review-agent

## 산출물 (01_outline/)

```
lectures/YYYY-MM-DD_{강의명}/01_outline/
├── input_data.json              # Phase 1: 사용자 입력 (Q1~Q12)
├── research_plan.md             # Phase 2: 리서치 계획
├── local_findings.md            # Phase 2: 로컬 참고자료 분석
├── nblm_findings.md             # Phase 2: NotebookLM 쿼리 결과
├── web_findings.md              # Phase 2: 인터넷 리서치 결과
├── research_exploration.md      # Phase 2: 4자료원 통합 최종 ★
├── brainstorm_plan.md           # Phase 3: 브레인스토밍 계획
├── divergent_ideas.md           # Phase 3: 발산 아이디어 원시 목록
├── idea_clusters.md             # Phase 3: 클러스터링 + 페르소나
├── review_result.md             # Phase 3: 다관점 검증 + Decision Log
├── brainstorm_result.md         # Phase 3: 브레인스토밍 최종 ★
├── research_deep.md             # Phase 4: 심화 리서치
├── architecture.md              # Phase 5: 아키텍처 설계
├── lecture_outline.md           # Phase 6: 최종 구성안 ★
└── quality_review.md            # Phase 7: 품질 검토
```
