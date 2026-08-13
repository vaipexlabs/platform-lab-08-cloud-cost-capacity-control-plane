#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

"${SCRIPT_DIR}/verify-metrics.sh"
"${SCRIPT_DIR}/verify-workloads.sh"
"${SCRIPT_DIR}/verify-opencost.sh"
"${SCRIPT_DIR}/verify-grafana.sh"

echo "All live platform checks passed."
