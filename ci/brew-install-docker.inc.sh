#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing Docker packages..."
else
    echo_do "brew: Installing Docker packages..."

    case $(uname -s) in
        Darwin)
            HAS_DOCKER=true
            if which docker >/dev/null 2>&1; then
                exe_and_grep_q "docker --version | head -1" "^Docker version." || HAS_DOCKER=false
            else
                HAS_DOCKER=false
            fi
            if ${HAS_DOCKER}; then
                echo_skip "Installing Docker via 'brew cask'."
            else
                if [[ "${CI:-}" = "true" ]]; then
                    echo_skip "Installing Docker via 'brew cask'..."
                    echo_do "Installing Docker via 'brew'..."
                    brew_install docker
                    brew_install docker-compose
                    echo_done
                else
                    echo_do "Installing Docker via 'brew cask'..."
                    brew cask install docker
                    echo_done
                fi
            fi
            unset HAS_DOCKER
            ;;
        Linux)
            (
                RELEASE_ID="$(source /etc/os-release && echo ${ID})"
                RELEASE_VERSION_ID="$(source /etc/os-release && echo ${VERSION_ID})"
                RELEASE_VERSION_CODENAME="$(source /etc/os-release && echo ${VERSION_CODENAME})"
                # docker-compose via linuxbrew fails on Ubuntu 20.04
                # https://travis-ci.com/github/rokmoln/support-firecloud/jobs/362746866#L2781
                case ${RELEASE_ID}-${RELEASE_VERSION_CODENAME} in
                    ubuntu-focal)
                        # BEGIN https://docs.docker.com/engine/install/ubuntu/
                        for PKG in docker docker-engine docker.io containerd runc; do
                            ${SUDO} apt-get remove ${PKG} || true;
                        done
                        unset PKG

                        apt_install apt-transport-https
                        apt_install ca-certificates
                        apt_install curl
                        apt_install gnupg-agent
                        apt_install software-properties-common

                        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | ${SUDO} apt-key add -
                        ${SUDO} apt-key fingerprint 0EBFCD88
                        ${SUDO} add-apt-repository -u \
                                "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

                        apt_install docker-ce
                        apt_install docker-ce-cli
                        apt_install containerd.io

                        # ENV https://docs.docker.com/engine/install/ubuntu/
                        # BEGIN https://docs.docker.com/compose/install/
                        DOCKER_COMPOSE_LATEST_URL=https://github.com/docker/compose/releases/latest/download
                        ${SUDO} curl -L -o /usr/local/bin/docker-compose \
                            "${DOCKER_COMPOSE_LATEST_URL}/docker-compose-$(uname -s)-$(uname -m)"
                        ${SUDO} chmod +x /usr/local/bin/docker-compose
                        unset DOCKER_COMPOSE_LATEST_URL
                        # END https://docs.docker.com/compose/install/
                        ;;
                    *)
                        brew_install docker
                        # workaround for "Illegal instruction", see https://github.com/rokmoln/support-firecloud/issues/198
                        # brew_install docker-compose
                        brew_install "docker-compose --build-from-source"
                        ;;
                esac
                unset RELEASE_ID
                unset RELEASE_VERSION_ID
                unset RELEASE_VERSION_CODENAME
            )
            ;;
        *)
            echo_err "$(uname -s) is an unsupported OS for installing Docker."
            return 1
            ;;
    esac

    echo_done

    echo_do "brew: Testing Docker packages..."
    exe_and_grep_q "docker --version | head -1" "^Docker version 19\."
    exe_and_grep_q "docker-compose --version | head -1" "^docker-compose version 1\."
    echo_done
fi
