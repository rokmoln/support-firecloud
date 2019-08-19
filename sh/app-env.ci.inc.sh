#!/usr/bin/env bash

function ci_run_script_env_git() {
    make snapshot
    make dist

    # copying dist/app.zip elsewhere or else it gets deleted by
    # ci_run_script_provision: webapp_reset_to_snapshot
    export LOCAL_DIST_APP_ZIP=$(mktemp -t $(basename $(pwd)).XXXXXXXXXX)
    mv dist/app.zip ${LOCAL_DIST_APP_ZIP}

    ${GIT_ROOT}/bin/provision-env
    [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
}


function ci_run_script_env() {
    PKG_VSN=$(cat package.json | json "version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    # Cron jobs should just run tests (skip provision)
    if [[ "${CI_IS_CRON}" = "true" ]]; then
        ${GIT_ROOT}/bin/get-snapshot
        make reset-to-snapshot
        [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
        return 0
    fi

    ${GIT_ROOT}/bin/provision-env
    [[ ! -f ${GIT_ROOT}/bin/test-env ]] || ${GIT_ROOT}/bin/test-env
}


function ci_run_install() {
    true
}


function ci_run_script_teardown_env() {
    ${GIT_ROOT}/bin/teardown-env
}


function ci_run_script() {
    # handle PRs
    [[ "${CI_IS_PR}" != "true" ]] || {
        sf_ci_run_script
        return 0
    }

    # handle teardown
    local ENV_NAME=${ENV_NAME:-$(${GIT_ROOT}/bin/get-env-name)}
    local TEARDOWN_PATTERN="^\[TEARDOWN-ENV ${ENV_NAME}\]"
    if [[ $(git log --format=%s -n1) =~ ${TEARDOWN_PATTERN} ]] ; then
        ci_run_script_teardown_env
        return 0
    fi

    case ${GIT_BRANCH} in
        # handle env branches
        env/*)
            ci_run_script_env
            return 0
            ;;
        # handle git-env branches
        master|*-env)
            sf_ci_run_script
            ci_run_script_env_git
            return 0
            ;;
    esac

    sf_ci_run_script
}

function ci_run_deploy() {
    PKG_VSN=$(cat package.json | json "version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    local ASSETS=${ASSETS:-$(ls dist/app.zip snapshot.zip)}

    echo_info "Assets for release:"
    echo "${ASSETS}" | xargs ls -l

    local ASSETS_ARGS=$(
        echo "${ASSETS}" | \
        xargs -I {} echo "--asset {}"
    )
    ${SUPPORT_FIRECLOUD_DIR}/bin/github-create-release \
        --repo-slug ${CI_REPO_SLUG} \
        --tag "v${PKG_VSN}" \
        --target $(git rev-parse HEAD) \
        ${ASSETS_ARGS} \
        --token ${GH_TOKEN}
}
