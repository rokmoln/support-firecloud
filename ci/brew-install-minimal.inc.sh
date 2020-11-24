#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing minimal packages..."
else
    echo_do "brew: Installing minimal packages..."
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-core.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-gnu.inc.sh

    echo_done
fi
