#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

if ! kubectl --context "${KUBE_CONTEXT}" get namespace "${MONITORING_NAMESPACE}" >/dev/null 2>&1; then
  echo "The local cluster is not ready. Run ./scripts/create-cluster.sh first." >&2
  exit 1
fi

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts \
  --force-update >/dev/null

echo "Installing Prometheus ${PROMETHEUS_APP_VERSION} from chart ${PROMETHEUS_CHART_VERSION}..."
helm upgrade --install prometheus prometheus-community/prometheus \
  --kube-context "${KUBE_CONTEXT}" \
  --namespace "${MONITORING_NAMESPACE}" \
  --version "${PROMETHEUS_CHART_VERSION}" \
  --values "${REPOSITORY_ROOT}/deploy/prometheus/values.yaml" \
  --wait \
  --timeout 5m

kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  rollout status deployment/prometheus-server --timeout=120s >/dev/null
kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  rollout status deployment/prometheus-kube-state-metrics --timeout=120s >/dev/null
kubectl --context "${KUBE_CONTEXT}" --namespace "${MONITORING_NAMESPACE}" \
  rollout status daemonset/prometheus-prometheus-node-exporter --timeout=120s >/dev/null

echo "Prometheus metrics plane is ready."
