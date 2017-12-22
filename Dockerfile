FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	binutils-gold \
	ghc \
	git \
	libffi-dev \
	musl-dev && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	cabal && \
 echo "**** compile shellcheck ****" && \
 git clone https://github.com/koalaman/shellcheck /tmp/shellcheck && \
 cd /tmp/shellcheck && \
 cabal update && \
 cabal install && \
 echo "**** install shellcheck ****" && \
 cp /root/.cabal/bin/shellcheck /usr/local/bin/ && \
 ldd \
	/root/.cabal/bin/shellcheck | grep "=> /" \
	| awk '{print $3}' | xargs -I '{}' cp -v '{}'  \
	/usr/local/lib/ && \
 ldconfig /usr/local/lib && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
rm -rf \
	/root \
	/tmp/* && \
 mkdir -p \
	/root
