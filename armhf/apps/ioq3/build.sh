#! /bin/sh

wget http://osp.dget.cc/orangesmoothie/downloads/osp-Quake3-1.03a_full.zip || exit 1

docker run --rm -t -v `pwd`:/usr/src zsoltm/buildpack-deps:jessie-armhf /usr/src/build-inside.sh \
 && docker build -t zsoltm/ioq3-armhf:latest . \
 && rm osp-Quake3-1.03a_full.zip

rm ioq3-linux-armv7l.tar.bz2
