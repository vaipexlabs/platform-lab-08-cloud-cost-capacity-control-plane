#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=versions.env
source "${REPOSITORY_ROOT}/versions.env"

required_commands=(curl docker helm jq kind kubectl)
for required_command in "${required_commands[@]}"; do
  if ! command -v "${required_command}" >/dev/null 2>&1; then
    echo "Required command not found: ${required_command}" >&2
    exit 1
  fi
done

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start Docker Desktop and try again." >&2
  exit 1
fi

installed_kind_version="$(kind version | awk '{print $2}')"
if [[ "${installed_kind_version}" != "${KIND_VERSION}" ]]; then
  echo "kind ${KIND_VERSION} is required; found ${installed_kind_version}." >&2
  exit 1
fi

echo "Preflight passed: Docker, kind ${KIND_VERSION}, kubectl, Helm, curl, and jq are available."
