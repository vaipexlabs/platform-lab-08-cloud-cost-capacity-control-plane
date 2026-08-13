#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

"${SCRIPT_DIR}/create-cluster.sh"
"${SCRIPT_DIR}/install-prometheus.sh"
"${SCRIPT_DIR}/verify-metrics.sh"

echo "Vaipex Cloud Cost & Capacity metrics plane is ready."
