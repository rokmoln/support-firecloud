#!/usr/bin/env sh

function sf_path_prepend() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=$1:${PATH}
}

function sf_path_append() {
    echo ":${PATH}:" | grep -q ":$1:" || export PATH=${PATH}:$1
}

# remove homebrew (linuxbrew) from PATH which is appended, not prepended (default homebrew behaviour)
# see https://github.com/actions/virtual-environments/pull/789
[[ "${GITHUB_ACTIONS:-}" != "true" ]] || {
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/bin:||" | sed "s|::|:|")
    export PATH=$(echo ":${PATH}:" | sed "s|:/home/linuxbrew/.linuxbrew/sbin:||" | sed "s|::|:|")
    export PATH=$(echo "${PATH}" | sed "s|^:||" | sed "s|:$||")
}

if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    sf_path_prepend /home/linuxbrew/.linuxbrew/sbin
    sf_path_prepend /home/linuxbrew/.linuxbrew/bin
elif [ -x ~/.linuxbrew/bin/brew ]; then
    sf_path_prepend ${HOME}/.linuxbrew/sbin
    sf_path_prepend ${HOME}/.linuxbrew/bin
fi
sf_path_prepend /usr/local/sbin
sf_path_prepend /usr/local/bin
sf_path_prepend ${HOME}/.local/sbin
sf_path_prepend ${HOME}/.local/bin

if which brew >/dev/null 2>&1; then
    HOMEBREW_PREFIX=$(brew --prefix)
    sf_path_prepend ${HOMEBREW_PREFIX}/sbin
    sf_path_prepend ${HOMEBREW_PREFIX}/bin

    for f in coreutils findutils gnu-sed gnu-tar gnu-time gnu-which grep gzip make; do
        sf_path_prepend ${HOMEBREW_PREFIX}/opt/${f}/libexec/gnubin
    done
    sf_path_prepend ${HOMEBREW_PREFIX}/opt/curl/bin
    sf_path_prepend ${HOMEBREW_PREFIX}/opt/gettext/bin
    sf_path_prepend ${HOMEBREW_PREFIX}/opt/unzip/bin
    sf_path_prepend ${HOMEBREW_PREFIX}/opt/zip/bin

    unset HOMEBREW_PREFIX
fi

echo debug-exe-env-before-make
function make() {
    local MAKE_COMMAND=$(which -a make | grep "^/" | head -1)
    [[ -x make.sh ]] || [[ -n "${SF_MAKE_SH_PASS:-}" ]] || {
        ${MAKE_COMMAND} $@
        return $?
    }
    echo >&2 "[INFO] Found a ${PWD}/make.sh. Executing that instead of ${MAKE_COMMAND}."
    export SF_MAKE_SH_PASS=1
    ./make.sh $@
}
echo debug-exe-env-after-make
