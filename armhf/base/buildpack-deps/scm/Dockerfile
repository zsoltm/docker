FROM zsoltm/buildpack-deps-curl-armhf:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
        bzr \
        git \
        mercurial \
        openssh-client \
        subversion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*