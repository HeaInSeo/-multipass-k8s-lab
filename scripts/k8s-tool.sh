#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="${TOOL:-tofu}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-${ROOT_DIR}/kubeconfig}"

if [[ -f "$KUBECONFIG_PATH" ]]; then
  export KUBECONFIG="$KUBECONFIG_PATH"
fi

usage() {
  cat <<'USAGE'
Usage: scripts/k8s-tool.sh <command> [args]

Commands:
  host-setup                         Install or verify host prerequisites
  host-cleanup                       Remove host-installed tools (requires FORCE=1)
  up                                 Create VMs and bootstrap the baseline cluster
  down                               Destroy VMs and OpenTofu-managed resources
  status                             Show cluster or VM status
  clean                              Remove local state files (requires FORCE=1)
  addons-install <base|optional> [name]
  addons-uninstall <base|optional> [name]
  addons-verify

Env:
  TOOL=tofu|terraform
  KUBECONFIG_PATH=/path/to/kubeconfig
  FORCE=1
USAGE
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing: $1" >&2
    exit 1
  }
}

cmd="${1:-}"
if [[ -z "$cmd" ]]; then
  usage
  exit 1
fi

shift || true

case "$cmd" in
  host-setup)
    bash "${ROOT_DIR}/scripts/host/setup-host-rocky8.sh"
    ;;
  host-cleanup)
    bash "${ROOT_DIR}/scripts/host/cleanup-host-rocky8.sh"
    ;;
  up)
    need_cmd "$TOOL"
    (
      cd "${ROOT_DIR}"
      "$TOOL" init
      "$TOOL" plan
      "$TOOL" apply -auto-approve
    )
    ;;
  down)
    need_cmd "$TOOL"
    (
      cd "${ROOT_DIR}"
      "$TOOL" destroy -auto-approve
    )
    ;;
  status)
    if [[ -f "$KUBECONFIG_PATH" ]] && command -v kubectl >/dev/null 2>&1; then
      export KUBECONFIG="$KUBECONFIG_PATH"
      echo "== Nodes =="
      kubectl get nodes -o wide || true
      echo
      echo "== Pods =="
      kubectl get pods -A -o wide || true
    elif command -v multipass >/dev/null 2>&1; then
      multipass list || true
    else
      echo "kubectl or multipass not found" >&2
      exit 1
    fi
    ;;
  clean)
    if [[ "${FORCE:-0}" != "1" ]]; then
      echo "FORCE=1 is required to clean local state files" >&2
      exit 1
    fi
    (
      cd "${ROOT_DIR}"
      rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tofu.tfstate* tofu.tfstate.d
      rm -f "$KUBECONFIG_PATH"
    )
    ;;
  addons-install)
    bash "${ROOT_DIR}/addons/manage.sh" install "$@"
    ;;
  addons-uninstall)
    bash "${ROOT_DIR}/addons/manage.sh" uninstall "$@"
    ;;
  addons-verify)
    bash "${ROOT_DIR}/addons/manage.sh" verify
    ;;
  *)
    usage
    exit 1
    ;;
esac
