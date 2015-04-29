# IOQ3-ARMv7l image

FROM zsoltm/debian-armhf:jessie

## ARIA2C

ADD \
https://github.com/zsoltm/aria2-static/releases/download/release-1.18.10/aria2-1.18.10-static-armv7l.tar.xz /

RUN tar xvf aria2-1.18.10-static-armv7l.tar.xz && rm aria2-1.18.10-static-armv7l.tar.xz

## supervisord

RUN apt-get update && apt-get install -y --no-install-recommends supervisor\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

## IOQ3

ADD ioq3-paks.metalink /

RUN mkdir -p /usr/local/games/quake3/baseq3\
 && cd /usr/local/games/quake3/baseq3\
 && aria2c --check-certificate=false /ioq3-paks.metalink && rm /ioq3-paks.metalink

ADD supervisord.conf entrypoint.sh /
RUN useradd -m q3\
 && aria2c --check-certificate=false\
   https://github.com/zsoltm/ioq3/releases/download/REL-1.36-3/ioq3-linux-armv7l-1.36-3.tar.xz\
 && cd /usr/local/games\
 && mkdir -p quake3 && cd quake3\
 && tar xvf /ioq3-linux-armv7l-1.36-3.tar.xz --strip-components=1\
 && rm /ioq3-linux-armv7l-1.36-3.tar.xz\
 && ln -s ioq3ded.armv7l ioq3ded\
 && ln -s ioq3ded.armv7l q3ded\
 && ln -s ioquake3.armv7l ioquake3\
 && ln -s ioq3ded.armv7l quake3\
 && mv /supervisord.conf /etc/supervisor/supervisord.conf

ENV PORT 27960
ENV GAME baseq3
ENV DEDICATED 1
ENV NAME Dockerized ^2/ ^3Vanilla ^2/ ^6ARMv7l
ENV RCON=
ENV PURE 1
ENV MAX_CLIENTS 8
EXPOSE 27960/udp
VOLUME /home/q3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ioq3ded"]
