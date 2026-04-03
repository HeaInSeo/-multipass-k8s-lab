#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

echo "[INFO] uninstall optional addon: metallb"
kubectl delete -f "${ROOT_DIR}/addons/values/metallb/ipaddresspool.yaml" --ignore-not-found
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml --ignore-not-found
