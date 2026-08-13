#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

port_forward_pid=""
cleanup() {
  if [[ -n "${port_forward_pid}" ]]; then
    kill "${port_forward_pid}" >/dev/null 2>&1 || true
    wait "${port_forward_pid}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

kubectl --context "${KUBE_CONTEXT}" --namespace "${OPENCOST_NAMESPACE}" \
  port-forward service/opencost 19003:9003 >/dev/null 2>&1 &
port_forward_pid=$!

for _ in $(seq 1 30); do
  if curl --silent --fail http://127.0.0.1:19003/healthz >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

allocation=""
row_count=0
for _ in $(seq 1 30); do
  allocation="$(curl --silent --fail --get \
    http://127.0.0.1:19003/allocation/compute \
    --data-urlencode 'window=15m' \
    --data-urlencode 'aggregate=pod' \
    --data-urlencode "filter=namespace:\"${WORKLOAD_NAMESPACE}\"")"
  row_count="$(jq '[.data[0][]] | length' <<<"${allocation}")"
  if (( row_count >= 2 )); then
    break
  fi
  sleep 2
done

if [[ "$(jq -r '.code' <<<"${allocation}")" != "200" ]]; then
  echo "OpenCost allocation API did not return a successful response." >&2
  exit 1
fi

if (( row_count < 2 )); then
  echo "Expected allocations for two demo workloads; found ${row_count}." >&2
  exit 1
fi

{
  printf 'SERVICE\tOWNER\tENV\tCPU REQUEST\tCPU USED\tCPU EFF\tMEM REQUEST\tMEM USED\tUSD/HOUR\tRECOMMENDATION\n'
  jq --raw-output '
    def percent: ((. * 1000 | round) / 10 | tostring) + "%";
    def mib: ((. / 1048576 * 10 | round) / 10 | tostring) + " MiB";
    def recommendation:
      if .cpuEfficiency < 0.10 and .ramEfficiency < 0.20 then
        "Review lower requests: CPU and memory utilization are low"
      elif .cpuEfficiency > 0.80 or .ramEfficiency > 0.80 then
        "Review headroom: one or more resources exceed 80% of request"
      else
        "Observe: no threshold-based capacity review"
      end;
    .data[0][] |
    [
      .properties.labels.app_kubernetes_io_name,
      .properties.labels.vaipex_io_owner,
      .properties.labels.app_kubernetes_io_environment,
      ((.cpuCoreRequestAverage * 1000 | round | tostring) + "m"),
      ((.cpuCoreUsageAverage * 1000 | round | tostring) + "m"),
      (.cpuEfficiency | percent),
      (.ramByteRequestAverage | mib),
      (.ramByteUsageAverage | mib),
      (if .minutes > 0 then (.totalCost * 60 / .minutes * 1000000 | round) / 1000000 else 0 end | tostring),
      recommendation
    ] | @tsv
  ' <<<"${allocation}"
} | column -t -s $'\t'

echo
echo "Dimensions: service, owner/team, namespace=${WORKLOAD_NAMESPACE}, environment, and cost center."
echo "Recommendations are review signals only; this project never changes workload resources."
