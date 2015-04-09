#! /bin/bash
set -e

apt-get update && apt-get install -y --no-install-recommends\
    zip unzip libsdl2-dev makeself

mkdir -p /tmp/build && pushd /tmp/build\
 && curl -OkL https://github.com/zsoltm/ioq3/archive/arm-custom.zip\
 && unzip arm-custom.zip\
 && rm arm-custom.zip\
 && pushd ioq3-arm-custom\
 && make -j4\
 && pushd build\
 && pushd release-linux-armv7l\
 && rm -Rf client ded renderergl1 renderergl2 \
  tools/asm tools/cpp tools/etc tools/lburg tools/rcc \
  baseq3/cgame baseq3/game baseq3/qcommon baseq3/ui \
  missionpack/cgame missionpack/game missionpack/qcommon missionpack/ui \
 && popd\
 && mv release-linux-armv7l ioq3-linux-armv7l\
 && tar cjvf /usr/src/ioq3-linux-armv7l.tar.bz2 ioq3-linux-armv7l \
 && popd && popd && popd

echo "Sucessfuly built IOQ3"
