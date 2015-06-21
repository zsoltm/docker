#! /bin/bash
set -e

tmpDir=`mktemp -d`
nginxVersion=1.9.2-1

docker run --rm -it\
 -v `pwd`:/mnt/out\
 -e tmpDir="${tmpDir}"\
 -e NGINX_VERSION="${nginxVersion}"'~jessie'\
 zsoltm/buildpack-deps-deb-armhf:jessie /mnt/out/build_deb.sh

cp Dockerfile ${tmpDir}
pushd ${tmpDir}
docker build -t zsoltm/nginx-armhf:1.9.2-2 .
popd

rm -Rf ${tmpDir}
