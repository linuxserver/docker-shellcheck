#!/bin/bash

# clear preexisting variables not set by job
unset EXECUTABLE_FILES MOUNT_OPTIONS NON_EXECUTABLE_FILES SHELLCHECK_OPTIONS SHELLCKECK_IMAGE TEST_AREA

# initialize variables
EXECUTABLE_FILES=()
MOUNT_OPTIONS=()
NON_EXECUTABLE_FILES=()
SHELLCHECK_OPTIONS=("--exclude=SC1008" "--format=checkstyle" "--shell=bash")
SHELLCKECK_IMAGE="ghcr.io/linuxserver/lsiodev-shellcheck"
# consider using official shellcheck image
#SHELLCKECK_IMAGE="koalaman/shellcheck:stable"
TEST_AREA=()

# clear preexising checkstyle files
if [[ -f "${WORKSPACE}"/shellcheck-result.xml ]]; then
    rm "${WORKSPACE}"/shellcheck-result.xml
fi

if [[ -d "${WORKSPACE}"/init ]]; then
    MOUNT_OPTIONS+=("-v" "${WORKSPACE}/init:/init")
    TEST_AREA+=("init")
fi

if [[ -d "${WORKSPACE}"/services ]]; then
    MOUNT_OPTIONS+=("-v" "${WORKSPACE}/services:/services")
    TEST_AREA+=("services")
fi

if [[ -d "${WORKSPACE}"/root/etc/cont-init.d ]]; then
    MOUNT_OPTIONS+=("-v" "${WORKSPACE}/root/etc/cont-init.d:/root/etc/cont-init.d")
    TEST_AREA+=("root/etc/cont-init.d")
fi

if [[ -d "${WORKSPACE}"/root/etc/services.d ]]; then
    MOUNT_OPTIONS+=("-v" "${WORKSPACE}/root/etc/services.d:/root/etc/services.d")
    TEST_AREA+=("root/etc/services.d")
fi

if [[ -d "${WORKSPACE}"/root/etc/s6-overlay/s6-rc.d ]]; then
    MOUNT_OPTIONS+=("-v" "${WORKSPACE}/root/etc/s6-overlay/s6-rc.d:/root/etc/s6-overlay/s6-rc.d")
    TEST_AREA+=("root/etc/s6-overlay/s6-rc.d")
fi

# check test area for executable files
while IFS= read -r -d '' file; do
    if head -n1 "${file}" | grep -q -E -w "sh|bash|dash|ksh"; then
        if [[ -x "${file}" ]]; then
            EXECUTABLE_FILES+=("${file}")
        else
            NON_EXECUTABLE_FILES+=("${file}")
        fi
    fi
done < <(find "${TEST_AREA[@]}" -type f -print0)

# exit with error if non executable shell scripts are found
if [[ ${#NON_EXECUTABLE_FILES[@]} -ne 0 ]]; then
    echo "the following shell scripts are not executable:"
    printf "'%s'\n" "${NON_EXECUTABLE_FILES[@]}"
    exit 1
fi

# exit gracefully if no EXECUTABLE_FILES are found
if [[ ${#EXECUTABLE_FILES[@]} -eq 0 ]]; then
    echo "no common files found, linting not required"
    exit 0
fi

# run shellcheck
docker pull "${SHELLCKECK_IMAGE}"
docker run --rm -t \
    "${SHELLCKECK_IMAGE}" \
    shellcheck --version
find "${EXECUTABLE_FILES[@]}" -exec \
    docker run --rm -t \
    "${MOUNT_OPTIONS[@]}" \
    "${SHELLCKECK_IMAGE}" \
    shellcheck \
    "${SHELLCHECK_OPTIONS[@]}" {} + \
    >"${WORKSPACE}"/shellcheck-result.xml

if [[ ! -f ${WORKSPACE}/shellcheck-result.xml ]]; then
    echo "<?xml version='1.0' encoding='UTF-8'?><checkstyle version='4.3'></checkstyle>" >"${WORKSPACE}"/shellcheck-result.xml
fi

# exit gracefully
exit 0
