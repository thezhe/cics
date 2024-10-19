#!/usr/bin/env sh
## Strict mode
set -eu
IFS="(printf '\n\t')"
readonly IFS
## Prologue
test_script_path="$(
    script_directory="$(dirname "${0}")"
    cd -- "${script_directory}"
    pwd -P
)"
cics="${test_script_path}/cics"
readonly cics test_script_path
## Pass-fail tests
(
    set -x
    # Help
    "${cics}" -h
    ! "${cics}"
    "${cics}" install -h
    "${cics}" list -h
    "${cics}" run -h
    "${cics}" uninstall -h
    ! "${cics}" not_a_command -h
    ! "${cics}" not_a_command
    # Commands
    "${cics}" install ghcr.io/hadolint/hadolint docker.io/koalaman/shellcheck:stable
    ! "${cics}" install ghcr.io/hadolint/hadolint
    ! "${cics}" install
    "${cics}" list
    ! "${cics}" list hadolint
    "${cics}" run "${test_script_path}/hadolint" --help
    "${cics}" run "${test_script_path}/shellcheck" --help
    ! "${cics}" run
    "${cics}" uninstall hadolint shellcheck
    ! "${cics}" uninstall hadolint shellcheck
    ! "${cics}" uninstall
    # Post conditions (idempotency)
    ! [ -f "${test_script_path}/hadolint" ]
    ! [ -f "${test_script_path}/shellcheck" ]
) >/dev/null
