FROM ubuntu:16.04
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV LC_ALL=en_US.iso88591

# build packages as variable
ARG BUILD_PACKAGES="\
	cabal-install \
	git"

# Set the locale
RUN locale-gen en_US.iso88591

# install build packages
RUN \
 apt-get update && \
 apt-get install -y \
	$BUILD_PACKAGES && \

# compile shellcheck
 cabal update && \
 git clone https://github.com/koalaman/shellcheck \
	/tmp/shellcheck && \
 cd /tmp/shellcheck && \
 cabal install && \
 export OLDPATH="$PATH" && \
 export PATH="/root/.cabal/bin:$PATH" && \
 cp $(which shellcheck) /usr/local/bin/ && \
 ldd $(which shellcheck) | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' /usr/local/lib/ && \
 export PATH="$OLDPATH" && \
 ldconfig /usr/local/lib && \

# cleanup
 apt-get purge -y --auto-remove \
	$BUILD_PACKAGES && \
 rm -rf \
	/root/.cabal \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

WORKDIR /mnt
ENTRYPOINT ["shellcheck"]
