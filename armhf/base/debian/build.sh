#! /bin/bash

TEMP_DIR=`mktemp -d`
DEBIAN_MIRROR=http://ftp.ch.debian.org/debian/

docker run --rm --privileged -t\
 -v "${TEMP_DIR}":/tmp/build\
 -v "`pwd`":/usr/src/jessie\
 -e DISTRO=jessie\
 -e DEBIAN_MIRROR=${DEBIAN_MIRROR}\
 debian:jessie /bin/bash -c /usr/src/jessie/inception.sh

docker build\
 -t zsoltm/debian-armhf:latest\
 -t zsoltm/debian-armhf:jessie\
 -t zsoltm/debian-armhf:8\
 -t zsoltm/debian-armhf:8.0 ${TEMP_DIR}

rm -Rf ${TEMP_DIR}
