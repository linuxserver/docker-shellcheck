FROM alpine:3.4
MAINTAINER sparklyballs

# copy files from jenkins builder job
COPY package/bin/shellcheck /usr/local/bin/
COPY package/lib/ /usr/local/lib/

# load lib files
RUN \
 ldconfig /usr/local/lib

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

