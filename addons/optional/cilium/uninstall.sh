#!/usr/bin/env bash
# addons/optional/cilium/uninstall.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

CILIUM_NS="${CILIUM_NS:-kube-system}"
GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.2.0}"

echo "[INFO] uninstall optional addon: cilium"

kubectl delete -f "${ROOT_DIR}/addons/values/cilium/l2pool.yaml" --ignore-not-found

helm uninstall cilium --namespace "${CILIUM_NS}" --ignore-not-found || true

echo "[INFO] removing Gateway API CRDs ${GATEWAY_API_VERSION}"
kubectl delete -f \
  "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml" \
  --ignore-not-found || true

echo "[INFO] cilium uninstall complete"
