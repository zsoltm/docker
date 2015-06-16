#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/assets/env.sh"

prebuildDeps="$1"
tmpDir=`mktemp -d`

if [[ -z "$1" || ! -e "$1" ]]; then
    echo "Prebuilt dependencies not found; building"
    cp ${DIR}/
    docker run -it --rm\
     -e GITLAB_VERSION=${GITLAB_VERSION}\
     -v ${DIR}:/usr/src/gitlab-docker\
     -v ${tmpDir}:/tmp/out\
     buildpack-deps:jessie\
     /usr/src/gitlab-docker/build-bundle/build_inside.sh
    prebuildDeps="${tmpDir}/gitlab-bundle.tar.gz"
else
    echo "Using prebuilt dependencies bundle: ${prebuildDeps}"
    if [ "${prebuildDeps}" != "${tmpDir}/gitlab-bundle.tar.gz" ]; then
        cp ${prebuildDeps} ${tmpDir}/gitlab-bundle.tar.gz
    fi
fi

pushd ${tmpDir}
cp -R "${DIR}/assets" .
ln -s "${DIR}/Dockerfile"
docker build .
popd ${tmpDir}

zsoltm/gitlab-armhf:${GITLAB_VERSION}-latest
