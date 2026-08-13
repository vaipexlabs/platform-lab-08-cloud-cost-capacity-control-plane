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

kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  port-forward service/grafana 13000:80 >/dev/null 2>&1 &
port_forward_pid=$!

for _ in $(seq 1 45); do
  if curl --silent --fail http://127.0.0.1:13000/api/health >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

health="$(curl --silent --fail http://127.0.0.1:13000/api/health)"
if [[ "$(jq -r '.database' <<<"${health}")" != "ok" ]]; then
  echo "Grafana database health check failed." >&2
  exit 1
fi

dashboard_count="$(curl --silent --fail --user admin:vaipex-local \
  'http://127.0.0.1:13000/api/search?query=Vaipex%20Cloud%20Cost' | jq 'length')"
if (( dashboard_count < 1 )); then
  echo "The Vaipex cost-capacity dashboard was not provisioned." >&2
  exit 1
fi

echo "Verified Grafana ${GRAFANA_APP_VERSION} and the provisioned Vaipex dashboard."
