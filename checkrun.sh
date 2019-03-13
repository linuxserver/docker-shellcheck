#!/bin/bash

# clear preexisting variables not set by job
unset MOUNT_OPTIONS TEST_AREA LINT_ARCH SHELLCHECK_OPTIONS

# clear preexising checkstyle files
[[ -f "${WORKSPACE}"/shellcheck-result.xml ]] && rm "${WORKSPACE}"/shellcheck-result.xml

# check for common locations and exit if not found
if [[ ! -d "${WORKSPACE}"/root/etc/cont-init.d  && ! -d "${WORKSPACE}"/root/etc/services.d && \
! -d "${WORKSPACE}"/init  && ! -d "${WORKSPACE}"/services ]]; then
echo "no common files found, linting not required" exit 0
fi

if [[ ! -d "${WORKSPACE}"/root/etc/cont-init.d  && ! -d "${WORKSPACE}"/root/etc/services.d ]] && \
[[ -d "${WORKSPACE}"/init && -d "${WORKSPACE}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/init:/init -v ${WORKSPACE}/services:/services"
TEST_AREA="init services"

elif [[ ! -d "${WORKSPACE}"/root/etc/cont-init.d  && ! -d "${WORKSPACE}"/root/etc/services.d ]] && \
[[ ! -d "${WORKSPACE}"/init && -d "${WORKSPACE}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/services:/services"
TEST_AREA="services"

elif [[ ! -d "${WORKSPACE}"/root/etc/cont-init.d  && ! -d "${WORKSPACE}"/root/etc/services.d ]] && \
[[ -d "${WORKSPACE}"/init && ! -d "${WORKSPACE}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/init:/init"
TEST_AREA="init"

elif [[ -d "${WORKSPACE}"/root/etc/cont-init.d  && -d "${WORKSPACE}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/root:/root"
TEST_AREA="root/etc/services.d root/etc/cont-init.d"

elif [[ ! -d "${WORKSPACE}"/root/etc/cont-init.d  && -d "${WORKSPACE}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/root:/root"
TEST_AREA="root/etc/services.d"

elif [[ -d "${WORKSPACE}"/root/etc/cont-init.d  && ! -d "${WORKSPACE}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${WORKSPACE}/root:/root"
TEST_AREA="root/etc/cont-init.d"
fi

# run shellcheck
if [[ -d "${WORKSPACE}"/root/etc/cont-init.d || -d "${WORKSPACE}"/root/etc/services.d || \
-d "${WORKSPACE}"/init  || -d "${WORKSPACE}"/services ]];then

docker pull lsiodev/shellcheck

docker run \
	--rm=true -t \
	${MOUNT_OPTIONS} \
	lsiodev/shellcheck \
	find ${TEST_AREA} -type f -exec shellcheck ${SHELLCHECK_OPTIONS} {} + \
	> ${WORKSPACE}/shellcheck-result.xml

fi

[[ ! -f ${WORKSPACE}/shellcheck-result.xml ]] && echo "<?xml version='1.0' encoding='UTF-8'?><checkstyle version='4.3'></checkstyle>" > ${WORKSPACE}/shellcheck-result.xml

# exit gracefully
exit 0
