#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-util.inc.sh

function bootstrap_has_brew() {
    if which brew >/dev/null 2>&1; then
        # using tail or else broken pipe. see https://github.com/Homebrew/homebrew-cask/issues/36218
        # exe_and_grep_q "brew --version | head -1" "^Homebrew 2." || return 1
        exe_and_grep_q "brew --version | tail -n+1 | head -1" "^Homebrew 2\." || return 1
    else
        echo_info "brew: Executable brew not found."
        return 1
    fi
}

function bootstrap_brew() {
    local RAW_GUC_URL="https://raw.githubusercontent.com"
    local BREWFILE_LOCK=${GIT_ROOT}/Brewfile.lock
    local BREW_GITREF=master
    local BREW_INSTALL_GITREF=master
    [[ ! -f ${BREWFILE_LOCK} ]] || {
        local BREW_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/brew " || true)
        local BREW_GITREF=$(echo "${BREW_LOCK}" | cut -d" " -f2)

        local BREW_INSTALL_LOCK=$(cat "${BREWFILE_LOCK}" | grep "^homebrew/install " || true)
        local BREW_INSTALL_GITREF=$(echo "${BREW_INSTALL_LOCK}" | cut -d" " -f2)
    }
    local BREW_INSTALL_URL=${RAW_GUC_URL}/Homebrew/install/${BREW_INSTALL_GITREF}

    [[ "${CI}" != "true" ]] || {
        if which brew >/dev/null 2>&1; then
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_skip "brew: Uninstalling homebrew..."
            else
                echo_do "brew: Uninstalling homebrew..."
                </dev/null /bin/bash -c "$(curl -fqsS -L ${BREW_INSTALL_URL}/uninstall.sh)"
                echo_done
                hash -r
            fi
        fi
    }

    local HAS_BREW_2=true
    bootstrap_has_brew || HAS_BREW_2=false

    case ${HAS_BREW_2}-$(uname -s) in
        false-Darwin)
            echo_do "brew: Installing homebrew..."
            </dev/null /bin/bash -c "$(curl -fqsS -L ${BREW_INSTALL_URL}/install.sh)"
            echo_done
            ;;
        true-Darwin)
            brew_config
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
                echo_skip "brew: Updating homebrew..."
            else
                echo_do "brew: Updating homebrew..."

                [[ ${GITHUB_ACTIONS:=} != "true" ]] || {
                    # see https://github.com/actions/virtual-environments/issues/1811#issuecomment-713862592
                    for BREW_TAP in $(brew tap | grep "^local/"); do
                        brew untap "${BREW_TAP}"
                    done
                }

                brew update >/dev/null
                echo_done
            fi
            ;;
        false-Linux)
            echo_do "brew: Installing homebrew..."
            if [[ "${SUDO}" = "" ]] || [[ "${SUDO}" = "sf_nosudo" ]]; then
                HOMEBREW_PREFIX=${HOME}/.linuxbrew
                echo_do "brew: Installing without sudo into ${HOMEBREW_PREFIX}..."
                mkdir -p ${HOMEBREW_PREFIX}
                curl -fqsS -L https://github.com/Homebrew/brew/tarball/${BREW_GITREF} | \
                    tar xz --strip 1 -C ${HOMEBREW_PREFIX}
                echo_done
            else
                export SUDO_ASKPASS=false
                </dev/null /bin/bash -c "$(curl -fqsS -L ${BREW_INSTALL_URL}/install.sh)"
            fi
            echo_done
            ;;
        true-Linux)
            brew_config
            if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
                echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
                echo_skip "brew: Updating homebrew..."
            else
                echo_do "brew: Updating homebrew..."
                brew update >/dev/null
                echo_done
            fi
            ;;
        *)
            echo_err "brew: $(uname -s) is an unsupported OS."
            return 1
            ;;
    esac
}

bootstrap_brew
source ${SUPPORT_FIRECLOUD_DIR}/sh/exe-env.inc.sh

[[ "${CI}" != "true" ]] || {
    brew_config
    [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]] || {
        if [[ -f ${GIT_ROOT}/Brewfile.lock ]]; then
            brew_lockfile
        else
            brew_update
        fi
    }
    source ${SUPPORT_FIRECLOUD_DIR}/bootstrap/brew-install-ci.inc.sh
}

source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh
