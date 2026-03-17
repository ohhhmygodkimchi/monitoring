# 모듈 설계서: Sentry (Self-Hosted)

## 1. 목적
애플리케이션 레벨의 런타임 에러(Unhandled Exception 등)를 SDK를 통해 자동 수집하고, Call Stack 및 발생 맥락을 시각화하여 에러 이슈를 관리한다.

## 2. 포함 컴포넌트
| 컴포넌트           | 유형           | 역할                                 |
|-------------------|---------------|-------------------------------------|
| Sentry Web        | Deployment    | Web UI 및 API 서버                    |
| Sentry Worker     | Deployment    | 비동기 작업 처리 (이벤트 처리, 알림 등)  |
| Sentry Relay      | Deployment    | SDK 이벤트 수신 프록시                  |
| PostgreSQL        | StatefulSet   | 메타데이터 저장                        |
| Redis             | StatefulSet   | 캐시 및 큐                             |
| ClickHouse        | StatefulSet   | 이벤트 데이터 저장 (고속 분석용)         |
| Kafka (선택)      | StatefulSet   | 이벤트 버퍼링 (고부하 환경)              |

> **주의:** Sentry Self-Hosted는 의존성이 많아 상당한 리소스(최소 8GB RAM 이상 권장)가 필요합니다. 인프라 자원을 반드시 확인하세요.

## 3. Helm 차트 정보
- **Repository:** `https://sentry-kubernetes.github.io/charts`
- **Chart:** `sentry/sentry`
- **Namespace:** `sentry`

## 4. custom-values.yaml 핵심 설정 항목
```yaml
user:
  create: true
  email: admin@example.com
  password: ""                        # K8s Secret으로 주입 (REQ-N-06)

sentry:
  web:
    replicaCount: 1
    resources:
      limits:
        cpu: "2"
        memory: 4Gi
  worker:
    replicaCount: 2
    resources:
      limits:
        cpu: "1"
        memory: 2Gi

postgresql:
  enabled: true
  persistence:
    size: 20Gi
  auth:
    existingSecret: sentry-postgres-secret  # Secret 참조

redis:
  enabled: true
  architecture: standalone

clickhouse:
  enabled: true
  persistence:
    size: 30Gi

ingress:
  enabled: false                      # NodePort 사용

service:
  type: NodePort
  nodePort: 30090
```

## 5. 입력 / 출력
- **입력(Input):** Application Pod → Sentry SDK → Sentry Relay (HTTP, DSN 기반)
- **출력(Output):**
  - Sentry Web UI (이슈 대시보드, NodePort:30090)
  - 이메일/Slack 알림 (Sentry 내장 Integration)

## 6. 배포 명령
```bash
helm repo add sentry https://sentry-kubernetes.github.io/charts
helm repo update

# Secret 생성 (사전 작업)
kubectl create namespace sentry
kubectl create secret generic sentry-postgres-secret \
  --namespace sentry \
  --from-literal=postgres-password=<SECURE_PASSWORD>

helm install sentry sentry/sentry \
  --namespace sentry \
  -f src/sentry/custom-values.yaml
```

## 7. 검증 방법
1. `kubectl get pods -n sentry` — 모든 컴포넌트 `Running` 확인 (초기 기동에 5~10분 소요 가능)
2. Sentry Web UI 접속 (`<NodeIP>:30090`) → 로그인 확인
3. 테스트 프로젝트 생성 → SDK DSN 발급 → 테스트 에러 전송 → 이슈 목록에 표시 확인
