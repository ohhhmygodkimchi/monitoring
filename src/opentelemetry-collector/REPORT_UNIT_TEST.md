# 단위 테스트 보고서: OpenTelemetry Collector

## 모듈 정보
- **모듈:** opentelemetry-collector
- **파일:** `src/opentelemetry-collector/custom-values.yaml`
- **작성일:** 2026-03-17

## 테스트 결과

| ID        | 시나리오                    | 상태  | 비고                                         |
|-----------|---------------------------|-------|---------------------------------------------|
| UT-OTC-01 | Helm 템플릿 렌더링 정상 여부 | ⏳ 대기 | K8s 클러스터에서 `helm template` 실행 필요      |
| UT-OTC-02 | DaemonSet Pod 기동 확인     | ⏳ 대기 | 배포 후 확인                                  |
| UT-OTC-03 | gRPC 수신 포트 확인          | ⏳ 대기 | Health check 엔드포인트 확인                   |
| UT-OTC-04 | Jaeger Exporter 연결 확인    | ⏳ 대기 | Collector 로그 확인                           |
| UT-OTC-05 | memory_limiter 적용 확인     | ⏳ 대기 | Collector 로그에서 초기화 확인                  |

## 코드 리뷰 체크리스트

- [x] DaemonSet 모드로 각 노드에 배포
- [x] OTLP gRPC(:4317) + HTTP(:4318) 수신 설정
- [x] traces → Jaeger 파이프라인 구성
- [x] metrics → Prometheus Remote Write 파이프라인 구성
- [x] `memory_limiter` 프로세서 활성화 (400MiB limit, REQ-N-01)
- [x] `batch` 프로세서 설정 (512 batch size)
- [x] `resources.limits` 설정 (500m CPU, 512Mi Memory)
