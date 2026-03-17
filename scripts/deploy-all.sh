#!/bin/bash
# ============================================================
# K8s 모니터링 파이프라인 - 전체 Helm 배포 스크립트
# ============================================================
# 사용법: bash scripts/deploy-all.sh
# 사전 조건: scripts/create-secrets.sh 실행 완료
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "  K8s Monitoring Pipeline - Full Deployment"
echo "============================================"
echo "  Project Root: $PROJECT_ROOT"
echo ""

# ----------------------------------------------------------
# 1. Helm Repository 추가
# ----------------------------------------------------------
echo "[1/6] Adding Helm repositories..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts 2>/dev/null || true
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts 2>/dev/null || true
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo add sentry https://sentry-kubernetes.github.io/charts 2>/dev/null || true

helm repo update
echo "  ✅ Repositories added and updated."

# ----------------------------------------------------------
# 2. kube-prometheus-stack (monitoring namespace)
# ----------------------------------------------------------
echo ""
echo "[2/6] Deploying kube-prometheus-stack..."
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f "$PROJECT_ROOT/src/kube-prometheus-stack/custom-values.yaml" \
  --wait --timeout 10m
echo "  ✅ kube-prometheus-stack deployed."

# ----------------------------------------------------------
# 3. Loki Stack (logging namespace)
# ----------------------------------------------------------
echo ""
echo "[3/6] Deploying loki-stack..."
helm upgrade --install loki-stack grafana/loki-stack \
  --namespace logging \
  --create-namespace \
  -f "$PROJECT_ROOT/src/loki-stack/custom-values.yaml" \
  --wait --timeout 5m
echo "  ✅ loki-stack deployed."

# ----------------------------------------------------------
# 4. OpenTelemetry Collector (tracing namespace)
# ----------------------------------------------------------
echo ""
echo "[4/6] Deploying opentelemetry-collector..."
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --namespace tracing \
  --create-namespace \
  -f "$PROJECT_ROOT/src/opentelemetry-collector/custom-values.yaml" \
  --wait --timeout 5m
echo "  ✅ opentelemetry-collector deployed."

# ----------------------------------------------------------
# 5. Jaeger (tracing namespace)
# ----------------------------------------------------------
echo ""
echo "[5/6] Deploying jaeger..."
helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace tracing \
  -f "$PROJECT_ROOT/src/jaeger/custom-values.yaml" \
  --wait --timeout 10m
echo "  ✅ jaeger deployed."

# ----------------------------------------------------------
# 6. Sentry (sentry namespace)
# ----------------------------------------------------------
echo ""
echo "[6/6] Deploying sentry..."
helm upgrade --install sentry sentry/sentry \
  --namespace sentry \
  --create-namespace \
  -f "$PROJECT_ROOT/src/sentry/custom-values.yaml" \
  --wait --timeout 15m
echo "  ✅ sentry deployed."

# ----------------------------------------------------------
# 배포 결과 확인
# ----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ All components deployed successfully!"
echo "============================================"
echo ""
echo "📊 Access Points:"
echo "  - Grafana:    http://<NodeIP>:30080"
echo "  - Jaeger UI:  http://<NodeIP>:30086"
echo "  - Sentry UI:  http://<NodeIP>:30090"
echo ""
echo "🔍 Pod Status:"
for ns in monitoring logging tracing sentry; do
  echo ""
  echo "--- $ns ---"
  kubectl get pods -n "$ns" -o wide
done
