#!/bin/bash

# clear preexisting variables not set by job
unset MOUNT_OPTIONS TEST_AREA LINT_ARCH SHELLCHECK_OPTIONS

# clear preexising checkstyle files
[[ -f "${PWD}"/shellcheck-result.xml ]] && rm "${PWD}"/shellcheck-result.xml

# check for common locations and exit if not found
if [[ ! -d "${PWD}"/root/etc/cont-init.d  && ! -d "${PWD}"/root/etc/services.d && \
! -d "${PWD}"/init  && ! -d "${PWD}"/services ]]; then
echo "no common files found, linting not required" exit 0
fi

if [[ ! -d "${PWD}"/root/etc/cont-init.d  && ! -d "${PWD}"/root/etc/services.d ]] && \
[[ -d "${PWD}"/init && -d "${PWD}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/init:/init -v ${PWD}/services:/services"
TEST_AREA="init services"

elif [[ ! -d "${PWD}"/root/etc/cont-init.d  && ! -d "${PWD}"/root/etc/services.d ]] && \
[[ ! -d "${PWD}"/init && -d "${PWD}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/services:/services"
TEST_AREA="services"

elif [[ ! -d "${PWD}"/root/etc/cont-init.d  && ! -d "${PWD}"/root/etc/services.d ]] && \
[[ -d "${PWD}"/init && ! -d "${PWD}"/services ]]; then
SHELLCHECK_OPTIONS="--format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/init:/init"
TEST_AREA="init"

elif [[ -d "${PWD}"/root/etc/cont-init.d  && -d "${PWD}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/root:/root"
TEST_AREA="root/etc/services.d root/etc/cont-init.d"

elif [[ ! -d "${PWD}"/root/etc/cont-init.d  && -d "${PWD}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/root:/root"
TEST_AREA="root/etc/services.d"

elif [[ -d "${PWD}"/root/etc/cont-init.d  && ! -d "${PWD}"/root/etc/services.d ]]; then
SHELLCHECK_OPTIONS="--exclude=SC1008 --format=checkstyle --shell=bash"
MOUNT_OPTIONS="-v ${PWD}/root:/root"
TEST_AREA="root/etc/cont-init.d"
fi

# run shellcheck
if [[ -d "${PWD}"/root/etc/cont-init.d || -d "${PWD}"/root/etc/services.d || \
-d "${PWD}"/init  || -d "${PWD}"/services ]];then

docker pull lsiodev/shellcheck

docker run \
	--rm=true -t \
	${MOUNT_OPTIONS} \
	lsiodev/shellcheck \
	find ${TEST_AREA} -type f -exec shellcheck ${SHELLCHECK_OPTIONS} {} + \
	> ${PWD}/shellcheck-result.xml

fi

[[ ! -f ${PWD}/shellcheck-result.xml ]] && echo "<?xml version='1.0' encoding='UTF-8'?><checkstyle version='4.3'></checkstyle>" > ${PWD}/shellcheck-result.xml

# exit gracefully
exit 0
