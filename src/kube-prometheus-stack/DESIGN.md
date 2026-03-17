# 모듈 설계서: kube-prometheus-stack

## 1. 목적
K8s 클러스터의 인프라 메트릭(CPU, Memory, Disk I/O, Network) 수집, 시각화, 알람 기능을 제공한다.

## 2. 포함 컴포넌트
| 컴포넌트           | 유형           | 역할                                  |
|-------------------|---------------|--------------------------------------|
| Prometheus        | StatefulSet   | 메트릭 수집 및 저장(TSDB)               |
| Alertmanager      | StatefulSet   | 알람 규칙 평가 및 외부 알림 발송          |
| Grafana           | Deployment    | 대시보드 시각화                         |
| Node Exporter     | DaemonSet     | 각 노드의 하드웨어/OS 메트릭 노출        |
| Kube-State-Metrics| Deployment    | K8s 오브젝트 상태 메트릭 노출            |

## 3. Helm 차트 정보
- **Repository:** `https://prometheus-community.github.io/helm-charts`
- **Chart:** `prometheus-community/kube-prometheus-stack`
- **Namespace:** `monitoring`

## 4. custom-values.yaml 핵심 설정 항목
```yaml
# Prometheus
prometheus:
  prometheusSpec:
    retention: 15d                    # REQ-N-02
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          resources:
            requests:
              storage: 50Gi
    resources:                         # REQ-N-01
      limits:
        cpu: "2"
        memory: 4Gi
      requests:
        cpu: "500m"
        memory: 2Gi

# Alertmanager
alertmanager:
  config:
    receivers:
      - name: slack-notifications
        slack_configs:
          - api_url_secret:            # K8s Secret 참조
              name: alertmanager-slack
              key: webhook-url
            channel: '#alerts'
            send_resolved: true

# Grafana
grafana:
  adminPassword: ""                    # Secret으로 주입 (REQ-N-06)
  persistence:
    enabled: true
    size: 5Gi
  service:
    type: NodePort
    nodePort: 30080

# Node Exporter
nodeExporter:
  resources:
    limits:
      cpu: 200m
      memory: 256Mi
```

## 5. 입력 / 출력
- **입력(Input):** K8s 클러스터 내 각 노드/Pod의 `/metrics` 엔드포인트 (Pull 모델)
- **출력(Output):**
  - Grafana 대시보드 (시각화)
  - Alertmanager → Slack Webhook (알람)

## 6. 배포 명령
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f src/kube-prometheus-stack/custom-values.yaml
```

## 7. 검증 방법
1. `kubectl get pods -n monitoring` — 모든 Pod `Running` 확인
2. Grafana UI 접속 (`<NodeIP>:30080`) → 기본 대시보드 로딩 확인
3. Prometheus UI → `Targets` 페이지에서 모든 Scrape Target `UP` 확인
4. 테스트 알람 규칙 트리거 → Slack 채널 수신 확인
