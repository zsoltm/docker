#! /bin/bash

BUILD_DIR=`mktemp -d`
DEBIAN_MIRROR=http://ftp.ch.debian.org/debian/

cp Dockerfile "${BUILD_DIR}"

docker run --rm --privileged -t\
 -v "${BUILD_DIR}":/tmp/build\
 -v "`pwd`":/usr/src/jessie\
 -e DISTRO=jessie\
 -e DEBIAN_MIRROR=${DEBIAN_MIRROR}\
 debian:jessie /bin/bash -c /usr/src/jessie/inception.sh || exit 1

docker build\
 -t zsoltm/debian-armhf:latest\
 -t zsoltm/debian-armhf:jessie\
 -t zsoltm/debian-armhf:8\
 -t zsoltm/debian-armhf:8.0 ${BUILD_DIR} || exit 1

rm -Rf ${BUILD_DIR}
