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

query_has_data() {
  local expression="$1"
  local response
  response="$(curl --silent --get http://127.0.0.1:19090/api/v1/query \
    --data-urlencode "query=${expression}")"
  [[ "$(jq -r '.status' <<<"${response}")" == "success" ]] &&
    (( $(jq '.data.result | length' <<<"${response}") > 0 ))
}

kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  port-forward service/prometheus-server 19090:80 >/dev/null 2>&1 &
port_forward_pid=$!

for _ in $(seq 1 30); do
  if curl --silent --fail http://127.0.0.1:19090/-/ready >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl --silent --fail http://127.0.0.1:19090/-/ready >/dev/null; then
  echo "Prometheus did not become reachable on local port 19090." >&2
  exit 1
fi

source_names=(kube-state-metrics kubelet-cAdvisor node-exporter)
metrics=(kube_node_info container_cpu_usage_seconds_total node_uname_info)

for index in "${!source_names[@]}"; do
  source_name="${source_names[${index}]}"
  metric="${metrics[${index}]}"
  if ! query_has_data "${metric}"; then
    echo "Required ${source_name} metric has no data: ${metric}" >&2
    exit 1
  fi
  echo "Verified ${source_name}: ${metric}"
done

chart_label="$(helm --kube-context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  list --filter '^prometheus$' --output json | jq -r '.[0].chart')"
if [[ "${chart_label}" != "prometheus-${PROMETHEUS_CHART_VERSION}" ]]; then
  echo "Expected Prometheus chart ${PROMETHEUS_CHART_VERSION}; found ${chart_label}." >&2
  exit 1
fi

echo "Metrics verification passed: Prometheus ${PROMETHEUS_APP_VERSION}, chart ${PROMETHEUS_CHART_VERSION}."
