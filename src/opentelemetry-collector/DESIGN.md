# 모듈 설계서: OpenTelemetry Collector

## 1. 목적
애플리케이션에서 생성되는 분산 트레이스(Trace) 및 애플리케이션 메트릭을 표준화된 방식(OTLP)으로 수집하고, 백엔드(Jaeger, Prometheus)로 내보내는 중간 수집기 역할을 수행한다.

## 2. 포함 컴포넌트
| 컴포넌트              | 유형                    | 역할                              |
|----------------------|------------------------|----------------------------------|
| Otel Collector       | DaemonSet 또는 Deployment | OTLP 데이터 수신 및 백엔드 Export   |

## 3. Helm 차트 정보
- **Repository:** `https://open-telemetry.github.io/opentelemetry-helm-charts`
- **Chart:** `open-telemetry/opentelemetry-collector`
- **Namespace:** `tracing`

## 4. custom-values.yaml 핵심 설정 항목
```yaml
mode: daemonset                       # 각 노드마다 수집기 배포

config:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

  processors:
    batch:
      timeout: 5s
      send_batch_size: 512
    memory_limiter:
      check_interval: 1s
      limit_mib: 512

  exporters:
    otlp/jaeger:
      endpoint: "jaeger-collector.tracing.svc.cluster.local:4317"
      tls:
        insecure: true
    prometheusremotewrite:
      endpoint: "http://kube-prometheus-prometheus.monitoring.svc.cluster.local:9090/api/v1/write"

  service:
    pipelines:
      traces:
        receivers: [otlp]
        processors: [memory_limiter, batch]
        exporters: [otlp/jaeger]
      metrics:
        receivers: [otlp]
        processors: [memory_limiter, batch]
        exporters: [prometheusremotewrite]

resources:                              # REQ-N-01
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

## 5. 입력 / 출력
- **입력(Input):** Application Pod → OTLP/gRPC(:4317) 또는 OTLP/HTTP(:4318)
- **출력(Output):**
  - Traces → Jaeger Collector (gRPC)
  - Metrics → Prometheus (Remote Write)

## 6. 배포 명령
```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

helm install otel-collector open-telemetry/opentelemetry-collector \
  --namespace tracing \
  --create-namespace \
  -f src/opentelemetry-collector/custom-values.yaml
```

## 7. 검증 방법
1. `kubectl get pods -n tracing` — 각 노드에 Otel Collector Pod `Running` 확인
2. `kubectl logs -n tracing <collector-pod>` — 에러 없이 Exporter 연결 확인
3. 테스트 App에서 트레이스 생성 → Jaeger UI에서 Trace 데이터 조회 확인
