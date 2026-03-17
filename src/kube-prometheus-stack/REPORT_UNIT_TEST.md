# 단위 테스트 보고서: kube-prometheus-stack

## 모듈 정보
- **모듈:** kube-prometheus-stack
- **파일:** `src/kube-prometheus-stack/custom-values.yaml`
- **작성일:** 2026-03-17

## 테스트 결과

| ID        | 시나리오                    | 상태  | 비고                                         |
|-----------|---------------------------|-------|---------------------------------------------|
| UT-KPS-01 | Helm 템플릿 렌더링 정상 여부 | ⏳ 대기 | K8s 클러스터에서 `helm template` 실행 필요      |
| UT-KPS-02 | Pod 기동 확인               | ⏳ 대기 | 배포 후 확인                                  |
| UT-KPS-03 | Prometheus Target 수집 확인  | ⏳ 대기 | Prometheus UI에서 확인                        |
| UT-KPS-04 | Grafana 대시보드 로딩 확인    | ⏳ 대기 | Grafana UI 접속 후 확인                       |
| UT-KPS-05 | Alert Rule 트리거 테스트      | ⏳ 대기 | CPU 부하 테스트 후 Slack 수신 확인              |
| UT-KPS-06 | resources.limits 적용 확인   | ⏳ 대기 | `kubectl describe pod` 결과 확인               |

## 코드 리뷰 체크리스트

- [x] `retention: 15d` 설정으로 REQ-N-02 충족
- [x] 모든 컴포넌트에 `resources.limits/requests` 설정 (REQ-N-01)
- [x] Grafana admin 비밀번호 `existingSecret` 사용 (REQ-N-06)
- [x] Alertmanager Slack `api_url_file`로 Secret 참조 (REQ-N-06)
- [x] 커스텀 Alert Rules 추가 (CPU 80%, Memory 85%, CrashLoop)
- [x] Grafana에 Loki, Jaeger Data Source 자동 등록 (Cross-namespace)
- [x] PVC 스토리지 50Gi 설정
