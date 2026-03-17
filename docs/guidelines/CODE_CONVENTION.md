# 코딩 컨벤션 (CODE CONVENTION)

> 본 프로젝트는 Helm Chart 기반 인프라 배포 프로젝트이므로, 코딩 컨벤션은 **YAML 작성 규칙**, **Helm values 관리 규칙**, **K8s 리소스 네이밍 규칙**을 중심으로 정의합니다.

---

## 1. YAML 작성 규칙

### 1.1 들여쓰기
- **2 spaces** 사용 (탭 사용 금지)
- 중첩 깊이는 **최대 6단계**까지 허용

### 1.2 주석
- 모든 주요 설정 블록에는 **한 줄 주석**으로 설정 이유를 명시한다
- 형식: `# [REQ-ID] 설명` (요구사항 ID가 있는 경우)
```yaml
# [REQ-N-02] 메트릭 보존 기간: 15일
retention: 15d
```

### 1.3 값 표기
- Boolean: `true` / `false` (소문자)
- 문자열: 특수문자가 포함된 경우만 `""` 사용
- 숫자: 단위 표기 시 K8s 표준 사용 (`Gi`, `Mi`, `m` 등)

## 2. Helm Values 관리 규칙

### 2.1 파일 명명
| 파일명                  | 용도                                    |
|------------------------|-----------------------------------------|
| `default-values.yaml`  | `helm show values`로 추출한 원본 (수정 금지)|
| `custom-values.yaml`   | 프로젝트 환경에 맞게 오버라이드한 설정 파일    |

### 2.2 custom-values.yaml 작성 원칙
1. **변경하는 항목만 기재**한다 (default와 동일한 값은 생략)
2. 각 섹션 상단에 **변경 이유** 주석을 작성한다
3. **민감 정보(Password, Token, Webhook URL 등)**는 절대 직접 기재하지 않는다
   - K8s Secret 또는 `existingSecret` 필드를 사용한다

### 2.3 금지 사항
- ❌ `default-values.yaml`을 직접 수정하는 것
- ❌ `custom-values.yaml`에 비밀번호를 평문으로 기재하는 것
- ❌ Helm install 시 `--set` 플래그로 값을 인라인 전달하는 것 (추적 불가)

## 3. K8s 리소스 네이밍 규칙

### 3.1 Namespace
| Namespace    | 용도                  |
|-------------|----------------------|
| `monitoring`| 메트릭 수집, 알람, 시각화 |
| `logging`   | 로그 수집/저장          |
| `tracing`   | 분산 트레이싱           |
| `sentry`    | 에러 트래킹             |

### 3.2 Helm Release Name
- **소문자 + 하이픈(-)**만 사용
- 컴포넌트 역할을 명확히 표현
```
kube-prometheus    (O)
otel-collector     (O)
loki-stack         (O)
my_prometheus_v2   (X) ← 언더스코어/버전 붙이지 않음
```

### 3.3 Secret 네이밍
- 형식: `<component>-<purpose>-secret`
- 예: `grafana-admin-secret`, `sentry-postgres-secret`, `alertmanager-slack-secret`

## 4. Git 커밋 메시지 규칙

### 4.1 형식
```
<type>(<scope>): <subject>

<body> (선택)
```

### 4.2 Type
| Type     | 용도                          |
|----------|------------------------------|
| `feat`   | 새 모듈/기능 추가              |
| `fix`    | 설정 오류 수정                 |
| `docs`   | 문서 추가/수정                 |
| `chore`  | 빌드/배포 스크립트, 의존성 변경  |
| `refactor`| values.yaml 구조 개선         |

### 4.3 Scope
- 모듈명을 사용: `prometheus`, `otel`, `jaeger`, `sentry`, `loki`
- 예: `feat(prometheus): add custom alert rules for CPU threshold`

## 5. 디렉토리 구조 규칙
```
src/
├── <module-name>/             # 소문자 + 하이픈
│   ├── DESIGN.md              # 모듈 설계서 (필수)
│   ├── custom-values.yaml     # Helm override 값 (필수)
│   └── default-values.yaml    # 원본 values (참조용, Git 추적)
docs/
├── planning/                  # PRD, TECH_STACK, REQUIREMENTS
├── design/                    # ARCHITECTURE
├── tests/                     # UNIT_TEST_CASES
├── guidelines/                # CODE_CONVENTION
├── reports/                   # 테스트 리포트
└── manual/                    # 사용자/개발자 가이드
tests/                         # 테스트 스크립트 (셸 스크립트 등)
```
