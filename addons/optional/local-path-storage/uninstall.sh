#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] uninstall optional addon: local-path-storage"
kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml --ignore-not-found
