############## build stage ##############
FROM ubuntu as buildstage

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# build environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# package versions
ARG SHELLCHECK_VER="0.5.0"

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
	apt-get install -y \
	cabal-install \
	curl \
	ghc \
	git && \
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
 cabal install --dependencies-only && \
 cabal build Paths_ShellCheck && \
 ghc \
	-idist/build/autogen \
	-isrc \
	-optl-pthread \
	-optl-static \
	--make \
	shellcheck && \
 strip --strip-all shellcheck

############## runtime stage ##############
FROM scratch
ADD rootfs.tar.xz /

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy files from build stage
COPY --from=buildstage /tmp/shellcheck/shellcheck /usr/local/bin/
