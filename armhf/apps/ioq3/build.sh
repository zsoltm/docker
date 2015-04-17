#! /bin/sh

image=$(docker build -t zsoltm/io-quake3-armhf:latest .)
docker tag ${image} zsoltm/io-quake3-armhf:1.36-3
