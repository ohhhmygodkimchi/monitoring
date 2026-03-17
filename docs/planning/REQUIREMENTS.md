# 상세 요구사항 명세서 (REQUIREMENTS)

## 1. 개요
본 문서는 K8s 온프레미스 파이프라인 구축을 위한 PRD 및 `TECH_STACK.md`를 바탕으로 개발 및 구축에 필요한 상세 요건들을 기능(Functional), 비기능(Non-Functional), 시스템(System) 관점에서 정의합니다.

## 2. 기능 요구사항 (Functional Requirements)

### 2.1 인프라 측정 (Prometheus + Grafana)
*   **REQ-F-01**: K8s 클러스터 내 모든 Node의 기본 메트릭(CPU, Memory, Disk, Network)을 수집해야 한다.
*   **REQ-F-02**: 모든 Pod 단위의 자원 사용량 메트릭을 수집해야 한다.
*   **REQ-F-03**: 수집된 메트릭을 시각화할 수 있는 사전 정의된(Grafana Labs 제공 등) 대시보드를 1개 이상 구성해야 한다.
*   **REQ-F-04**: 특정 수치(예: Node CPU 80% 이상, Pod Crash 반복) 연속 발생 시 Alertmanager를 통해 알람을 발생시켜야 한다.

### 2.2 APM 및 분산 트레이싱 (OpenTelemetry + Jaeger)
*   **REQ-F-05**: 시스템 내 주요 서비스(API 서버 등)는 OpenTelemetry SDK를 통해 트레이스 데이터를 생성해야 한다.
*   **REQ-F-06**: 생성된 트레이스 데이터는 DaemonSet 혹은 Deployment 형태의 Otel Collector로 전송되어야 한다.
*   **REQ-F-07**: Jaeger UI를 통해 특정 Trace ID로 분산 요청 경로와 각 구간별 소요 시간을 검색하고 확인할 수 있어야 한다.

### 2.3 에러 트래킹 (Sentry)
*   **REQ-F-08**: Application Level에서 발생하는 Unhandled Exception 및 Warning 급 이상의 에러를 Sentry 수집기로 전송해야 한다.
*   **REQ-F-09**: Sentry UI에서 에러가 발생한 코드의 Call Stack, 발생 빈도, 영향을 받은 사용자 수(가능한 경우)를 시각화해야 한다.
*   **REQ-F-10**: 동일한 원인으로 발생하는 에러는 하나의 이슈로 자동 그룹화(Grouping) 되어야 한다.

### 2.4 중앙 집중형 로그 관리 (Loki + Promtail)
*   **REQ-F-11**: 클러스터 내 모든 Pod의 `stdout`/`stderr` 로그를 Promtail이 수집하여 Loki로 전송해야 한다.
*   **REQ-F-12**: 전송된 로그는 K8s 메타데이터(Namespace, Pod, Container 라벨 등)를 기반으로 인덱싱되어야 한다.
*   **REQ-F-13**: Grafana 대시보드의 Explore(LogQL) 기능을 통해 특정 조건의 로그를 필터링하고 검색할 수 있어야 한다.

## 3. 비기능 요구사항 (Non-Functional Requirements)

### 3.1 성능 및 자원 (Performance)
*   **REQ-N-01 (자원 효율성):** 모니터링 에이전트(Otel Collector, Promtail 등)가 각 Node에서 소비하는 CPU 및 Memory 리소스는 최소한으로 유지되도록 Helm `values.yaml` 에 `resources.limits`를 엄격히 설정해야 한다.
*   **REQ-N-02 (데이터 보존):** 
    *   메트릭(Prometheus): 최근 15일 보관
    *   로그(Loki): 최근 30일 보관
    *   트레이스(Jaeger): 최근 7일 보관
    *   에러(Sentry): 최근 90일 보관

### 3.2 고가용성 및 확장성 (Availability & Scalability)
*   **REQ-N-03**: 수집기 컴포넌트(Prometheus, Otel Collector 등) 장애 시 전체 서비스에 영향을 미치지 않도록 격리되어야 한다.
*   **REQ-N-04**: 로드 증가 시 수집기(StatefulSet 혹은 Deployment 형태)를 Scale-Out 할 수 있는 구조여야 한다.

### 3.3 보안 (Security)
*   **REQ-N-05**: 대시보드(Grafana, Sentry, Jaeger) 접근 시 인증/인가(Authentication/Authorization) 메커니즘을 적용해야 한다. (최소한의 기본 ID/PW 기반 인증)
*   **REQ-N-06**: Helm 차트 배포 시 민감 정보(DB 패스워드, API 키 등)는 K8s Secret을 통해 주입되어야 하며 평문으로 `values.yaml`에 저장되어서는 안 된다.

## 4. 제약 사항 (Constraints)
*   **CON-01**: 모든 모니터링 컴포넌트는 반드시 **Helm Charts** 형태로 템플릿화되어 배포되어야 한다.
*   **CON-02**: 배포된 K8s 자원(Pod, SVC 등)은 `monitoring` (또는 각 역할별) 등 별도로 분리된 Namespace 내에 존재해야 한다.
*   **CON-03**: 물리 서버(On-Premise) 환경의 제약으로 퍼블릭 클라우드 전용 관리형 서비스(예: CloudWatch, Datadog)는 사용할 수 없다.
