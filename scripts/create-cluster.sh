#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

"${SCRIPT_DIR}/preflight.sh"

if kind get clusters | grep -Fx -- "${CLUSTER_NAME}" >/dev/null; then
  echo "Cluster ${CLUSTER_NAME} already exists; reusing it."
else
  echo "Creating ${CLUSTER_NAME} with Kubernetes ${KUBERNETES_VERSION}..."
  kind create cluster \
    --name "${CLUSTER_NAME}" \
    --image "${KIND_NODE_IMAGE}" \
    --config "${REPOSITORY_ROOT}/kind/cluster.yaml" \
    --wait 120s
fi

kubectl --context "${KUBE_CONTEXT}" wait \
  --for=condition=Ready node --all --timeout=120s
kubectl --context "${KUBE_CONTEXT}" apply \
  --filename "${REPOSITORY_ROOT}/bootstrap/namespaces.yaml"

echo "Cluster ${CLUSTER_NAME} is ready."
