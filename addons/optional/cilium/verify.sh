#!/usr/bin/env bash
# addons/optional/cilium/verify.sh
set -euo pipefail

CILIUM_NS="${CILIUM_NS:-kube-system}"
PASS=0
FAIL=0

check() {
  local label="$1"; shift
  if eval "$@" >/dev/null 2>&1; then
    echo "  [OK]  ${label}"
    PASS=$((PASS + 1))
  else
    echo "  [NG]  ${label}"
    FAIL=$((FAIL + 1))
  fi
}

echo "== cilium =="

check "cilium DaemonSet exists" \
  "kubectl -n ${CILIUM_NS} get ds cilium"

check "cilium-operator Deployment exists" \
  "kubectl -n ${CILIUM_NS} get deployment cilium-operator"

check "all cilium pods Running" \
  "kubectl -n ${CILIUM_NS} get pods -l k8s-app=cilium --field-selector=status.phase!=Running 2>/dev/null | grep -q 'No resources'"

check "Gateway API GatewayClass cilium registered" \
  "kubectl get gatewayclass cilium"

check "CiliumLoadBalancerIPPool exists" \
  "kubectl get ciliumloadbalancerippools.cilium.io lab-default-pool"

check "CiliumL2AnnouncementPolicy exists" \
  "kubectl get ciliuml2announcementpolicies.cilium.io lab-default-l2"

echo ""
echo "  PASS: ${PASS}  FAIL: ${FAIL}"
[[ "$FAIL" -eq 0 ]]
