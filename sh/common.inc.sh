#!/usr/bin/env bash
set -euo pipefail

if [ -z "${BASH_VERSINFO}" ] || [ -z "${BASH_VERSINFO[0]}" ] || [ ${BASH_VERSINFO[0]} -lt 4 ]; then
    echo >&2 "Your Bash version is ${BASH_VERSINFO[0]}. ${0} requires >= 4.";
    exit 1;
fi

export SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source ${SUPPORT_FIRECLOUD_DIR}/sh/core.inc.sh
source ${SUPPORT_FIRECLOUD_DIR}/sh/exe.inc.sh
