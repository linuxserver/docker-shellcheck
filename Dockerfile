FROM alpine:edge
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# copy apk key
COPY mitch.tishmack@gmail.com-55881c97.rsa.pub /etc/apk/keys/mitch.tishmack@gmail.com-55881c97.rsa.pub

# install packages
RUN \
 echo "https://s3-us-west-2.amazonaws.com/alpine-ghc/next/8.0" >> /etc/apk/repositories && \
 apk add --no-cache --virtual=build-dependencies \
	bash \
	binutils \
	cabal \
	g++ \
	gcc \
	ghc \
	ghc-dev \
	git \
	make \
	stack && \

# update cabal and stack
 cabal \
	update && \
 stack \
	update && \

# compile shellcheck
 cabal install ShellCheck && \
 cp /root/.cabal/bin/shellcheck /usr/local/bin/ && \
 ldd /root/.cabal/bin/shellcheck | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}'  /usr/local/lib/ && \
 ldconfig /usr/local/lib && \

# clean up
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* && \
 find /root -name . -o -prune -exec rm -rf -- {} + && \
 mkdir -p \
	/root
