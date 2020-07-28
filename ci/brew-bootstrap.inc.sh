#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

HAS_BREW_2=true

if which brew >/dev/null 2>&1; then
    # using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
    # exe_and_grep_q "brew --version | head -1" "^Homebrew 2." || HAS_BREW_2=false
    exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 2\." || HAS_BREW_2=false
else
    echo_info "brew: Executable brew not found."
    HAS_BREW_2=false
fi

RAW_GUC_URL="https://raw.githubusercontent.com"

case $(uname -s) in
    Darwin)
        if [[ "${HAS_BREW_2}" = "true" ]]; then
            echo_do "brew: Updating homebrew..."
            brew update >/dev/null
            echo_done
        else
            echo_do "brew: Installing homebrew..."
            </dev/null /bin/bash -c "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/install.sh)"
            echo_done
        fi

        CI_CACHE_HOMEBREW_PREFIX=~/.homebrew
        ;;
    Linux)
        if [[ "${HAS_BREW_2}" = "true" ]]; then
            echo_do "brew: Updating linuxbrew..."
            brew update >/dev/null
            echo_done
        else
            echo_do "brew: Installing linuxbrew..."
            if [[ "${SUDO}" = "" ]] || [[ "${SUDO}" = "sf_nosudo" ]]; then
                HOMEBREW_PREFIX=~/.linuxbrew
                echo_do "brew: Installing without sudo into ${HOMEBREW_PREFIX}..."
                mkdir -p ${HOMEBREW_PREFIX}
                curl -fqsS -L https://github.com/Homebrew/brew/tarball/master | \
                    tar xz --strip 1 -C ${HOMEBREW_PREFIX}
                echo_done
            else
                </dev/null /bin/bash -c "$(curl -fqsS -L ${RAW_GUC_URL}/Homebrew/install/master/install.sh)"
            fi
            echo_done
        fi

        CI_CACHE_HOMEBREW_PREFIX=~/.linuxbrew
        ;;
    *)
        echo_err "brew: $(uname -s) is an unsupported OS."
        return 1
        ;;
esac
unset HAS_BREW_2
unset RAW_GUC_URL

source ${SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh

HOMEBREW_PREFIX=$(brew --prefix)
HOMEBREW_PREFIX_FULL=$(cd ${HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
CI_CACHE_HOMEBREW_PREFIX_FULL=$(cd ${CI_CACHE_HOMEBREW_PREFIX} 2>/dev/null && pwd || true)
[[ "${CI}" != "true" ]] || [[ "${HOMEBREW_PREFIX_FULL}" = "${CI_CACHE_HOMEBREW_PREFIX_FULL}" ]] || {
    echo_do "brew: Restoring cache..."
    if [[ -d "${CI_CACHE_HOMEBREW_PREFIX}/Homebrew" ]]; then
        echo_do "brew: Restoring ${HOMEBREW_PREFIX}/Homebrew..."
        RSYNC_CMD="rsync -a --delete ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew/ ${HOMEBREW_PREFIX}/Homebrew/"
        ${RSYNC_CMD} || {
            exe ls -la ${CI_CACHE_HOMEBREW_PREFIX}/Homebrew || true
            exe ls -la ${HOMEBREW_PREFIX}/Homebrew || true
            ${RSYNC_CMD} --verbose
        }
        unset RSYNC_CMD
        echo_done
    fi
    echo_done
}
unset CI_CACHE_HOMEBREW_PREFIX
unset CI_CACHE_HOMEBREW_PREFIX_FULL
unset HOMEBREW_PREFIX
unset HOMEBREW_PREFIX_FULL

[[ "${CI:-}" != "true" ]] || {
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-util.inc.sh
    brew_update
    source ${SUPPORT_FIRECLOUD_DIR}/ci/brew-install-ci.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
