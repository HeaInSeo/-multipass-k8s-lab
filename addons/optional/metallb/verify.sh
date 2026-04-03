#!/usr/bin/env bash
set -euo pipefail

echo "== metallb =="
kubectl -n metallb-system get deployment controller >/dev/null 2>&1 && \
  kubectl -n metallb-system get deployment controller || \
  echo "metallb not installed"
