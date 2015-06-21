#! /bin/sh

set -e

tmpDir=`mktemp -d`

docker run --rm -it\
 -v `pwd`:/mnt/host:ro\
 -v "${tmpDir}":/tmp/out\
 zsoltm/buildpack-deps-armhf:jessie-deb bash -c\
  '/mnt/host/dockerized/build_privoxy_deb.sh && /mnt/host/dockerized/fetch_gosu.sh'

cp Dockerfile "${tmpDir}"

pushd "${tmpDir}"
docker build -t zsoltm/privoxy-armhf .
popd 

rm -Rf ${tmpDir}
