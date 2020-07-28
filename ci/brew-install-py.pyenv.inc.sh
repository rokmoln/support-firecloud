#!/usr/bin/env bash
set -euo pipefail

echo_do "brew: Installing Python pyenv packages..."
BREW_FORMULAE="$(cat <<-EOF
pyenv
EOF
)"
brew_install "${BREW_FORMULAE}"
unset BREW_FORMULAE
eval "$(pyenv init -)"
mkdir -p ~/.pyenv/versions
for PYTHON_VSN in $(brew --cellar python)/*; do
    ln -sf ${PYTHON_VSN} ~/.pyenv/versions/
done
unset PYTHON_VSN
echo_done

echo_do "brew: Testing Python pyenv packages..."
exe_and_grep_q "pyenv --version | head -1" "^pyenv "
echo_done
