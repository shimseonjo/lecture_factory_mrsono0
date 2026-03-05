# Lecture Factory - 워크플로우 시스템 규칙

## Output Convention (산출물 저장 규칙)

### 폴더 구조

```
lectures/
└── YYYY-MM-DD_{강의명}/              # 날짜 + 강의명 (Phase 1에서 자동 생성)
    ├── 01_outline/                   # /lecture-outline 산출물
    ├── 02_script/                    # /lecture-script 산출물
    ├── 03_slide_plan/                # /slide-planning 산출물
    └── 04_slides/                    # /slide-generation 산출물
```

### 폴더 명명 규칙

- **날짜 형식**: `YYYY-MM-DD` (예: `2026-03-05`)
- **강의명**: 사용자 입력 Q1(핵심 주제)에서 추출, 공백은 하이픈(`-`)으로 대체
- **예시**: `lectures/2026-03-05_claude-code-활용/`

### 워크플로우별 산출물 위치

각 워크플로우는 자신의 폴더에만 파일을 생성한다. 상세 파일 목록은 각 SKILL.md 참조.

| 워크플로우 | 폴더 | 최종 산출물 |
|-----------|------|-----------|
| `/lecture-outline` | `01_outline/` | `lecture_outline.md` |
| `/lecture-script` | `02_script/` | `lecture_script.md` |
| `/slide-planning` | `03_slide_plan/` | `slide_plan.md` |
| `/slide-generation` | `04_slides/` | `slides.md` |

### 공통 규칙

1. **폴더 자동 생성**: Phase 1(input-agent)에서 강의 루트 폴더 + 해당 워크플로우 폴더를 생성
2. **이전 단계 참조**: 각 워크플로우는 이전 단계 폴더의 최종 산출물을 입력으로 로드
   - `/lecture-script` → `01_outline/lecture_outline.md` 참조
   - `/slide-planning` → `02_script/lecture_script.md` 참조
   - `/slide-generation` → `03_slide_plan/slide_plan.md` 참조
3. **중간 산출물 보존**: 각 Phase의 중간 산출물도 해당 폴더에 저장 (디버깅·재실행 용도)
4. **input_data.json**: 각 워크플로우 폴더에 독립적으로 생성 (워크플로우별 입력이 다름)
