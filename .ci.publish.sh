#!/usr/bin/env bash

SF_DOCKER_CI_IMAGE=false
DOCKER_ORG=${DOCKER_ORG:-rokmoln}

function ci_run_before_install() {
    true
}

function ci_run_install() {
    true
}

function ci_run_before_script() {
    true
}

function ci_run_script() {
    true
}

function ci_run_before_deploy() {
    true
}

function ci_run_deploy_docker_image_hubdockercom() {
    [[ -n "${DOCKER_USERNAME:-}" ]] || return
    [[ -n "${DOCKER_TOKEN:-}" ]] || return

    echo "${DOCKER_TOKEN}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

    local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG}..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image_dockerpkggithubcom() {
    [[ -n "${GH_USERNAME:-}" ]] || return
    [[ -n "${GH_TOKEN:-}" ]] || return

    local GH_DOCKER_HUB=docker.pkg.github.com

    echo "${GH_TOKEN}" | docker login -u ${GH_USERNAME} --password-stdin ${GH_DOCKER_HUB}

    local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
    echo_do "Pushing ${TAG}..."
    exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
    exe docker push ${TAG}
    echo_done

    local PUBLISH_AS_LATEST_TAG=$1
    if [[ "${PUBLISH_AS_LATEST_TAG}" = "true" ]]; then
        local TAG=${GH_DOCKER_HUB}/${CI_REPO_SLUG}/${DOCKER_IMAGE_NAME}:latest
        echo_do "Pushing ${TAG}..."
        exe docker tag ${DOCKER_ORG}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${TAG}
        exe docker push ${TAG}
        echo_done
    fi
}

function ci_run_deploy_docker_image() {
    # safety pin: release only on Travis
    [[ "${TRAVIS:-}" = "true" ]] || return

    # safety pin: release only on Linux
    [[ "${TRAVIS_OS_NAME:-}" = "linux" ]] || return

    [[ "${SF_CI_BREW_INSTALL}" != "dev" ]] || SF_CI_BREW_INSTALL=common

    # NOTE keep in sync with `dockerfiles/build`
    local RELEASE_ID="$(source /etc/os-release && echo ${ID})"
    local RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"
    local RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
    local DOCKER_IMAGE_NAME=sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}-${SF_CI_BREW_INSTALL}
    local DOCKER_IMAGE_TAG=$(cat package.json | jq -r ".version")
    local DOCKERFILE=${SUPPORT_FIRECLOUD_DIR}/dockerfiles/sf-${RELEASE_ID}-${RELEASE_VERSION_CODENAME}/Dockerfile
    [[ -f "${DOCKERFILE}" ]] || return

    # NOTE jq must be preinstalled
    local TIMESTAMP_LATEST=$(
        curl https://hub.docker.com/v2/repositories/${DOCKER_ORG}/${DOCKER_IMAGE_NAME}/tags/latest | \
            jq -r .last_updated | \
            xargs -r -0 date +%s -d || \
            echo 0)

    ${SUPPORT_FIRECLOUD_DIR}/dockerfiles/build \
        --release-id ${RELEASE_ID} \
        --release-version-id ${RELEASE_VERSION_ID} \
        --release-version-codename ${RELEASE_VERSION_CODENAME} \
        --docker-org ${DOCKER_ORG} \
        --docker-image-name ${DOCKER_IMAGE_NAME} \
        --docker-image-tag ${DOCKER_IMAGE_TAG} \
        --dockerfile ${DOCKERFILE} \
        --sf-ci-brew-install ${SF_CI_BREW_INSTALL}

    # don't push as 'latest' tag if the tag has been updated after the current commit
    local PUBLISH_AS_LATEST_TAG=false
    if [[ $(git show -s --format=%ct HEAD) -ge ${TIMESTAMP_LATEST} ]]; then
        PUBLISH_AS_LATEST_TAG=true
    fi

    ci_run_deploy_docker_image_hubdockercom ${PUBLISH_AS_LATEST_TAG}

    # DONT USE docker.pkg.github.com
    # 1. it requires credentials even for downloading *public* packages
    # 2. *public* packages cannot be deleted, neither entirely, nor specific versions
    # https://help.github.com/en/github/managing-packages-with-github-packages/deleting-a-package
    # ci_run_deploy_docker_image_dockerpkggithubcom ${PUBLISH_AS_LATEST_TAG}
}

function ci_run_deploy() {
    PKG_VSN=$(cat package.json | jq -r ".version")
    echo "${GIT_TAGS}" | grep -q "v${PKG_VSN}" || {
        echo_err "${FUNCNAME[0]}: git tags ${GIT_TAGS} do not match package.json version v${PKG_VSN}."
        return 1
    }

    ci_run_deploy_docker_image
}

source "${SUPPORT_FIRECLOUD_DIR}/repo/dot.ci.sh.sf"
