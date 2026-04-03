#!/usr/bin/env bash
set -euo pipefail

echo "== metrics-server =="
kubectl -n kube-system get deployment metrics-server >/dev/null 2>&1 && \
  kubectl -n kube-system get deployment metrics-server || \
  echo "metrics-server not installed"
