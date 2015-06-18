#! /bin/bash

docker run --rm -it\
 -v `pwd`:/mnt/out -v ${tmpDir}:/tmp/out\
 -e NGINX_VERSION=1.9.1-1~jessie\
 zsoltm/buildpack-deps-deb-armhf /mnt/out/build_deb.sh
