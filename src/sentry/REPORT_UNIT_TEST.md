# 단위 테스트 보고서: Sentry

## 모듈 정보
- **모듈:** sentry (self-hosted)
- **파일:** `src/sentry/custom-values.yaml`
- **작성일:** 2026-03-17

## 테스트 결과

| ID        | 시나리오                    | 상태  | 비고                                         |
|-----------|---------------------------|-------|---------------------------------------------|
| UT-SEN-01 | Helm 템플릿 렌더링 정상 여부 | ⏳ 대기 | `helm template` 실행 필요                     |
| UT-SEN-02 | 전체 Pod 기동 확인           | ⏳ 대기 | Web, Worker, Relay, DB 등 Running 확인        |
| UT-SEN-03 | Web UI 접근 확인             | ⏳ 대기 | NodePort:30090 접근 확인                      |
| UT-SEN-04 | 프로젝트 생성 및 DSN 발급     | ⏳ 대기 | Sentry UI에서 프로젝트 생성                    |
| UT-SEN-05 | 테스트 에러 이벤트 수신        | ⏳ 대기 | SDK 테스트 에러 전송 후 이슈 확인              |
| UT-SEN-06 | Secret 참조 확인              | ⏳ 대기 | Secret 존재 및 Pod 마운트 확인                 |

## 코드 리뷰 체크리스트

- [x] 관리자 비밀번호 `existingSecret` 사용 (REQ-N-06)
- [x] PostgreSQL `existingSecret` 참조 (REQ-N-06)
- [x] Sentry Secret Key 외부 주입
- [x] Web 1 replica, Worker 2 replica 구성
- [x] PostgreSQL 20Gi, ClickHouse 30Gi PVC 설정
- [x] Redis standalone 모드
- [x] Kafka 비활성화 (소규모 환경)
- [x] 90일 보존 정책 (REQ-N-02)
- [x] NodePort:30090 설정
- [x] `create-secrets.sh`에 사전 Secret 생성 포함
