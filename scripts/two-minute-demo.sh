#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

echo "Vaipex Cloud Cost & Capacity Control Plane"
echo "=========================================="
echo
echo "1/3 Build or reconcile the local control plane"
"${SCRIPT_DIR}/start-local.sh"

echo
echo "2/3 Show cost, capacity, ownership, and review signals"
"${SCRIPT_DIR}/show-cost-capacity.sh"

echo
echo "3/3 Explore the interfaces"
echo "Grafana:  kubectl --context kind-vaipex-cost-capacity --namespace monitoring port-forward service/grafana 3000:80"
echo "          http://localhost:3000  (admin / vaipex-local)"
echo "OpenCost: kubectl --context kind-vaipex-cost-capacity --namespace opencost port-forward service/opencost 19090:9090"
echo "          http://localhost:19090"
echo
echo "Cleanup:  ./scripts/stop-local.sh"
