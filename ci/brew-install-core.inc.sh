#!/usr/bin/env bash
set -euo pipefail

if [[ "${SF_SKIP_COMMON_BOOTSTRAP:-}" = "true" ]]; then
    echo_info "brew: SF_SKIP_COMMON_BOOTSTRAP=${SF_SKIP_COMMON_BOOTSTRAP}"
    echo_skip "brew: Installing core packages..."
else
    echo_do "brew: Installing core packages..."
    # 'findutils' provides 'xargs', because the OSX version has no 'xargs -r'
    BREW_FORMULAE="$(cat <<-EOF
${SUPPORT_FIRECLOUD_DIR}/Formula/editorconfig-checker.rb
${SUPPORT_FIRECLOUD_DIR}/Formula/retry.rb
bash
curl
findutils
git
jq
make
unzip
zip
EOF
)"
    brew_install "${BREW_FORMULAE}"
    unset BREW_FORMULAE
    echo_done

    echo_do "brew: Testing core packages..."
    exe_and_grep_q "bash --version | head -1" "^GNU bash, version [^123]\\."
    exe_and_grep_q "curl --version | head -1" "^curl 7\\."
    exe_and_grep_q "editorconfig-checker --version | head -1" "^2\\."
    exe_and_grep_q "git --version | head -1" "^git version 2\\."
    exe_and_grep_q "jq --version | head -1" "^jq\\-1\\."
    exe_and_grep_q "make --version | head -1" "^GNU Make 4\\."
    exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" "^UnZip 6\\."
    exe_and_grep_q "unzip --version 2>&1 | head -2 | tail -1" ", by Debian\\."
    # need an extra condition, because the original one fails intermitently
    # exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
    echo | xargs -r false || {
        echo_err "Your xargs doesn't have a working -r (short for --no-run-of-empty) option."
        exe_and_grep_q "xargs --help 2>&1" "no\\-run\\-if\\-empty"
        exit 1
    }
    exe_and_grep_q "zip --version 2>&1 | head -2 | tail -1" "Zip 3\\.0"
    exe_and_grep_q "zip --version 2>&1 | head -2 | tail -1" ", by Info-ZIP\\."
    echo_done
fi
