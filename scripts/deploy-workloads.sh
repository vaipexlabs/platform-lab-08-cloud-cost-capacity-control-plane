#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

kubectl --context "${KUBE_CONTEXT}" apply --filename "${REPOSITORY_ROOT}/deploy/workloads"

for deployment in checkout-api report-generator; do
  kubectl --context "${KUBE_CONTEXT}" --namespace "${WORKLOAD_NAMESPACE}" \
    rollout status "deployment/${deployment}" --timeout=120s
done

echo "Contrasting capacity workloads are ready in ${WORKLOAD_NAMESPACE}."
