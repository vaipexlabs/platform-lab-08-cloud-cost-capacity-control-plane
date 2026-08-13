#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

helm repo add grafana-community https://grafana-community.github.io/helm-charts \
  --force-update >/dev/null
kubectl --context "${KUBE_CONTEXT}" apply --filename "${REPOSITORY_ROOT}/deploy/grafana/datasource.yaml"
kubectl --context "${KUBE_CONTEXT}" apply --filename "${REPOSITORY_ROOT}/deploy/grafana/dashboard.yaml"

echo "Installing Grafana ${GRAFANA_APP_VERSION} from chart ${GRAFANA_CHART_VERSION}..."
helm upgrade --install grafana grafana-community/grafana \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace "${MONITORING_NAMESPACE}" \
  --version "${GRAFANA_CHART_VERSION}" \
  --values "${REPOSITORY_ROOT}/deploy/grafana/values.yaml" \
  --wait \
  --timeout 5m

kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  rollout status deployment/grafana --timeout=180s

echo "Grafana dashboard is provisioned."
