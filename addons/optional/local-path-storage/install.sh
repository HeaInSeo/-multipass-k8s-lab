#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] install optional addon: local-path-storage"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl -n local-path-storage rollout status deployment/local-path-provisioner --timeout=180s || true
