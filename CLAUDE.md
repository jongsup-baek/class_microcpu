# CLAUDE.md

> **반드시 따를 것**: `../clae/CLAUDE.md` 읽고 8단계 플로우 따라갈 것
>
> **clae 로컬 경로**: `../../clae/` (work 디렉토리 내 형제 폴더)
>
> **clae 경로 못 찾으면**: 사용자에게 경로 질문 (GitHub: https://github.com/jongsup-baek/clae)
>
> **이슈 등록**: 모든 이슈는 **clae 레포**에 등록하라. 라벨은 CLAE_LABELS.md 참조
>
> **원칙 변경 금지**: clae 공통 원칙(`principles/`)을 직접 수정하지 마라. clae 이슈로 요청하라

**관련 GitHub repo:**

- [jongsup-baek/clae](https://github.com/jongsup-baek/clae) — CLAE 협업 지식 베이스, 프로젝트 전체 이슈 관리
- [jongsup-baek/class_microcpu](https://github.com/jongsup-baek/class_microcpu) — 이 프로젝트 - MicroCPU 16비트 CPU 설계
- [jongsup-baek/course_sv](https://github.com/jongsup-baek/course_sv) — 교육 자료 소스 (상위 레포)
- [jongsup-baek/class_simplecpu](https://github.com/jongsup-baek/class_simplecpu) — SimpleCPU (원본 기반)
- [jongsup-baek/claeclassmaster](https://github.com/jongsup-baek/claeclassmaster) — 교재 개발 원칙 + 액티브 리뷰

> **내 역할**: 콘텐츠 생산 (lecture, slide). 동기화는 classmaster가, 퀴즈는 quizbank가 담당.
> **교재 개발 원칙**: `../../claeclassmaster/principles/` 참조
> **병렬 워크플로우**: `../../claeclassmaster/principles/workflow_roles.md` 참조

---

## 1. 프로젝트 개요

SimpleCPU(8비트 accumulator)를 확장한 16비트 명령어 + 레지스터 파일 기반 CPU.
class_simplecpu의 설계 패턴(8상태 FSM, 5-phase 클럭)을 유지하면서 데이터패스를 확장한다.
이 레포는 course_sv의 submodule로 포함된다.

- 과목: MicroCPU 설계 실무
- 범위: lab01-10 (설계 + 검증)
- 자료 위치: lab_microcpu/, instruction_microcpu/
- 원본: class_simplecpu에서 확장

## 2. 작업 원칙

- 실습 소스 수정: lab_microcpu/ 에서 직접 수행
- 지침서 수정: instruction_microcpu/ 에서 직접 수행

### 이 세션이 하지 않는 것

- clae 공통 원칙 직접 수정 → **clae 이슈로 요청**
- 다른 프로젝트 파일 수정 → **해당 세션에서 처리**

## 3. 작업 이력

> **Git Issue로 관리**: 세션 종료 전 `gh issue create --label history`로 작업 이력 발급

---

*Authored-By: Jongsup Baek <jongsup.baek@ksdcsemi.com>*
*Last updated: 2026-03-31*
