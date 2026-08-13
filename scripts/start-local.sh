#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

"${SCRIPT_DIR}/create-cluster.sh"
"${SCRIPT_DIR}/install-prometheus.sh"
"${SCRIPT_DIR}/verify-metrics.sh"
"${SCRIPT_DIR}/deploy-workloads.sh"
"${SCRIPT_DIR}/verify-workloads.sh"

echo "Vaipex Cloud Cost & Capacity local platform is ready."
