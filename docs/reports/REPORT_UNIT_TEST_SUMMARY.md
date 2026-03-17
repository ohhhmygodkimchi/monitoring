# 단위 테스트 집계 보고서 (REPORT_UNIT_TEST_SUMMARY)

## 개요
- **프로젝트:** 온프레미스 K8s 모니터링 파이프라인
- **작성일:** 2026-03-17
- **총 모듈 수:** 5
- **총 테스트 케이스:** 28

## 요구사항 충족 상태 (코드 리뷰)

| 요구사항 ID | 내용                       | 충족 모듈                                       | 상태 |
|------------|---------------------------|------------------------------------------------|------|
| REQ-F-01   | Node 메트릭 수집            | kube-prometheus-stack (Node Exporter)            | ✅   |
| REQ-F-02   | Pod 메트릭 수집             | kube-prometheus-stack (KSM)                      | ✅   |
| REQ-F-03   | Grafana 대시보드            | kube-prometheus-stack (Grafana)                   | ✅   |
| REQ-F-04   | Alert 규칙 + Slack 알림     | kube-prometheus-stack (Alertmanager + Custom Rules)| ✅   |
| REQ-F-05   | Otel SDK 트레이스 생성       | opentelemetry-collector                           | ✅   |
| REQ-F-06   | Otel Collector 전송         | opentelemetry-collector                           | ✅   |
| REQ-F-07   | Jaeger UI 트레이스 검색      | jaeger                                            | ✅   |
| REQ-F-08   | Sentry 에러 수집            | sentry                                            | ✅   |
| REQ-F-09   | Sentry Call Stack 시각화     | sentry                                            | ✅   |
| REQ-F-10   | 에러 그룹화                  | sentry                                            | ✅   |
| REQ-F-11   | Pod 로그 수집               | loki-stack (Promtail)                             | ✅   |
| REQ-F-12   | K8s 라벨 기반 인덱싱         | loki-stack (Loki)                                 | ✅   |
| REQ-F-13   | Grafana LogQL 검색          | loki-stack + kube-prometheus-stack (Grafana)       | ✅   |
| REQ-N-01   | 자원 제한 설정              | 전체 모듈                                          | ✅   |
| REQ-N-02   | 데이터 보존 기간             | 전체 모듈 (15d/30d/7d/90d)                         | ✅   |
| REQ-N-05   | 대시보드 인증               | kube-prometheus-stack (Grafana Secret)              | ✅   |
| REQ-N-06   | 민감 정보 Secret 주입        | kube-prometheus-stack + sentry                     | ✅   |
| CON-01     | Helm Chart 배포             | 전체 모듈                                          | ✅   |
| CON-02     | Namespace 분리              | monitoring/logging/tracing/sentry                   | ✅   |

## 모듈별 테스트 현황

| 모듈                      | 테스트 수 | 코드 리뷰 통과 | 배포 테스트 상태 |
|--------------------------|----------|--------------|----------------|
| kube-prometheus-stack     | 6        | ✅ 7/7 항목    | ⏳ 배포 후 실행  |
| opentelemetry-collector   | 5        | ✅ 7/7 항목    | ⏳ 배포 후 실행  |
| jaeger                   | 5        | ✅ 8/8 항목    | ⏳ 배포 후 실행  |
| sentry                   | 6        | ✅ 10/10 항목  | ⏳ 배포 후 실행  |
| loki-stack               | 6        | ✅ 9/9 항목    | ⏳ 배포 후 실행  |
| **합계**                  | **28**   | **✅ 41/41**   | ⏳              |

## 비고
- 모든 `custom-values.yaml`의 코드 리뷰(요구사항 대비 설정 점검)를 완료했습니다.
- 실제 Helm 배포 테스트(UT-xxx 시나리오)는 K8s 클러스터 환경에서 `scripts/deploy-all.sh` 실행 후 수행해야 합니다.
- 각 모듈의 상세 테스트 보고서는 `src/<module>/REPORT_UNIT_TEST.md`를 참조하세요.

## 배포 후 테스트 실행 순서
```bash
# 1. Secret 생성
bash scripts/create-secrets.sh

# 2. 전체 배포
bash scripts/deploy-all.sh

# 3. 상태 확인
bash scripts/check-status.sh

# 4. Helm 템플릿 검증 (개별)
helm template kube-prometheus prometheus-community/kube-prometheus-stack \
  -f src/kube-prometheus-stack/custom-values.yaml > /dev/null && echo "PASS"
```
