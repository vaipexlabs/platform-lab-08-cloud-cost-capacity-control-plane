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

for _ in $(seq 1 45); do
  if curl --silent --fail http://127.0.0.1:19003/healthz >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl --silent --fail http://127.0.0.1:19003/healthz >/dev/null; then
  echo "OpenCost API did not become reachable on local port 19003." >&2
  exit 1
fi

cpu_price="$(kubectl --context "${KUBE_CONTEXT}" --namespace "${OPENCOST_NAMESPACE}" \
  get configmap custom-pricing-model --output jsonpath='{.data.CPU}')"
ram_price="$(kubectl --context "${KUBE_CONTEXT}" --namespace "${OPENCOST_NAMESPACE}" \
  get configmap custom-pricing-model --output jsonpath='{.data.RAM}')"
if [[ "${cpu_price}" != "0.04" ]] || [[ "${ram_price}" != "0.005" ]]; then
  echo "OpenCost custom CPU or RAM pricing does not match the declared assumptions." >&2
  exit 1
fi

allocation="$(curl --silent --fail --get \
  http://127.0.0.1:19003/allocation/compute \
  --data-urlencode 'window=15m' \
  --data-urlencode 'aggregate=pod' \
  --data-urlencode 'includeIdle=true')"

if [[ "$(jq -r '.code' <<<"${allocation}")" != "200" ]]; then
  echo "OpenCost allocation API did not return a successful response." >&2
  jq . <<<"${allocation}" >&2
  exit 1
fi

echo "Verified OpenCost pricing: USD 0.04/core-hour and USD 0.005/GiB-hour."
echo "Verified OpenCost allocation API for the local cluster."
