# 기술 스택 명세서 (TECH STACK)

## 1. 개요
본 문서는 K8s 온프레미스 모니터링 파이프라인 구축을 위한 기술 스택 및 라이브러리 선정 결과를 정의합니다. 
> *참고: 본 선정은 Context7 서비스 미활성화 상태에서 일반 웹 검색 및 K8s 생태계 표준(Best Practice)에 기반하여 작성되었습니다.*

## 2. 모니터링 컴포넌트별 선정 스택

### 2.1 인프라 모니터링 (Infrastructure)
*   **선정 기술:** **kube-prometheus-stack** (Prometheus + Grafana + Alertmanager 묶음)
*   **Helm 배포:** `prometheus-community/kube-prometheus-stack` 차트 사용
*   **선정 이유:** K8s 환경의 사실상 표준이며, Node Exporter와 Kube-State-Metrics를 기본 포함하여 쉽고 강력한 하드웨어 컴포넌트 수집을 지원. Alertmanager가 내장되어 임계치 알람을 손쉽게 설정 가능.

### 2.2 APM (분산 트레이싱 포함)
*   **선정 기술:** **OpenTelemetry** (수집기) + **Jaeger** (백엔드/UI)
*   **Helm 배포:**
    *   Otel 수집기: `open-telemetry/opentelemetry-collector` 차트 사용
    *   Jaeger: `jaegertracing/jaeger` 차트 사용
*   **선정 이유:** 
    *   특정 언어에 종속되지 않는 OpenTelemetry 표준을 사용하여 Java, Node, Python 등 서비스 확장에 유리함.
    *   분산 트레이싱 데이터 저장을 위한 검증된 오픈소스인 Jaeger 활용. (운영 환경에 따라 Cassandra/Elasticsearch 등 스토리지 백엔드 구성 필요)

### 2.3 에러 트래킹 (Error Tracking)
*   **선정 기술:** **Sentry** (On-Premise)
*   **Helm 배포:** `sentry/sentry` 차트 사용 (의존성: PostgreSQL, Redis, ClickHouse 등 필요)
*   **선정 이유:** 어플리케이션 소스 코드 레벨의 치명적 에러 콜스택 캡처와 이슈 분류 기능이 압도적. K8s 기반 On-Premise 구축을 지원. (리소스 요구량이 어느정도 있으므로 가용 자원 고려 필요).

### 2.4 통합 로그 관리 (Centralized Logging)
*   **선정 기술:** **Loki** + **Promtail** (+ Grafana 통합)
*   **Helm 배포:** `grafana/loki-stack` (혹은 개별 차트) 사용
*   **선정 이유:** ELK(Elasticsearch-Logstash-Kibana) 스택 대비 인덱스 부담이 적고 용량이 매우 가벼워 K8s 로그 수집에 최적화된 경량 스택임. 기존 Grafana 대시보드에서 쿼리(LogQL)가 가능하여 UI 통합이 매우 뛰어남.

## 3. 요약 및 아키텍처 (Draft)
```mermaid
graph TD;
    subgraph K8s Cluster (On-Premise)
        Pod_App[Application Pods] -->|Logs| Promtail;
        Pod_App -->|Metrics| Prometheus;
        Pod_App -->|Traces| Otel_Collector[OpenTelemetry Collector];
        Pod_App -->|Errors| Sentry_SDK[Sentry SDK];

        Otel_Collector -->|Export| Jaeger;
        Promtail -->|Push| Loki;
        Prometheus --> |Alerts| Alertmanager;
    end

    Loki -->|Data Source| Grafana;
    Prometheus -->|Data Source| Grafana;
    Jaeger -->|Data Source (Optional)| Grafana;

    Grafana --> Developer[Dashboard View];
    Alertmanager --> Slack[Slack / Messanger];
    Sentry_SDK --> Sentry_Server[Sentry Self-Hosted];
```

## 4. 향후 검토 사항
*   **Context7 라이브러리 연동:** 현재 사용할 수 없는 상태이나 추후 환경 정비 시 각 컴포넌트들의 공식 ID를 맵핑할 계획.
*   **스토리지 백엔드 설정:** Prometheus (TSDB), Jaeger (Elasticsearch 등), Sentry (ClickHouse/PostgreSQL 등), Loki 의 영구 데이터 보존 처리 (PersistentVolumeClaim) 방안 확립.
