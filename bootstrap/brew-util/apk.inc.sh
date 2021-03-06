#!/usr/bin/env bash
set -euo pipefail

# apk-* functions are not related to brew,
# but they are here for convenience, to make them available in Brewfile.inc.sh files

function apk_update() {
    ${SF_SUDO} apk update
}

function apk_install_one() {
    local PKG="$*"

    echo_do "apk: Installing ${PKG}..."
    ${SF_SUDO} apk add --no-cache ${PKG}
    echo_done
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function apk_install_one_if() {
    local FORMULA="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "apk: Installing ${FORMULA}..."
    else
        apk_install_one "${FORMULA}"
        >&2 exe_debug "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
