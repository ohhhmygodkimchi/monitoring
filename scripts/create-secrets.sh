#!/bin/bash
# ============================================================
# K8s 모니터링 파이프라인 - Secret 사전 생성 스크립트
# 배포 전 반드시 실행해야 합니다.
# ============================================================
# 사용법: bash scripts/create-secrets.sh
# 참고: 실행 전 아래 변수의 값을 실제 값으로 변경하세요.
# ============================================================

set -euo pipefail

# ============================================================
# 변수 설정 (반드시 변경하세요!)
# ============================================================
GRAFANA_ADMIN_USER="${GRAFANA_ADMIN_USER:-admin}"
GRAFANA_ADMIN_PASSWORD="${GRAFANA_ADMIN_PASSWORD:-CHANGE_ME_grafana}"
SENTRY_POSTGRES_PASSWORD="${SENTRY_POSTGRES_PASSWORD:-CHANGE_ME_sentry_pg}"
SENTRY_ADMIN_PASSWORD="${SENTRY_ADMIN_PASSWORD:-CHANGE_ME_sentry_admin}"
SENTRY_SECRET_KEY="${SENTRY_SECRET_KEY:-CHANGE_ME_sentry_secret_key_min_32_chars}"

echo "============================================"
echo "  K8s Monitoring - Secret Creation Script"
echo "============================================"

# ----------------------------------------------------------
# 1. Namespace 생성
# ----------------------------------------------------------
echo ""
echo "[1/5] Creating namespaces..."
for ns in monitoring logging tracing sentry; do
  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done
echo "  ✅ Namespaces created."

# ----------------------------------------------------------
# 2. monitoring namespace Secrets
# ----------------------------------------------------------
echo ""
echo "[2/5] Creating monitoring secrets..."

# Grafana Admin
kubectl create secret generic grafana-admin-secret \
  --namespace monitoring \
  --from-literal=admin-user="$GRAFANA_ADMIN_USER" \
  --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "  ✅ Monitoring secrets created."

# ----------------------------------------------------------
# 3. sentry namespace Secrets
# ----------------------------------------------------------
echo ""
echo "[3/5] Creating sentry secrets..."

# Sentry PostgreSQL
kubectl create secret generic sentry-postgres-secret \
  --namespace sentry \
  --from-literal=postgres-password="$SENTRY_POSTGRES_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

# Sentry Admin
kubectl create secret generic sentry-admin-secret \
  --namespace sentry \
  --from-literal=admin-password="$SENTRY_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

# Sentry Secret Key
kubectl create secret generic sentry-secret-key \
  --namespace sentry \
  --from-literal=secret-key="$SENTRY_SECRET_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "  ✅ Sentry secrets created."

# ----------------------------------------------------------
# 4. 확인
# ----------------------------------------------------------
echo ""
echo "[4/5] Verifying secrets..."
echo "--- monitoring ---"
kubectl get secrets -n monitoring
echo ""
echo "--- sentry ---"
kubectl get secrets -n sentry

# ----------------------------------------------------------
# 5. 완료
# ----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ All secrets created successfully!"
echo "  Next: Run scripts/deploy-all.sh"
echo "============================================"
