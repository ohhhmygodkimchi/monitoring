#!/bin/bash
# ============================================================
# K8s 모니터링 파이프라인 - 상태 확인 스크립트
# ============================================================
# 사용법: bash scripts/check-status.sh
# ============================================================

set -euo pipefail

echo "============================================"
echo "  K8s Monitoring Pipeline - Status Check"
echo "============================================"

# ----------------------------------------------------------
# 1. Pod 상태 확인
# ----------------------------------------------------------
echo ""
echo "📦 Pod Status:"
for ns in monitoring logging tracing sentry; do
  echo ""
  echo "━━━ Namespace: $ns ━━━"
  kubectl get pods -n "$ns" -o wide 2>/dev/null || echo "  ⚠️  Namespace '$ns' not found or no pods."
done

# ----------------------------------------------------------
# 2. Service 확인 (NodePort)
# ----------------------------------------------------------
echo ""
echo "🌐 Services (NodePort):"
echo ""
echo "━━━ monitoring ━━━"
kubectl get svc -n monitoring -o wide 2>/dev/null | grep -E "NAME|NodePort" || echo "  No NodePort services."
echo ""
echo "━━━ tracing ━━━"
kubectl get svc -n tracing -o wide 2>/dev/null | grep -E "NAME|NodePort" || echo "  No NodePort services."
echo ""
echo "━━━ sentry ━━━"
kubectl get svc -n sentry -o wide 2>/dev/null | grep -E "NAME|NodePort" || echo "  No NodePort services."

# ----------------------------------------------------------
# 3. PVC 상태 확인
# ----------------------------------------------------------
echo ""
echo "💾 PersistentVolumeClaims:"
for ns in monitoring logging tracing sentry; do
  echo ""
  echo "━━━ Namespace: $ns ━━━"
  kubectl get pvc -n "$ns" 2>/dev/null || echo "  No PVCs found."
done

# ----------------------------------------------------------
# 4. Helm Releases
# ----------------------------------------------------------
echo ""
echo "⎈ Helm Releases:"
helm list -A 2>/dev/null || echo "  ⚠️  Unable to list Helm releases."

# ----------------------------------------------------------
# 5. 접속 정보
# ----------------------------------------------------------
echo ""
echo "============================================"
echo "📊 Access Points:"
echo "  - Grafana:    http://<NodeIP>:30080"
echo "  - Jaeger UI:  http://<NodeIP>:30086"
echo "  - Sentry UI:  http://<NodeIP>:30090"
echo "============================================"
