FROM alpine:3.4
MAINTAINER sparklyballs

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

COPY package/bin/shellcheck /usr/local/bin/
COPY package/lib/           /usr/local/lib/

RUN ldconfig /usr/local/lib


