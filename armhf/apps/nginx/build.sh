#! /bin/bash
set -e

tmpDir=`mktemp -d`
nginxVersion=1.9.2-1

docker run --rm -it\
 -v `pwd`:/mnt/host\
 -e tmpDir="${tmpDir}"\
 -e NGINX_VERSION="${nginxVersion}"'~jessie'\
 zsoltm/buildpack-deps-armhf:jessie-deb /mnt/host/build_deb.sh

cp Dockerfile ${tmpDir}
pushd ${tmpDir}
docker build -t zsoltm/nginx-armhf .
popd

rm -Rf ${tmpDir}
