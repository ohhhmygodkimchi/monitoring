# 단위 테스트 보고서: Jaeger

## 모듈 정보
- **모듈:** jaeger
- **파일:** `src/jaeger/custom-values.yaml`
- **작성일:** 2026-03-17

## 테스트 결과

| ID        | 시나리오                    | 상태  | 비고                                         |
|-----------|---------------------------|-------|---------------------------------------------|
| UT-JAE-01 | Helm 템플릿 렌더링 정상 여부 | ⏳ 대기 | `helm template` 실행 필요                     |
| UT-JAE-02 | 전체 Pod 기동 확인           | ⏳ 대기 | Collector, Query, ES 모두 Running 확인        |
| UT-JAE-03 | Jaeger UI 접근 확인          | ⏳ 대기 | NodePort:30086 접근 확인                      |
| UT-JAE-04 | 테스트 트레이스 조회          | ⏳ 대기 | Otel SDK 트레이스 전송 후 UI 확인              |
| UT-JAE-05 | ES 스토리지 PVC 바인딩 확인   | ⏳ 대기 | `kubectl get pvc -n tracing`                 |

## 코드 리뷰 체크리스트

- [x] Elasticsearch 백엔드 활성화 (Cassandra 비활성화)
- [x] ES replica 1, minimumMasterNodes 1 (온프레미스 최소 구성)
- [x] Collector 2 replica 구성
- [x] Query NodePort:30086 설정
- [x] Agent 비활성화 (Otel Collector가 대체)
- [x] ES Index Cleaner 7일 보존 (REQ-N-02)
- [x] PVC 30Gi 설정
- [x] 모든 컴포넌트에 `resources.limits` 설정 (REQ-N-01)
