#!/usr/bin/env bash
set -euo pipefail

GIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "${GIT_ROOT}/support-firecloud" && pwd)"

SRC_FILE=.github/workflows.src/main.yml

# ci
ENVSUBST_WSLENV=CI:V
# support-firecloud
ENVSUBST_WSLENV=${ENVSUBST_WSLENV}:SF_LOG_BOOTSTRAP:SF_PRINTENV_BOOTSTRAP
# github
ENVSUBST_WSLENV=${ENVSUBST_WSLENV}:GH_TOKEN:GH_USERNAME
# transcrypt
ENVSUBST_WSLENV=${ENVSUBST_WSLENV}:TRANSCRYPT_PASSWORD
# slack
ENVSUBST_WSLENV=${ENVSUBST_WSLENV}:SLACK_WEBHOOK:SLACK_CHANNEL:CI_STATUS
# custom
ENVSUBST_WSLENV=${ENVSUBST_WSLENV}:SF_CI_BREW_INSTALL
export ENVSUBST_WSLENV

echo "# WARNING: DO NOT EDIT. AUTO-GENERATED CODE (${SRC_FILE})"
cat ${GIT_ROOT}/${SRC_FILE} | \
  envsubst "$(printenv | grep "^ENVSUBST_" | sed "s/=.*//g" | sed "s/^/\${/g" | sed "s/\$/}/g")" | \
  ${SUPPORT_FIRECLOUD_DIR}/bin/yaml-expand
