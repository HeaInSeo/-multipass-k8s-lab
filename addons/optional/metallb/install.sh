#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

echo "[INFO] install optional addon: metallb"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
kubectl -n metallb-system rollout status deployment/controller --timeout=180s || true
echo "[INFO] applying local IPAddressPool and L2Advertisement config"
kubectl apply -f "${ROOT_DIR}/addons/values/metallb/ipaddresspool.yaml"
