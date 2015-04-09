#! /bin/sh

docker run --rm -t -v `pwd`:/usr/src zsoltm/buildpack-deps:jessie-armhf /usr/src/build-inside.sh \
 && docker build -t zsoltm/ioq3-armhf:latest .

rm ioq3-linux-armv7l.tar.bz2
