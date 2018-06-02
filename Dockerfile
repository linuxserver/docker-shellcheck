############## build stage ##############
FROM scratch as buildstage
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# package versions
ARG SHELLCHECK_VER="0.5.0"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	binutils-gold \
	curl \
	ghc \
	git \
	libffi-dev \
	musl-dev \
	tar && \
 apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	cabal && \
 echo "**** compile shellcheck ****" && \
 mkdir -p \
	/tmp/shellcheck && \
 curl -o \
 /tmp/shellcheck-src.tar.gz -L \
	"https://github.com/koalaman/shellcheck/archive/v$SHELLCHECK_VER.tar.gz" && \
 tar xf /tmp/shellcheck-src.tar.gz -C \
	/tmp/shellcheck --strip-components=1 && \
 cd /tmp/shellcheck && \
 cabal update && \
 cabal install && \
 echo "**** install shellcheck in buildstage ****" && \
 cp /root/.cabal/bin/shellcheck /usr/local/bin/ && \
 ldd \
	/root/.cabal/bin/shellcheck | grep "=> /" \
	| awk '{print $3}' | xargs -I '{}' cp -v '{}'  \
	/usr/local/lib/

############## runtime stage ##############
FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy files from build stage
COPY --from=buildstage /usr/local/ /usr/local/
# RUN ldconfig /usr/local/lib
