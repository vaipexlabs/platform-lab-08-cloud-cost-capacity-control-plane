#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

assert_value() {
  local actual="$1"
  local expected="$2"
  local description="$3"

  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected ${description} to be ${expected}; found ${actual}." >&2
    exit 1
  fi
}

assert_value "$(kubectl --context "${KUBE_CONTEXT}" --namespace "${WORKLOAD_NAMESPACE}" \
  get deployment checkout-api --output jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')" \
  "100m" "checkout-api CPU request"
assert_value "$(kubectl --context "${KUBE_CONTEXT}" --namespace "${WORKLOAD_NAMESPACE}" \
  get deployment report-generator --output jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}')" \
  "500m" "report-generator CPU request"

for deployment in checkout-api report-generator; do
  available="$(kubectl --context "${KUBE_CONTEXT}" --namespace "${WORKLOAD_NAMESPACE}" \
    get deployment "${deployment}" --output jsonpath='{.status.availableReplicas}')"
  assert_value "${available}" "1" "${deployment} available replicas"

  owner="$(kubectl --context "${KUBE_CONTEXT}" --namespace "${WORKLOAD_NAMESPACE}" \
    get deployment "${deployment}" --output jsonpath='{.metadata.labels.vaipex\.io/owner}')"
  if [[ -z "${owner}" ]]; then
    echo "Deployment ${deployment} has no vaipex.io/owner label." >&2
    exit 1
  fi
  echo "Verified ${deployment}: ready, owned by ${owner}."
done

echo "Workload verification passed: 100m active profile versus 500m idle profile."
