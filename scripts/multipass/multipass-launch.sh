#!/usr/bin/env bash
set -euo pipefail

name="${1:?name required}"
image="${2:?image required}"
mem="${3:?mem required}"
disk="${4:?disk required}"
cpus="${5:?cpus required}"
cloud_init="${6:?cloud-init path required}"

RECREATE_ON_DIFF="${RECREATE_ON_DIFF:-0}"

die() { echo "[ERR] $*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "$1 not found"
}

need_cmd multipass
need_cmd awk
need_cmd head
need_cmd realpath

size_to_mib() {
  local s="${1//[[:space:]]/}"
  awk -v s="$s" '
    function factor(u) {
      if (u=="MiB") return 1
      if (u=="GiB") return 1024
      if (u=="KiB") return 1/1024
      if (u=="MB") return 1
      if (u=="GB") return 1024
      return -1
    }
    BEGIN {
      if (match(s, /^([0-9]+)(M|G)$/, a)) {
        num = a[1] + 0
        unit = a[2]
        mib = (unit=="G") ? num*1024 : num
        printf "%.0f", mib
        exit 0
      }
      if (match(s, /^([0-9]+(\.[0-9]+)?)(KiB|MiB|GiB|MB|GB)$/, a)) {
        num = a[1] + 0
        unit = a[3]
        f = factor(unit)
        if (f < 0) exit 2
        mib = num * f
        printf "%.0f", mib
        exit 0
      }
      exit 2
    }'
}

cloud_init_abs="$(realpath "$cloud_init")"

if ! head -n 1 "$cloud_init_abs" | grep -q '^#cloud-config'; then
  die "cloud-init file must start with '#cloud-config': $cloud_init_abs"
fi

if [[ "$cloud_init_abs" != "$HOME/"* ]]; then
  cache_dir="${HOME}/.cache/multipass-cloud-init"
  mkdir -p "$cache_dir"
  chmod 700 "$cache_dir"

  if command -v sha256sum >/dev/null 2>&1; then
    digest="$(sha256sum "$cloud_init_abs" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    digest="$(shasum -a 256 "$cloud_init_abs" | awk '{print $1}')"
  else
    digest="$(date +%s)"
  fi

  cached="${cache_dir}/$(basename "$cloud_init_abs").${digest}.yaml"
  cp -f "$cloud_init_abs" "$cached"
  chmod 644 "$cached"
  cloud_init_abs="$cached"
fi

if multipass info "$name" >/dev/null 2>&1; then
  if [[ "$RECREATE_ON_DIFF" != "1" ]]; then
    echo "[INFO] $name already exists; waiting for cloud-init completion"
    multipass exec "$name" -- bash -lc 'command -v cloud-init >/dev/null && sudo cloud-init status --wait || true'
    exit 0
  fi

  have_cpus="$(multipass get "local.${name}.cpus" | tr -d '\r')"
  have_mem="$(multipass get "local.${name}.memory" | tr -d '\r')"
  have_disk="$(multipass get "local.${name}.disk" | tr -d '\r')"

  want_mem_mib="$(size_to_mib "$mem")" || die "invalid mem format: $mem"
  want_disk_mib="$(size_to_mib "$disk")" || die "invalid disk format: $disk"
  have_mem_mib="$(size_to_mib "$have_mem")" || die "cannot parse current memory: $have_mem"
  have_disk_mib="$(size_to_mib "$have_disk")" || die "cannot parse current disk: $have_disk"

  diff=0
  [[ "$have_cpus" == "$cpus" ]] || diff=1
  [[ "$have_mem_mib" == "$want_mem_mib" ]] || diff=1
  [[ "$have_disk_mib" == "$want_disk_mib" ]] || diff=1

  if [[ "$diff" != "1" ]]; then
    echo "[INFO] $name exists and matches spec; waiting for cloud-init completion"
    multipass exec "$name" -- bash -lc 'command -v cloud-init >/dev/null && sudo cloud-init status --wait || true'
    exit 0
  fi

  echo "[INFO] $name spec differs; recreating"
  multipass delete --purge "$name"
fi

echo "[INFO] launching $name"
multipass launch --timeout 1800 "$image" \
  --name "$name" \
  --memory "$mem" \
  --disk "$disk" \
  --cpus "$cpus" \
  --cloud-init "$cloud_init_abs"

echo "[INFO] waiting for cloud-init to finish on $name"
multipass exec "$name" -- bash -lc 'command -v cloud-init >/dev/null && sudo cloud-init status --wait || true'
echo "[OK] launched $name"
