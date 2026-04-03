#!/usr/bin/env bash
set -euo pipefail

if [[ "${FORCE:-0}" != "1" ]]; then
  echo "FORCE=1 is required to proceed" >&2
  exit 1
fi

echo "=== Remove Multipass and optional CLI tools ==="
if command -v snap >/dev/null 2>&1; then
  sudo snap remove multipass || true
  sudo snap remove kubectl || true
  sudo snap remove helm || true
  sudo systemctl disable --now snapd.socket || true
  sudo dnf -y remove snapd || true
  sudo rm -rf /var/lib/snapd /var/cache/snapd || true
fi

echo "=== Remove OpenTofu ==="
if command -v tofu >/dev/null 2>&1; then
  sudo dnf -y remove tofu || true
fi

echo "=== Remove local repo state ==="
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
rm -rf "${ROOT_DIR}/.terraform" "${ROOT_DIR}/.terraform.lock.hcl" \
       "${ROOT_DIR}"/terraform.tfstate* "${ROOT_DIR}"/tofu.tfstate* "${ROOT_DIR}/tofu.tfstate.d" \
       "${ROOT_DIR}/kubeconfig" || true

echo "Cleanup completed"
