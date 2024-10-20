#!/usr/bin/env sh
# shellcheck disable=SC2251 # '&& exit 1' inverts errexit, but '!' also inverts exit codes
## Strict mode
set -eu
IFS="$(printf "\n\t")"
readonly IFS
## Prologue
test_script_path="$(
    script_directory="$(dirname -- "${0}")"
    cd -- "${script_directory}" >/dev/null 2>&1
    pwd -P
)"
test_cics="${test_script_path}/cics"
readonly test_cics test_script_path
## Pass-fail tests
(
    set -x
    # Help
    "${test_cics}" -h
    ! "${test_cics}"
    "${test_cics}" install -h
    "${test_cics}" list -h
    "${test_cics}" run -h
    "${test_cics}" uninstall -h
    ! "${test_cics}" not_a_command -h
    ! "${test_cics}" not_a_command
    # Commands
    "${test_cics}" install docker.io/rhysd/actionlint:latest docker.io/koalaman/shellcheck:stable ghcr.io/hadolint/hadolint
    ! "${test_cics}" install ghcr.io/hadolint/hadolint
    ! "${test_cics}" install
    "${test_cics}" upgrade
    ! "${test_cics}" upgrade actionlint
    "${test_cics}" list
    ! "${test_cics}" list hadolint
    "${test_cics}" run "${test_script_path}/actionlint" -version
    "${test_cics}" run "${test_script_path}/hadolint" --help
    "${test_cics}" run "${test_script_path}/shellcheck" --help
    ! "${test_cics}" run
    "${test_cics}" uninstall actionlint hadolint shellcheck
    ! "${test_cics}" uninstall actionlint hadolint shellcheck
    ! "${test_cics}" uninstall
    # Post conditions (idempotency)
    "${test_cics}" upgrade
    "${test_cics}" list
    ! [ -f "${test_script_path}/actionlint" ]
    ! [ -f "${test_script_path}/hadolint" ]
    ! [ -f "${test_script_path}/shellcheck" ]
    # cics never removes images
    podman inspect --type image docker.io/rhysd/actionlint:latest
    podman inspect --type image docker.io/koalaman/shellcheck:stable
    podman inspect --type image ghcr.io/hadolint/hadolint
) >/dev/null
