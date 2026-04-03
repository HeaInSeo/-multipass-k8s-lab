#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] install base addon: metrics-server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s || true
