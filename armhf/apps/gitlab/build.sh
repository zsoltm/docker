#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/assets/env.sh"

prebuiltDeps="$1"
tmpDir=`mktemp -d`

if [[ -z "${prebuiltDeps}" || ! -e "${prebuiltDeps}" ]]; then
    echo "Prebuilt dependencies not found; building"
    docker run -it --rm\
     -e GITLAB_VERSION=${GITLAB_VERSION}\
     -v ${DIR}:/mnt/host:ro\
     -v ${tmpDir}:/tmp/out\
     zsoltm/buildpack-deps-armhf:jessie\
     /mnt/host/build-bundle/build_inside.sh
    prebuiltDeps="${tmpDir}/gitlab-bundle.tar.gz"
else
    echo "Using prebuilt dependencies bundle: ${prebuiltDeps}"
fi

if [ "${prebuiltDeps}" != "${tmpDir}/gitlab-bundle.tar.gz" ]; then
    cp ${prebuiltDeps} ${tmpDir}/gitlab-bundle.tar.gz
fi

pushd ${tmpDir}
cp -R "${DIR}/assets" .
ln -s "${DIR}/Dockerfile"
docker build -t zsoltm/gitlab-armhf .
popd ${tmpDir}
