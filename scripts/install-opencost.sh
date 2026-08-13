#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

helm repo add opencost https://opencost.github.io/opencost-helm-chart \
  --force-update >/dev/null

echo "Installing OpenCost ${OPENCOST_APP_VERSION} from chart ${OPENCOST_CHART_VERSION}..."
helm upgrade --install opencost opencost/opencost \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace "${OPENCOST_NAMESPACE}" \
  --create-namespace \
  --version "${OPENCOST_CHART_VERSION}" \
  --values "${REPOSITORY_ROOT}/deploy/opencost/values.yaml" \
  --wait \
  --timeout 5m

kubectl --context "${KUBE_CONTEXT}" --namespace "${OPENCOST_NAMESPACE}" \
  rollout status deployment/opencost --timeout=180s

echo "OpenCost is ready with explicit local pricing."
