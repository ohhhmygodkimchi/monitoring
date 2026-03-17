# 단위 테스트 보고서: Loki Stack

## 모듈 정보
- **모듈:** loki-stack (Loki + Promtail)
- **파일:** `src/loki-stack/custom-values.yaml`
- **작성일:** 2026-03-17

## 테스트 결과

| ID        | 시나리오                    | 상태  | 비고                                         |
|-----------|---------------------------|-------|---------------------------------------------|
| UT-LOK-01 | Helm 템플릿 렌더링 정상 여부 | ⏳ 대기 | `helm template` 실행 필요                     |
| UT-LOK-02 | Loki + Promtail Pod 기동    | ⏳ 대기 | Loki StatefulSet + Promtail DaemonSet 확인    |
| UT-LOK-03 | Loki 헬스체크                | ⏳ 대기 | `/ready` 엔드포인트 확인                       |
| UT-LOK-04 | Grafana LogQL 쿼리 테스트    | ⏳ 대기 | Grafana Explore에서 확인                      |
| UT-LOK-05 | 로그 보존 기간 설정 확인      | ⏳ 대기 | `retention_period: 720h` 확인                 |
| UT-LOK-06 | PVC 바인딩 확인              | ⏳ 대기 | `kubectl get pvc -n logging`                 |

## 코드 리뷰 체크리스트

- [x] Loki PVC 100Gi 설정
- [x] BoltDB Shipper + Filesystem 스토리지 구성
- [x] `retention_period: 720h` (30일, REQ-N-02)
- [x] `reject_old_samples_max_age: 168h` (7일 이상 지난 로그 거부)
- [x] Promtail clients URL - 올바른 Loki 서비스 주소
- [x] Promtail `labeldrop` 으로 카디널리티 관리
- [x] 내장 Grafana/Prometheus 비활성화 (kube-prometheus-stack 공유)
- [x] 모든 컴포넌트에 `resources.limits` 설정 (REQ-N-01)
- [x] `compactor.retention_enabled: true` 설정
