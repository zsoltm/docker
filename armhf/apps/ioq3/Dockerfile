# IOQ3-ARMv7l image

FROM zsoltm/debian-armhf:jessie

## ARIA2C

ADD \
https://github.com/zsoltm/aria2-static/releases/download/release-1.18.10/aria2-1.18.10-static-armv7l.tar.xz /

RUN tar xvf aria2-1.18.10-static-armv7l.tar.xz && rm aria2-1.18.10-static-armv7l.tar.xz

## GOSU

RUN cd /usr/local/bin\
 && /bin/bash -c "aria2c --check-certificate=false -Z -P\
    https://github.com/tianon/gosu/releases/download/1.3/gosu-armhf{,.asc}" \
 && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4\
 && gpg --verify gosu-armhf.asc && rm gosu-armhf.asc\
 && mv gosu-armhf gosu\
 && chmod +x gosu

## IOQ3

ADD ioq3-paks.metalink entrypoint.sh /

RUN mkdir -p /usr/local/games/quake3/baseq3\
 && cd /usr/local/games/quake3/baseq3\
 && aria2c --check-certificate=false /ioq3-paks.metalink && rm /ioq3-paks.metalink

RUN useradd -m q3\
 && aria2c --check-certificate=false\
   https://github.com/zsoltm/ioq3/releases/download/REL-1.36-2/ioq3-linux-armv7l-1.36-2.tar.xz\
 && cd /usr/local/games\
 && mkdir -p quake3 && cd quake3\
 && tar xvf /ioq3-linux-armv7l-1.36-2.tar.xz --strip-components=1\
 && rm /ioq3-linux-armv7l-1.36-2.tar.xz\
 && ln -s ioq3ded.armv7l ioq3ded\
 && ln -s ioq3ded.armv7l q3ded\
 && ln -s ioquake3.armv7l ioquake3\
 && ln -s ioq3ded.armv7l quake3

ENV PORT=27960 \
    GAME=baseq3
EXPOSE 27960/udp
VOLUME /home/q3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ioq3ded"]
