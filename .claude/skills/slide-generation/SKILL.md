---
name: slide-generation
description: 슬라이드 생성 프롬프트 - 3단계 파이프라인 (입력수집 → 프롬프트생성 → 검토)
context: fork
allowed-tools: Agent, Read, Write, Glob, Grep, AskUserQuestion
---

# 슬라이드 생성 프롬프트 워크플로우

<!-- TODO: 오케스트레이터 로직 구현 예정 -->

## 작업 지시

$ARGUMENTS

## 파이프라인 (3단계)

### Phase 1: 입력 수집 → input-agent (기획안 로드 + 출력 형식 선택)
### Phase 2: 프롬프트 생성 → writer-agent (슬라이드별 마크다운/프롬프트 작성)
### Phase 3: 품질 검토 → review-agent (형식 검증, 콘텐츠 정확성, 일관성)

## 산출물 (04_slides/)

```
lectures/YYYY-MM-DD_{강의명}/04_slides/
├── input_data.json              # Phase 1: 기획안 로드 + 출력 형식 선택
├── slides.md                    # Phase 2: 최종 슬라이드/프롬프트 ★
└── quality_review.md            # Phase 3: 품질 검토
```
