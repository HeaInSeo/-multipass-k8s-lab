#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] uninstall base addon: metrics-server"
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml --ignore-not-found
