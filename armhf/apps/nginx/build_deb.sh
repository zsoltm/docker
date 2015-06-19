#! /bin/bash

# docker run --rm -it\
#  -v `pwd`:/mnt/out -v ${tmpDir}:/tmp/out\
#  -e NGINX_VERSION=1.9.1-1~jessie\
#  zsoltm/debian-packaging-armhf /mnt/out/build_deb.sh

echo 'deb-src http://nginx.org/packages/mainline/debian/ jessie nginx' >> /etc/apt/sources.list
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
apt-get update

arch=`dpkg --print-architecture`
pushd ${tmpDir}
apt-get --build source nginx=${NGINX_VERSION}
popd
