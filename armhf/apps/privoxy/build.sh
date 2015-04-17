#! /bin/sh

docker run -t --rm -v `pwd`:/target zsoltm/buildpack-deps:jessie-armhf /target/build_privoxy.sh && \
docker build -t zsoltm/privoxy-armhf . && \
rm privoxy-3.0.23-local.tar.gz
