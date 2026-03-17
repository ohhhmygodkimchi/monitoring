# 모듈 설계서: Loki Stack (Loki + Promtail)

## 1. 목적
K8s 클러스터 내 모든 Pod의 로그(stdout/stderr)를 중앙으로 수집하고, 장애 시점 전후의 로그를 신속하게 검색할 수 있도록 한다. Grafana와 통합하여 메트릭-로그 간 상관관계를 분석한다.

## 2. 포함 컴포넌트
| 컴포넌트    | 유형         | 역할                                  |
|------------|-------------|--------------------------------------|
| Loki       | StatefulSet | 로그 인덱싱 및 저장                     |
| Promtail   | DaemonSet   | 각 노드의 Pod 로그 수집 및 Loki로 Push  |

## 3. Helm 차트 정보
- **Repository:** `https://grafana.github.io/helm-charts`
- **Chart:** `grafana/loki-stack` 또는 개별 `grafana/loki` + `grafana/promtail`
- **Namespace:** `logging`

## 4. custom-values.yaml 핵심 설정 항목
```yaml
loki:
  enabled: true
  persistence:
    enabled: true
    size: 100Gi
    storageClassName: local-path
  config:
    table_manager:
      retention_deletes_enabled: true
      retention_period: 720h          # 30일 (REQ-N-02)
    limits_config:
      ingestion_rate_mb: 10
      ingestion_burst_size_mb: 20
  resources:
    limits:
      cpu: "1"
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 512Mi

promtail:
  enabled: true
  config:
    clients:
      - url: http://loki.logging.svc.cluster.local:3100/loki/api/v1/push
    snippets:
      pipelineStages:
        - docker: {}
        - labeldrop:
            - filename
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

## 5. 입력 / 출력
- **입력(Input):** Pod stdout/stderr → Promtail (DaemonSet, `/var/log/pods` 마운트)
- **출력(Output):**
  - Loki → Grafana Explore (LogQL 쿼리)
  - K8s 라벨 기반 필터링 (Namespace, Pod, Container)

## 6. 배포 명령
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki-stack grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  -f src/loki-stack/custom-values.yaml
```

## 7. 검증 방법
1. `kubectl get pods -n logging` — Loki StatefulSet + Promtail DaemonSet 모두 `Running` 확인
2. Grafana → Data Sources → Loki 추가 (`http://loki.logging.svc.cluster.local:3100`)
3. Grafana Explore → LogQL 쿼리 예시: `{namespace="default"}` → 로그 출력 확인
4. 특정 Pod에서 로그 발생 → Grafana에서 실시간으로 수집되는지 확인
