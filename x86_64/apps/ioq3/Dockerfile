# IOQ3-x86_64 image

FROM debian:jessie

## ARIA2C, unzip, supervisord

RUN apt-get update && apt-get install -y --no-install-recommends unzip aria2 supervisor\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

## IOQ3

ADD ioq3-paks.metalink /

RUN mkdir -p /usr/local/games/quake3/baseq3\
 && cd /usr/local/games/quake3/baseq3\
 && aria2c --check-certificate=false /ioq3-paks.metalink && rm /ioq3-paks.metalink

ADD supervisord.conf entrypoint.sh /
RUN useradd -m q3\
 && aria2c --check-certificate=false\
   https://github.com/zsoltm/ioq3/releases/download/REL-1.36-3/ioq3-linux-x86_64-1.36-3.tar.xz\
 && cd /usr/local/games\
 && mkdir -p quake3 && cd quake3\
 && tar xvf /ioq3-linux-x86_64-1.36-3.tar.xz --strip-components=1\
 && rm /ioq3-linux-x86_64-1.36-3.tar.xz\
 && ln -s ioq3ded.x86_64 ioq3ded\
 && ln -s ioq3ded.x86_64 q3ded\
 && ln -s ioquake3.x86_64 ioquake3\
 && ln -s ioq3ded.x86_64 quake3\
 && mv /supervisord.conf /etc/supervisor/supervisord.conf

ENV PORT 27960
ENV GAME baseq3
ENV DEDICATED 1
ENV NAME Dockerized ^2/ ^3Vanilla ^2/ ^6x86_64
ENV RCON=
ENV PURE 1
ENV MAX_CLIENTS 8
EXPOSE 27960/udp
VOLUME /home/q3

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ioq3ded"]
