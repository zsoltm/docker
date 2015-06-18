FROM zsoltm/buildpack-deps-armhf:jessie

RUN apt-get update && apt-get install -y --no-install-recommends\
  build-essential fakeroot devscripts
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
