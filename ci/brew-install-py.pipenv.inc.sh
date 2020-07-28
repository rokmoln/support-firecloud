#!/usr/bin/env bash
set -euo pipefail

# echo_do "brew: Installing Python pipenv packages..."
# BREW_FORMULAE="$(cat <<-EOF
# pipenv
# EOF
# )"
# brew_install "${BREW_FORMULAE}"
# unset BREW_FORMULAE
# echo_done

# echo_do "brew: Testing Python pipenv packages..."
# exe_and_grep_q "pipenv --version | head -1" "^pipenv "
# echo_done

# FIXME temporary fix
# See https://github.com/pypa/pipenv/issues/3395
# See https://github.com/pypa/virtualenv/issues/1270

# pipenv hasn't been released in a while, so we take a newer unreleased version straight from the git repo
# https://github.com/pypa/pipenv/commit/2549656dc09e132d8ba2fa6327c939f5f9a951b7 was chosen
# because it has a green CI run https://github.com/pypa/pipenv/runs/361861300
PIPENV_TAG=2549656dc09e132d8ba2fa6327c939f5f9a951b7
echo_do "brew: Installing pipenv@${PIPENV_TAG} via pip3..."
brew uninstall --force pipenv
pip3 install https://github.com/pypa/pipenv/archive/${PIPENV_TAG}.zip
unset PIPENV_TAG
exe_and_grep_q "pipenv --version | head -1" "^pipenv, version 2018.11.27.dev0"
echo_done
