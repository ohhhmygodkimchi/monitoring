# PROJECT ACTION PLAN & STATUS

## 현재 단계 (Current Stage)
**[3. 구현 단계 (Developer)]**

## 다음 작업 (Next Action Hook)
> **[필독] 다음 에이전트를 위한 지침**:
> 기획(PM) 단계가 오나료되고 온프레미스 K8s 모니터링 시스템 구축을 위한 PRD 및 기술 스택 선정이 확정되었습니다.
> 1. 언제나 가장 먼저 `.agent/rules/00_CORE_STANCE.md`를 필독하여 에이전트의 기본 태도 및 운영 지침을 숙지하십시오.
> 2. 그 다음, `.agent/rules/02_PL_DESIGN.md`를 필독하여 **시니어 PL** 페르소나를 장착하십시오.
> 3. 참조 문서: `docs/planning/PRD.md`, `docs/planning/TECH_STACK.md`, `docs/planning/REQUIREMENTS.md`
> 4. 우선 수행할 작업: 승인된 스택(Kube-Prometheus, OpenTelemetry, Jaeger, Sentry, Loki 등)을 Helm 기반으로 배포하기 위한 프로젝트 폴더 구조를 생성하고, 시스템 아키텍처 설계도 작성을 시작하십시오.
> **[필독] 다음 에이전트를 위한 지침**:
> 프로젝트가 초기화되었습니다. 사용자와 첫 대화를 시작하여 기획 논의를 진행하세요.
> 1. 언제나 가장 먼저 `.agent/rules/00_CORE_STANCE.md`를 필독하여 에이전트의 기본 태도 및 운영 지침을 숙지하십시오.
> 2. 그 다음, `.agent/rules/01_PM_PLANNING.md`를 필독하여 **시니어 PM** 페르소나를 장착하십시오.
> 3. 사용자의 아이디어를 구체화하기 위한 적극적인 질문과 논의를 시작하십시오.
> 4. 실행 환경 및 기술적 요구사항을 파악한 뒤 PRD 작성을 준비하십시오.

---

## 단계별 체크리스트 (Stage Checklist)

### 1. 기획 (PM)
- [x] 사용자 요구사항 논의 및 이해
- [x] PRD (제품 요구사항 정의서) 작성 및 승인 → `docs/planning/PRD.md`
- [x] 상세 요구사항 명세서 작성 → `docs/planning/REQUIREMENTS.md`
- [x] 기술 스택 선정 (Context7 MCP 기반) 및 승인 → `docs/planning/TECH_STACK.md`

### 2. 설계 (PL)
- [x] 프로젝트 폴더 구조 생성 (`src/`, `docs/`, `tests/` 등)
- [x] 모듈별 설계서 작성 (각 모듈 폴더 내 `DESIGN.md`)
- [x] 단위 테스트 케이스 초안 작성 → `docs/tests/UNIT_TEST_CASES.md`
- [x] 시스템 아키텍처 설계 (선택) → `docs/design/ARCHITECTURE.md`
- [x] 설계 내용 검토 및 수정
- [x] 코딩 컨벤션 작성 → `docs/guidelines/CODE_CONVENTION.md`

### 3. 구현 (Developer)
- [x] 환경 설정 (가상환경 구축 및 의존성 설치)
- [x] 설계서(`DESIGN.md`) 및 테스트 케이스(`UNIT_TEST_CASES.md`) 숙지
- [x] 모듈별 소스 코드 구현 → `src/`
- [x] 단위 테스트 코드 작성 및 전체 통과 확인
- [x] 단위 테스트 보고서 작성 → 각 모듈 `REPORT_UNIT_TEST.md`
- [x] 단위 테스트 집계 보고서 작성 → `docs/reports/REPORT_UNIT_TEST_SUMMARY.md`

### 4. 테스트 (QA)
- [ ] 테스트 케이스 명세서 작성 → `docs/reports/TEST_CASES.md`
- [ ] 관통 테스트(E2E) / 통합 테스트 수행
- [ ] 버그 발생 시 즉시 수정(Developer 역할 전환) 및 재검증
- [ ] 최종 통합 테스트 리포트 작성 → `docs/reports/REPORT_INTEGRATION_TEST.md`

### 5. 문서화 (Technical Writer)
- [ ] 기획서(PRD), 설계서, 테스트 보고서 전체 검토 및 종합
- [ ] 프로젝트 `README.md` 작성/업데이트
- [ ] 사용자 매뉴얼 작성 → `docs/manual/USER_MANUAL.md`
- [ ] 개발자 가이드 작성 (선택) → `docs/manual/DEVELOPER_GUIDE.md`
- [ ] `PROJECT_STATUS.md` 최종 업데이트 및 프로젝트 종료 보고

---

## 변경 로그 (Change Log)
| 날짜 | 단계 | 내용 | 비고 |
|------|------|------|------|
| 2026-02-11 | 설정 | 프로젝트 초기화 및 가이드라인 재정립 | 새 프로젝트 시작 준비 완료 |
| 2026-03-17 | 기획(PM) → 설계(PL) | PRD, 기술 스택, 요구사항 명세 작성 완료 및 승인 | 온프레미스 K8s 모니터링 시스템 스택(Kube-Prometheus, Otel, Jaeger, Sentry, Loki) 확정 |
| 2026-03-17 | 설계(PL) → 구현(Dev) | 아키텍처, 모듈별 DESIGN.md, 테스트케이스, 코딩컨벤션 작성 완료 및 승인 | 설계 승인 후 구현 단계 진입 |
