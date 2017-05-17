FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	binutils-gold \
	cabal && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	ghc && \
 apk add --no-cache --virtual=build-dependencies \
	libffi-dev \
	musl-dev && \

# compile shellcheck
 cabal update && \
 cabal install ShellCheck && \

# install shellcheck
 cp /root/.cabal/bin/shellcheck /usr/local/bin/ && \
 ldd \
	/root/.cabal/bin/shellcheck | grep "=> /" \
	| awk '{print $3}' | xargs -I '{}' cp -v '{}'  \
	/usr/local/lib/ && \
 ldconfig /usr/local/lib && \

# cleanup
 apk del --purge \
	build-dependencies && \
rm -rf \
	/root \
	/tmp/* && \
 mkdir -p \
	/root
