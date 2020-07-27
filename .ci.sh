#!/usr/bin/env bash

# SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/support-firecloud" && pwd)"
SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

TRAVIS_BUILD_STAGE_NAME=${TRAVIS_BUILD_STAGE_NAME:-test}
TRAVIS_BUILD_STAGE_NAME_LOWER=$(echo "${TRAVIS_BUILD_STAGE_NAME}" | tr "[:upper:]" "[:lower:]")
source .ci.${TRAVIS_BUILD_STAGE_NAME_LOWER}.sh
