#!/usr/bin/env bash
set -euo pipefail
set -x

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

SRC_FILE=.github/workflows.src/main.yml

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE})"
cat ${SUPPORT_FIRECLOUD_DIR}/${SRC_FILE} | ${SUPPORT_FIRECLOUD_DIR}/bin/yaml-expand
