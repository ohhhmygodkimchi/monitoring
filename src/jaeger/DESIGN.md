# 모듈 설계서: Jaeger

## 1. 목적
OpenTelemetry Collector로부터 전달받은 분산 트레이스 데이터를 저장하고, 트레이스 검색/시각화 UI를 제공하여 API 병목 구간 및 서비스 간 호출 경로를 분석한다.

## 2. 포함 컴포넌트
| 컴포넌트           | 유형           | 역할                              |
|-------------------|---------------|----------------------------------|
| Jaeger Collector  | Deployment    | 트레이스 데이터 수신 및 저장         |
| Jaeger Query      | Deployment    | 트레이스 검색 API 및 Web UI 제공    |
| Elasticsearch     | StatefulSet   | 트레이스 데이터 영구 저장 백엔드      |

> **대안:** Elasticsearch 대신 Cassandra 또는 Jaeger의 내장 Badger(경량) 사용도 가능. 온프레미스 자원 상황에 따라 결정.

## 3. Helm 차트 정보
- **Repository:** `https://jaegertracing.github.io/helm-charts`
- **Chart:** `jaegertracing/jaeger`
- **Namespace:** `tracing`

## 4. custom-values.yaml 핵심 설정 항목
```yaml
provisionDataStore:
  cassandra: false
  elasticsearch: true               # Elasticsearch를 스토리지 백엔드로 사용

storage:
  type: elasticsearch
  elasticsearch:
    host: elasticsearch-master       # 같은 namespace 내 ES 서비스
    port: 9200

collector:
  replicaCount: 2
  resources:
    limits:
      cpu: "1"
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi

query:
  replicaCount: 1
  service:
    type: NodePort
    nodePort: 30086                  # Jaeger UI 접근 포트
  resources:
    limits:
      cpu: 500m
      memory: 512Mi

elasticsearch:
  replicas: 1                        # 온프레미스 최소 구성
  minimumMasterNodes: 1
  volumeClaimTemplate:
    resources:
      requests:
        storage: 30Gi
  resources:
    limits:
      cpu: "1"
      memory: 2Gi
```

## 5. 입력 / 출력
- **입력(Input):** Otel Collector → OTLP/gRPC(:4317) 또는 Thrift(:14268)
- **출력(Output):**
  - Jaeger Query UI (Web, NodePort:30086)
  - Grafana Data Source (Jaeger 플러그인)

## 6. 배포 명령
```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

helm install jaeger jaegertracing/jaeger \
  --namespace tracing \
  -f src/jaeger/custom-values.yaml
```

## 7. 검증 방법
1. `kubectl get pods -n tracing` — Jaeger Collector, Query, ES 모두 `Running` 확인
2. Jaeger UI 접속 (`<NodeIP>:30086`) → Service 목록 로딩 확인
3. 테스트 트레이스 전송 후 Jaeger UI에서 Trace 검색 → 경로 시각화 확인
