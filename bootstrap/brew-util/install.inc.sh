#!/usr/bin/env bash
set -euo pipefail

function brew_install_one_patched() {
    local FORMULA="$*"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
    local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

    local DIR=${GIT_ROOT}/Formula/patch-lib
    mkdir -p ${DIR}

    local PATCH=${GIT_ROOT}/Formula/${NAME}.${OS_SHORT}.patch
    local ORIGINAL=${DIR}/${NAME}.original.rb
    local PATCHED=${DIR}/${NAME}.rb

    echo_do "brew: Patching ${NAME} with ${PATCH} as ${PATCHED}..."
    brew cat ${NAME} > ${ORIGINAL}
    patch ${ORIGINAL} ${PATCH} -o ${PATCHED} || {
        cat ${PATCHED}.rej
        exit 1
    }
    echo_done

    echo_do "brew: Installing ${NAME} from ${PATCHED}..."
    set -x
    which -a brew
    cat ${PATCHED}
    brew_install_one_core ${PATCHED} ${OPTIONS}
    echo_done
}

function brew_install_one_core() {
    local FORMULA="$*"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
    local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

    # is it already installed ?
    if brew list "${NAME}" >/dev/null 2>&1; then
        # is it a url/path to a formula.rb file
        [[ "${FULLNAME}" = "${FULLNAME%.rb}" ]] || {
            brew uninstall ${NAME}

            echo_do "brew: Installing ${FORMULA}..."
            if [[ "${CI:-}" != "true" ]]; then
                brew install ${FORMULA}
            else
                brew install --force ${FORMULA} || brew link --force --overwrite ${NAME}
            fi
            brew info --json=v1 ${NAME} | \
                ${SUPPORT_FIRECLOUD_DIR}/bin/jq -r ".[0].linked_keg" | \
                grep -q -v "^null$" || \
                brew link --force --overwrite ${NAME}
            echo_done

            return 0
        }

        # install without specific options ?
        [[ -n "${OPTIONS}" ]] || {
            # NOTE true when up-to-date, false otherwise
            if brew outdated ${NAME} >/dev/null; then
                echo_skip "brew: Installing ${FORMULA}..."
                return 0
            else
                brew uninstall --ignore-dependencies ${NAME}
            fi
        }

        # is it already installed with the required options ?
        local USED_OPTIONS="$(brew info --json=v1 ${NAME} | \
            ${SUPPORT_FIRECLOUD_DIR}/bin/jq -r ".[0].installed[0].used_options" | \
            xargs -n 1 | \
            sort -u || true)"
        local NOT_FOUND_OPTIONS="$(comm -23 <(echo "${OPTIONS}") <(echo "${USED_OPTIONS}"))"
        [[ -n "${NOT_FOUND_OPTIONS}" ]] || {
            # NOTE true when up-to-date, false otherwise
            if brew outdated ${NAME} >/dev/null; then
                echo_skip "brew: Installing ${FORMULA}..."
                return 0
            else
                brew uninstall --ignore-dependencies ${NAME}
            fi
        }

        echo_err "${NAME} is already installed with options '${USED_OPTIONS}',"
        echo_err "but not the required '${NOT_FOUND_OPTIONS}'."

        if [[ "${TRAVIS:-}" = "true" ]]; then
            brew uninstall --ignore-dependencies ${NAME}
        else
            echo_err "Consider uninstalling ${NAME} with 'brew uninstall ${NAME}' and rerun the bootstrap!"
            return 1
        fi
    fi

    echo_do "brew: Installing ${FORMULA}..."
    brew install ${FORMULA}
    brew info --json=v1 ${NAME} | \
        ${SUPPORT_FIRECLOUD_DIR}/bin/jq -r ".[0].linked_keg" | \
        grep -q -v "^null$" || \
        brew link --force --overwrite ${NAME}
    echo_done
}

function brew_install_one() {
    local FORMULA="$*"

    local FULLNAME=$(echo "${FORMULA}" | cut -d " " -f 1)
    local NAME=$(basename "${FULLNAME}" | sed "s/\.rb\$//")
    # local OPTIONS=$(echo "${FORMULA} " | cut -d " " -f 2- | xargs -n 1 | sort -u)

    # if we have a patch file, then use it to install the formula
    [[ ! -f Formula/${NAME}.${OS_SHORT}.patch ]] || {
        brew_install_one_patched "$@"
        hash -r # see https://github.com/Homebrew/brew/issues/5013
        return 0
    }

    brew_install_one_core "${FORMULA}"
    hash -r # see https://github.com/Homebrew/brew/issues/5013
}

function brew_install_one_if() {
    local FORMULA="$1"
    shift
    local EXECUTABLE=$(echo "$1" | cut -d" " -f1)

    if exe_and_grep_q "$@"; then
        echo_skip "brew: Installing ${FORMULA}..."
    else
        brew_install_one "${FORMULA}"
        >&2 exe_debug "${EXECUTABLE}"
        exe_and_grep_q "$@"
    fi
}
