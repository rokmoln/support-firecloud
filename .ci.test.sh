#!/usr/bin/env bash

SF_DOCKER_CI_IMAGE=false

function ci_run_before_deploy() {
    true
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
