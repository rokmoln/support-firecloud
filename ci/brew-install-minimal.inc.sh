#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing minimal packages..."
else
    echo_do "brew: Installing minimal packages..."
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-core.inc.sh
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-gnu.inc.sh

    # installing perl for performance reasons, since it takes a very long time to install via homebrew,
    # and quite a few formulas require it
    # NOTE: many formulas are optimized to use system's perl on Darwin, but not Linux
    case ${OS} in
        Darwin)
            brew_install perl
            ;;
        Linux)
            # TODO installing via apt as a workaround for
            # /usr/lib/gcc/x86_64-linux-gnu/9/include-fixed/bits/statx.h:38:25: error: missing binary operator before token "("
            # #if __glibc_has_include ("__linux__/stat.h")
            #                         ^
            apt_install perl
            ;;
    esac

    echo_done
fi
