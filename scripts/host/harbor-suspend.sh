#!/usr/bin/env bash
# harbor-suspend.sh — Harbor 배포를 0으로 스케일다운해 리소스를 절약한다.
# resume: scripts/host/harbor-resume.sh
set -euo pipefail

KUBECONFIG="${KUBECONFIG:-$(dirname "$0")/../../kubeconfig}"
export KUBECONFIG

NAMESPACE="harbor"

DEPLOYMENTS=(
  harbor-core
  harbor-jobservice
  harbor-nginx
  harbor-portal
  harbor-registry
  harbor-trivy
)

STATEFULSETS=(
  harbor-database
  harbor-redis
)

echo "[harbor-suspend] scaling down Harbor in namespace '${NAMESPACE}'"

for dep in "${DEPLOYMENTS[@]}"; do
  if kubectl get deployment "${dep}" -n "${NAMESPACE}" >/dev/null 2>&1; then
    kubectl scale deployment "${dep}" -n "${NAMESPACE}" --replicas=0
    echo "  scaled: ${dep}"
  fi
done

for sts in "${STATEFULSETS[@]}"; do
  if kubectl get statefulset "${sts}" -n "${NAMESPACE}" >/dev/null 2>&1; then
    kubectl scale statefulset "${sts}" -n "${NAMESPACE}" --replicas=0
    echo "  scaled: ${sts}"
  fi
done

echo "[harbor-suspend] done — Harbor suspended"
