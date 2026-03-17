# 단위 테스트 케이스 초안 (UNIT_TEST_CASES)

> 본 프로젝트는 Helm Chart 기반 인프라 배포 프로젝트이므로, "단위 테스트"는 각 모듈의 **Helm 배포 정합성 검증** 및 **기능 동작 확인(Smoke Test)**을 의미합니다.

---

## 1. kube-prometheus-stack

| ID       | 시나리오                         | 검증 방법                                                              | 기대 결과                        |
|----------|--------------------------------|----------------------------------------------------------------------|--------------------------------|
| UT-KPS-01| Helm 템플릿 렌더링 정상 여부      | `helm template` 명령으로 YAML 렌더링                                    | 에러 없이 YAML 출력              |
| UT-KPS-02| Pod 기동 확인                    | `kubectl get pods -n monitoring`                                      | 모든 Pod `Running` 상태          |
| UT-KPS-03| Prometheus Target 수집 확인      | Prometheus UI → Status → Targets                                      | 모든 Target `UP`                |
| UT-KPS-04| Grafana 대시보드 로딩 확인        | Grafana UI 접속 → 기본 대시보드 존재 확인                                 | 대시보드 1개 이상 로딩            |
| UT-KPS-05| Alert Rule 트리거 테스트          | 의도적으로 CPU 부하 생성 → Alertmanager 수신 확인                         | Slack 채널에 알림 도착            |
| UT-KPS-06| resources.limits 적용 확인       | `kubectl describe pod <prometheus-pod> -n monitoring`                  | CPU/Memory limits 값이 설정대로  |

## 2. OpenTelemetry Collector

| ID       | 시나리오                         | 검증 방법                                                              | 기대 결과                        |
|----------|--------------------------------|----------------------------------------------------------------------|--------------------------------|
| UT-OTC-01| Helm 템플릿 렌더링 정상 여부      | `helm template`                                                       | 에러 없이 YAML 출력              |
| UT-OTC-02| DaemonSet Pod 기동 확인          | `kubectl get pods -n tracing -l app=opentelemetry-collector`           | 각 노드에 1개씩 `Running`        |
| UT-OTC-03| gRPC 수신 포트 확인              | `kubectl exec <pod> -- wget -qO- localhost:13133/`(health check)       | Health OK 응답                  |
| UT-OTC-04| Jaeger Exporter 연결 확인        | Collector 로그에서 Exporter 연결 에러 없음 확인                           | 에러 로그 0건                    |
| UT-OTC-05| memory_limiter 적용 확인         | Collector 로그에서 `memory_limiter` 초기화 확인                           | memory_limiter 활성화 로그        |

## 3. Jaeger

| ID       | 시나리오                         | 검증 방법                                                              | 기대 결과                        |
|----------|--------------------------------|----------------------------------------------------------------------|--------------------------------|
| UT-JAE-01| Helm 템플릿 렌더링 정상 여부      | `helm template`                                                       | 에러 없이 YAML 출력              |
| UT-JAE-02| Jaeger 전체 Pod 기동 확인        | `kubectl get pods -n tracing`                                         | Collector, Query, ES 모두 `Running`|
| UT-JAE-03| Jaeger UI 접근 확인              | `curl http://<NodeIP>:30086`                                          | HTTP 200 응답                   |
| UT-JAE-04| 테스트 트레이스 조회              | Otel SDK로 트레이스 전송 → Jaeger UI에서 검색                             | Trace ID로 경로 시각화 확인       |
| UT-JAE-05| ES 스토리지 PVC 바인딩 확인       | `kubectl get pvc -n tracing`                                          | PVC `Bound` 상태                |

## 4. Sentry

| ID       | 시나리오                         | 검증 방법                                                              | 기대 결과                        |
|----------|--------------------------------|----------------------------------------------------------------------|--------------------------------|
| UT-SEN-01| Helm 템플릿 렌더링 정상 여부      | `helm template`                                                       | 에러 없이 YAML 출력              |
| UT-SEN-02| 전체 Pod 기동 확인               | `kubectl get pods -n sentry`                                          | Web, Worker, Relay, DB 등 `Running`|
| UT-SEN-03| Web UI 접근 확인                 | `curl http://<NodeIP>:30090`                                          | HTTP 200 (로그인 페이지)          |
| UT-SEN-04| 프로젝트 생성 및 DSN 발급         | Sentry UI → 프로젝트 생성                                              | DSN URL 정상 발급                |
| UT-SEN-05| 테스트 에러 이벤트 수신            | Sentry SDK로 테스트 에러 전송                                           | 이슈 목록에 에러 이벤트 표시       |
| UT-SEN-06| Secret 참조 확인                 | `kubectl get secret sentry-postgres-secret -n sentry`                 | Secret 존재 및 Pod 마운트 확인    |

## 5. Loki Stack

| ID       | 시나리오                         | 검증 방법                                                              | 기대 결과                        |
|----------|--------------------------------|----------------------------------------------------------------------|--------------------------------|
| UT-LOK-01| Helm 템플릿 렌더링 정상 여부      | `helm template`                                                       | 에러 없이 YAML 출력              |
| UT-LOK-02| Loki + Promtail Pod 기동 확인    | `kubectl get pods -n logging`                                         | Loki StatefulSet + Promtail DaemonSet `Running`|
| UT-LOK-03| Loki 헬스체크                    | `curl http://loki.logging.svc:3100/ready`                              | `ready` 응답                    |
| UT-LOK-04| Grafana에서 LogQL 쿼리 테스트    | Grafana Explore → `{namespace="default"}`                              | 로그 행 출력                     |
| UT-LOK-05| 로그 보존 기간 설정 확인          | Loki 설정 조회 → `retention_period` 값 확인                              | `720h` (30일)                   |
| UT-LOK-06| PVC 바인딩 확인                  | `kubectl get pvc -n logging`                                           | PVC `Bound` 상태                |

---

## 테스트 실행 방법 요약

### Helm 템플릿 검증 (모든 모듈 공통)
```bash
# 예시: kube-prometheus-stack
helm template kube-prometheus prometheus-community/kube-prometheus-stack \
  -f src/kube-prometheus-stack/custom-values.yaml \
  --namespace monitoring > /dev/null && echo "PASS" || echo "FAIL"
```

### Pod 기동 확인 (모든 모듈 공통)
```bash
# 전체 namespace 한번에 확인
for ns in monitoring tracing logging sentry; do
  echo "=== Namespace: $ns ==="
  kubectl get pods -n $ns
done
```
